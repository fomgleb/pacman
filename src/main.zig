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
const enemy_spawn_delay_s = 5;

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

        const delta_time = try ecs.entity.DeltaTime.init(&reg);
        const events_holder = reg.create();
        const grid = ecs.entity.Grid.init(&reg);
        const pacman = ecs.entity.Pacman.init(&reg);
        _ = ecs.entity.OneEnemyOnGridSpawner.init(&reg, try .init(enemy_spawn_delay_s), grid);
        _ = ecs.entity.Background.init(&reg, grid, wall_texture, .up);
        _ = ecs.entity.Background.init(&reg, grid, wall_texture, .down);
        _ = ecs.entity.Background.init(&reg, grid, wall_texture, .left);
        _ = ecs.entity.Background.init(&reg, grid, wall_texture, .right);

        const level_loader = try ecs.system.LevelLoader.init(allocator, &reg, "resources/level.txt", grid, pacman);
        defer level_loader.deinit();

        const player_initializer = try ecs.system.PlayerInitializer.init(&reg, sdl_renderer, pacman, grid);
        defer player_initializer.deinit();

        var fast_stupid_enemy_creator = try ecs.entity.FastStupidEnemyCreator.init(sdl_renderer, allocator, pacman);
        defer fast_stupid_enemy_creator.deinit();

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
                try ecs.system.enemy_spawning.update(&reg, pacman, fast_stupid_enemy_creator);
                ecs.system.fast_stupid_enemy_ai.update(&reg);
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
