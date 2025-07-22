const std = @import("std");
const c = @import("c.zig");
const ecs = @import("ecs.zig");
const sdl = @import("sdl.zig");
const System = @import("System.zig");
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
    var reg = entt.Registry.init(std.heap.smp_allocator);
    defer reg.deinit();

    const pellet_texture = try sdl.loadTexture(sdl_renderer, "resources/pellet.png");
    try sdl.setTextureScaleMode(pellet_texture, .nearest);
    defer c.SDL_DestroyTexture(pellet_texture);

    const fps = try ecs.entity.Fps.init(&reg);
    const delta_time = try ecs.entity.DeltaTime.init(&reg);
    const events_holder = reg.create();
    const grid = ecs.entity.Grid.init(&reg);
    const pacman = ecs.entity.Pacman.init(&reg);
    _ = ecs.entity.OneEnemyOnGridSpawner.init(&reg, try .init(enemy_spawn_delay_s), grid);

    const level_loader = try ecs.system.LevelLoader.init(std.heap.smp_allocator, &reg, "resources/level.txt", grid, pacman);
    defer level_loader.deinit();

    const player_initializer = try ecs.system.PlayerInitializer.init(&reg, sdl_renderer, pacman, grid);
    defer player_initializer.deinit();

    const fast_stupid_enemy_creator = try ecs.entity.FastStupidEnemyCreator.init(sdl_renderer);
    defer fast_stupid_enemy_creator.deinit();

    const systems = [_]System{
        (ecs.system.SdlEventsHandler{ .reg = &reg, .events_holder = events_holder }).system(),
        (ecs.system.DeltaTimeCounter{ .reg = &reg, .events_holder = events_holder, .delta_time = delta_time }).system(),
        (ecs.system.PlayerInputHandler{ .reg = &reg, .events_holder = events_holder, .pacman = pacman }).system(),

        ecs.system.EnemySpawning.init(&reg, sdl_renderer, pacman, fast_stupid_enemy_creator).system(),
        (ecs.system.FastStupidEnemyAi{ .reg = &reg }).system(),
        (ecs.system.MovementOnGrid{ .reg = &reg, .events_holder = events_holder }).system(),
        (ecs.system.TurningOnGrid{ .reg = &reg }).system(),
        (ecs.system.CollidingOnGrid{ .reg = &reg }).system(),
        (ecs.system.PelletsEating{ .reg = &reg, .events_holder = events_holder }).system(),

        (ecs.system.PlacerInWindowCenter{ .reg = &reg, .events_holder = events_holder }).system(),
        (ecs.system.ScalerToGrid{ .reg = &reg }).system(),
        (ecs.system.MovementAnimator{ .reg = &reg, .renderer = sdl_renderer, .events_holder = events_holder }).system(),

        (ecs.system.BackgroundRenderer{ .reg = &reg, .renderer = sdl_renderer }).system(),
        (ecs.system.DebugGridRenderer{ .reg = &reg, .renderer = sdl_renderer }).system(),
        (ecs.system.LevelRenderer{ .reg = &reg, .renderer = sdl_renderer, .pellet_texture = pellet_texture }).system(),
        (ecs.system.MovementAnimationRenderer{ .reg = &reg, .renderer = sdl_renderer }).system(),
        (ecs.system.TextureRenderer{ .reg = &reg }).system(),
        (ecs.system.RenderPresent{ .renderer = sdl_renderer }).system(),

        (ecs.system.FpsLimiter.init(&reg, fps, 60)).system(),
    };

    while (!reg.has(ecs.component.QuitEvent, events_holder))
        for (systems) |system|
            try system.update();
}
