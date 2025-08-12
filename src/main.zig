const std = @import("std");
const asset_loader = @import("asset_loader.zig");
const c = @import("c.zig");
const ecs = @import("ecs.zig");
const FpsLimiter = @import("FpsLimiter.zig");
const sdl = @import("sdl.zig");
const Vec2 = @import("Vec2.zig").Vec2;
const entt = @import("entt");

const window_title = "Pacman";
const initial_window_size = Vec2(u32){ .x = 600, .y = 400 };
const ghost1_spawn_delay_s = 5;
const ghost2_spawn_delay_s = 30;
const ghost3_spawn_delay_s = 60;

const fast_stupid_ghost_config: ecs.entity.GhostCreator.Config = .{
    .find_path_chance = 0.1,
    .find_path_period_s = 1,
    .move_speed = 5.5,
    .sprite_fps = 30,
};

const kinda_smart_ghost_config: ecs.entity.GhostCreator.Config = .{
    .find_path_chance = 0.4,
    .find_path_period_s = 1,
    .move_speed = 4.2,
    .sprite_fps = 25,
};

const fat_genious_ghost_config: ecs.entity.GhostCreator.Config = .{
    .find_path_chance = 0.98,
    .find_path_period_s = 0.2,
    .move_speed = 3.4,
    .sprite_fps = 20,
};

pub fn main() !void {
    try sdl.initSubSystem(c.SDL_INIT_VIDEO);
    defer c.SDL_Quit();
    defer c.SDL_QuitSubSystem(c.SDL_INIT_VIDEO);
    const sdl_window = try sdl.createWindow(window_title, initial_window_size, c.SDL_WINDOW_RESIZABLE);
    defer c.SDL_DestroyWindow(sdl_window);
    const sdl_renderer = try sdl.createRenderer(sdl_window, null);
    defer c.SDL_DestroyRenderer(sdl_renderer);
    try sdl.ttf.init();
    defer c.TTF_Quit();

    var gpa_state = std.heap.DebugAllocator(.{}).init;
    defer if (gpa_state.deinit() == .leak) @panic("Memory leak detected");
    const allocator = gpa_state.allocator();

    const pellet_texture = try asset_loader.loadSdlTexture(sdl_renderer, "resources/pellet.png", .nearest);
    defer c.SDL_DestroyTexture(pellet_texture);

    const wall_texture = try asset_loader.loadSdlTexture(sdl_renderer, "resources/wall/wall.png", .nearest);
    defer c.SDL_DestroyTexture(wall_texture);

    const grass_texture = try asset_loader.loadSdlTexture(sdl_renderer, "resources/grass/grass.png", .nearest);
    defer c.SDL_DestroyTexture(grass_texture);

    while (true) {
        var reg = entt.Registry.init(allocator);
        defer reg.deinit();

        const pacman = ecs.entity.Pacman.init(&reg);
        const grid = ecs.entity.Grid.init(&reg);

        var fast_stupid_ghost_creator: ecs.entity.GhostCreator = try .init(
            &reg,
            sdl_renderer,
            allocator,
            grid,
            pacman,
            "resources/ghosts/fast_stupid_ghost-move.png",
            fast_stupid_ghost_config,
        );
        defer fast_stupid_ghost_creator.deinit();

        var kinda_smart_ghost_creator: ecs.entity.GhostCreator = try .init(
            &reg,
            sdl_renderer,
            allocator,
            grid,
            pacman,
            "resources/ghosts/kinda_smart_ghost-move.png",
            kinda_smart_ghost_config,
        );
        defer kinda_smart_ghost_creator.deinit();

        var fat_genious_ghost_creator: ecs.entity.GhostCreator = try .init(
            &reg,
            sdl_renderer,
            allocator,
            grid,
            pacman,
            "resources/ghosts/fat_genious_ghost-move.png",
            fat_genious_ghost_config,
        );
        defer fat_genious_ghost_creator.deinit();

        const delta_time = try ecs.entity.DeltaTime.init(&reg);
        const events_holder = reg.create();
        _ = ecs.entity.OneGhostOnGridSpawner.init(&reg, try .init(fast_stupid_ghost_creator.entityCreator(), ghost1_spawn_delay_s), grid);
        _ = ecs.entity.OneGhostOnGridSpawner.init(&reg, try .init(kinda_smart_ghost_creator.entityCreator(), ghost2_spawn_delay_s), grid);
        _ = ecs.entity.OneGhostOnGridSpawner.init(&reg, try .init(fat_genious_ghost_creator.entityCreator(), ghost3_spawn_delay_s), grid);
        _ = ecs.entity.Background.init(&reg, grid, wall_texture, .up);
        _ = ecs.entity.Background.init(&reg, grid, wall_texture, .down);
        _ = ecs.entity.Background.init(&reg, grid, wall_texture, .left);
        _ = ecs.entity.Background.init(&reg, grid, wall_texture, .right);

        const level_loader = try ecs.system.LevelLoader.init(allocator, &reg, "resources/level.txt", grid, pacman);
        defer level_loader.deinit();

        const player_initializer = try ecs.system.PlayerInitializer.init(&reg, sdl_renderer, pacman, grid);
        defer player_initializer.deinit();

        var game_over_text_creator = try ecs.entity.TextCreator.init(&reg, sdl_renderer, grid, "resources/fonts/yoster.ttf", 60);
        defer game_over_text_creator.deinit();

        var fps_limiter = try FpsLimiter.init(60);

        var is_paused_on_game_over: bool = false;

        const window_size: Vec2(f32) = (try sdl.getWindowSize(sdl_window)).floatFromInt(f32);
        ecs.system.palcer_in_window_center.init(&reg, window_size);
        ecs.system.background_scaler.init(&reg, window_size);

        while (true) {
            ecs.system.sdl_events_handler.update(&reg, events_holder);
            ecs.system.delta_time_counter.update(&reg, events_holder, delta_time);
            ecs.system.player_input_handler.update(&reg, events_holder, pacman);

            if (reg.has(ecs.component.PlayerRequestedRestartEvent, events_holder)) break;

            if (!is_paused_on_game_over) {
                try ecs.system.enemy_spawning.update(&reg, allocator, pacman);
                try ecs.system.ghost_ai.update(&reg, allocator, pacman);
                ecs.system.movement_on_grid.update(&reg, events_holder);
                ecs.system.turning_on_grid.update(&reg);
                ecs.system.colliding_on_grid.update(&reg);
                ecs.system.pellets_eating.update(&reg, events_holder);
                ecs.system.killing.update(&reg);
                try ecs.system.game_over.update(&reg, delta_time, &game_over_text_creator, &is_paused_on_game_over);
            }

            if (reg.has(ecs.component.QuitEvent, events_holder)) return;

            ecs.system.palcer_in_window_center.update(&reg, events_holder);
            ecs.system.scaler_to_grid.update(&reg);
            ecs.system.background_scaler.update(&reg, events_holder);
            try ecs.system.text_within_grid.update(&reg);
            try ecs.system.movement_animator.update(&reg, events_holder);

            try sdl.renderClear(sdl_renderer);
            try ecs.system.background_renderer.update(&reg, sdl_renderer);
            try ecs.system.debug_grid_renderer.update(&reg, sdl_renderer);
            try ecs.system.level_renderer.update(&reg, sdl_renderer, wall_texture, pellet_texture, grass_texture);
            try ecs.system.movement_animation_renderer.update(&reg, sdl_renderer);
            try ecs.system.texture_renderer.update(&reg, sdl_renderer);
            try ecs.system.text_rendering.update(&reg, sdl_renderer);
            try sdl.renderPresent(sdl_renderer);

            fps_limiter.waitFrameEnd();
        }
    }
}
