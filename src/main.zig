const std = @import("std");
const ecs = @import("ecs.zig");
const FpsLimiter = @import("FpsLimiter.zig");
const TextSpawner = @import("TextSpawner.zig");
const entt = @import("entt");
const game_kit = @import("game_kit");
const asset_loader = game_kit.asset_loader;
const sdl = game_kit.sdl;
const Vec2 = game_kit.Vec2;

const window_title = "Pacman";
const initial_window_size = Vec2(u32){ .x = 600, .y = 400 };
const ghost1_spawn_delay_s = 5;
const ghost2_spawn_delay_s = 30;
const ghost3_spawn_delay_s = 60;

const fast_stupid_ghost_config: ecs.entity.GhostCreator.Config = .{
    .find_path_chance = 0.1,
    .ignore_turn_chance = 0.9,
    .find_path_period_s = 1,
    .move_speed = 5.5,
    .sprite_fps = 30,
};

const kinda_smart_ghost_config: ecs.entity.GhostCreator.Config = .{
    .find_path_chance = 0.4,
    .ignore_turn_chance = 0.5,
    .find_path_period_s = 1,
    .move_speed = 4.2,
    .sprite_fps = 25,
};

const fat_genious_ghost_config: ecs.entity.GhostCreator.Config = .{
    .find_path_chance = 0.98,
    .ignore_turn_chance = 0.2,
    .find_path_period_s = 1,
    .move_speed = 3.4,
    .sprite_fps = 20,
};

pub fn main() !void {
    try sdl.initSubSystem(sdl.c.SDL_INIT_VIDEO);
    defer sdl.quit();
    defer sdl.quitSubSystem(sdl.c.SDL_INIT_VIDEO);
    const window: *sdl.Window = try sdl.createWindow(window_title, initial_window_size, sdl.c.SDL_WINDOW_RESIZABLE);
    defer sdl.destroyWindow(window);
    const renderer: *sdl.Renderer = try sdl.createRenderer(window, null);
    defer sdl.destroyRenderer(renderer);
    try sdl.ttf.init();
    defer sdl.ttf.quit();

    var gpa_state = std.heap.DebugAllocator(.{}).init;
    defer if (gpa_state.deinit() == .leak) @panic("Memory leak detected");
    const allocator = gpa_state.allocator();

    const pellet_texture = try asset_loader.loadTexture(renderer, "resources/pellet.png", .nearest);
    defer sdl.destroyTexture(pellet_texture);

    const wall_texture = try asset_loader.loadTexture(renderer, "resources/wall/wall.png", .nearest);
    defer sdl.destroyTexture(wall_texture);

    const grass_texture = try asset_loader.loadTexture(renderer, "resources/grass/grass.png", .nearest);
    defer sdl.destroyTexture(grass_texture);

    while (true) {
        var reg = entt.Registry.init(allocator);
        defer reg.deinit();

        const pacman = ecs.entity.Pacman.init(&reg);
        const grid = ecs.entity.Grid.init(&reg);

        var fast_stupid_ghost_creator: ecs.entity.GhostCreator = try .init(
            &reg,
            renderer,
            allocator,
            grid,
            pacman,
            "resources/ghosts/fast_stupid_ghost-move.png",
            fast_stupid_ghost_config,
        );
        defer fast_stupid_ghost_creator.deinit();

        var kinda_smart_ghost_creator: ecs.entity.GhostCreator = try .init(
            &reg,
            renderer,
            allocator,
            grid,
            pacman,
            "resources/ghosts/kinda_smart_ghost-move.png",
            kinda_smart_ghost_config,
        );
        defer kinda_smart_ghost_creator.deinit();

        var fat_genious_ghost_creator: ecs.entity.GhostCreator = try .init(
            &reg,
            renderer,
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

        const player_initializer = try ecs.system.PlayerInitializer.init(&reg, renderer, pacman, grid);
        defer player_initializer.deinit();

        var fps_limiter = try FpsLimiter.init(60);

        var game_is_paused: bool = false;

        const window_size: Vec2(f32) = (try sdl.getWindowSize(window)).floatFromInt(f32);
        ecs.system.palcer_in_window_center.init(&reg, window_size);
        ecs.system.background_scaler.init(&reg, window_size);

        const yoster_font: *sdl.ttf.Font = try sdl.ttf.openFontIo(try asset_loader.openIoStream("resources/fonts/yoster.ttf"), true, 60);
        defer sdl.ttf.closeFont(yoster_font);

        var game_over: ecs.system.GameOver = .init(&reg, renderer, grid, yoster_font);
        defer game_over.deinit();

        var game_win: ecs.system.GameWin = try .init(&reg, allocator, renderer, grid, yoster_font);
        defer game_win.deinit();

        var profiling_timer: std.time.Timer = try .start();

        while (true) {
            ecs.system.sdl_events_handler.update(&reg, events_holder);
            std.log.debug("sdl_events_handler: {}ms", .{profiling_timer.lap() / std.time.ns_per_ms});
            ecs.system.delta_time_counter.update(&reg, events_holder, delta_time);
            std.log.debug("delta_time_counter: {}ms", .{profiling_timer.lap() / std.time.ns_per_ms});
            ecs.system.player_input_handler.update(&reg, events_holder, pacman);
            std.log.debug("player_input_handler: {}ms", .{profiling_timer.lap() / std.time.ns_per_ms});

            if (reg.has(ecs.component.PlayerRequestedRestartEvent, events_holder)) break;

            if (!game_is_paused) {
                try ecs.system.enemy_spawning.update(&reg, allocator, pacman);
                std.log.debug("enemy_spawning: {}ms", .{profiling_timer.lap() / std.time.ns_per_ms});
                try ecs.system.ghost_ai.update(&reg, allocator, pacman);
                std.log.debug("ghost_ai: {}ms", .{profiling_timer.lap() / std.time.ns_per_ms});
                ecs.system.movement_on_grid.update(&reg, events_holder);
                std.log.debug("movement_on_grid: {}ms", .{profiling_timer.lap() / std.time.ns_per_ms});
                ecs.system.turning_on_grid.update(&reg);
                std.log.debug("turning_on_grid: {}ms", .{profiling_timer.lap() / std.time.ns_per_ms});
                ecs.system.colliding_on_grid.update(&reg);
                std.log.debug("colliding_on_grid: {}ms", .{profiling_timer.lap() / std.time.ns_per_ms});
                ecs.system.pellets_eating.update(&reg);
                std.log.debug("pellets_eating: {}ms", .{profiling_timer.lap() / std.time.ns_per_ms});
                ecs.system.killing.update(&reg);
                std.log.debug("killing: {}ms", .{profiling_timer.lap() / std.time.ns_per_ms});
                try game_over.update(&game_is_paused);
                std.log.debug("game_over: {}ms", .{profiling_timer.lap() / std.time.ns_per_ms});
                try game_win.update(pacman, &game_is_paused);
                std.log.debug("game_win: {}ms", .{profiling_timer.lap() / std.time.ns_per_ms});
                try ecs.system.movement_animator.update(&reg, events_holder);
                std.log.debug("movement_animator: {}ms", .{profiling_timer.lap() / std.time.ns_per_ms});
            }

            if (reg.has(ecs.component.QuitEvent, events_holder)) return;

            ecs.system.palcer_in_window_center.update(&reg, events_holder);
            std.log.debug("palcer_in_window_center: {}ms", .{profiling_timer.lap() / std.time.ns_per_ms});
            ecs.system.scaler_to_grid.update(&reg);
            std.log.debug("scaler_to_grid: {}ms", .{profiling_timer.lap() / std.time.ns_per_ms});
            ecs.system.background_scaler.update(&reg, events_holder);
            std.log.debug("background_scaler: {}ms", .{profiling_timer.lap() / std.time.ns_per_ms});
            try ecs.system.layouted_scaling.update(&reg);
            std.log.debug("layouted_scaling: {}ms", .{profiling_timer.lap() / std.time.ns_per_ms});

            try sdl.renderClear(renderer);
            std.log.debug("sdl.renderClear: {}ms", .{profiling_timer.lap() / std.time.ns_per_ms});
            try ecs.system.background_renderer.update(&reg, renderer);
            std.log.debug("background_renderer: {}ms", .{profiling_timer.lap() / std.time.ns_per_ms});
            try ecs.system.debug_grid_renderer.update(&reg, renderer);
            std.log.debug("debug_grid_renderer: {}ms", .{profiling_timer.lap() / std.time.ns_per_ms});
            try ecs.system.level_renderer.update(&reg, renderer, wall_texture, pellet_texture, grass_texture);
            std.log.debug("level_renderer: {}ms", .{profiling_timer.lap() / std.time.ns_per_ms});
            try ecs.system.movement_animation_renderer.update(&reg, renderer);
            std.log.debug("movement_animation_renderer: {}ms", .{profiling_timer.lap() / std.time.ns_per_ms});
            try ecs.system.texture_renderer.update(&reg, renderer);
            std.log.debug("texture_renderer: {}ms", .{profiling_timer.lap() / std.time.ns_per_ms});
            try ecs.system.text_rendering.update(&reg, renderer);
            std.log.debug("text_rendering: {}ms", .{profiling_timer.lap() / std.time.ns_per_ms});
            try sdl.renderPresent(renderer);
            std.log.debug("sdl.renderPresent: {}ms", .{profiling_timer.lap() / std.time.ns_per_ms});

            fps_limiter.waitFrameEnd();
            std.log.debug("fps_limiter.waitFrameEnd: {}ms", .{profiling_timer.lap() / std.time.ns_per_ms});
        }
    }
}
