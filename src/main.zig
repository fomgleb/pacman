const std = @import("std");
const c = @import("c.zig");
const ecs = @import("ecs.zig");
const sdl = @import("sdl.zig");
const System = @import("System.zig");
const Vec2 = @import("Vec2.zig").Vec2;
const entt = @import("entt");

const window_title = "Pacman";
const initial_window_size = Vec2(u32){ .x = 600, .y = 400 };

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

    const fps_entity = try ecs.entity.Fps.init(&reg);
    const delta_time_entity = try ecs.entity.DeltaTime.init(&reg);
    const events_holder_entity = reg.create();
    const grid_entity = ecs.entity.Grid.init(&reg);
    const pacman = ecs.entity.Pacman.init(&reg);

    const level_loader = try ecs.system.init.LevelLoader.init(std.heap.smp_allocator, &reg, "resources/level.txt", grid_entity);
    defer level_loader.deinit();

    const player_initializer = try ecs.system.PlayerInitializer.init(&reg, sdl_renderer, pacman, grid_entity);
    defer player_initializer.deinit();

    const systems = [_]System{
        (ecs.system.SdlEventsHandler{ .reg = &reg, .events_holder_entity = events_holder_entity }).system(),
        (ecs.system.DeltaTimeCounter{ .reg = &reg, .events_holder_entity = events_holder_entity, .delta_time_entity = delta_time_entity }).system(),
        (ecs.system.PlayerInputHandler{ .reg = &reg, .events_holder_entity = events_holder_entity, .pacman_entity = pacman }).system(),

        (ecs.system.MovementOnGrid{ .reg = &reg, .events_holder_entity = events_holder_entity }).system(),
        (ecs.system.TurningOnGrid{ .reg = &reg }).system(),
        (ecs.system.CollidingOnGrid{ .reg = &reg }).system(),
        (ecs.system.PelletsEating{ .reg = &reg }).system(),

        (ecs.system.PlacerInWindowCenter{ .reg = &reg, .events_holder_entity = events_holder_entity }).system(),
        (ecs.system.GridRenderAreaAligner{ .reg = &reg, .events_holder = events_holder_entity }).system(),
        (ecs.system.ScalerToGrid{ .reg = &reg }).system(),

        (ecs.system.BackgroundRenderer{ .reg = &reg, .renderer = sdl_renderer }).system(),
        (ecs.system.DebugGridRenderer{ .reg = &reg, .renderer = sdl_renderer }).system(),
        (ecs.system.LevelRenderer{ .reg = &reg, .renderer = sdl_renderer, .pellet_texture = pellet_texture }).system(),
        (ecs.system.TextureRenderer{ .reg = &reg }).system(),
        (ecs.system.RenderPresent{ .renderer = sdl_renderer }).system(),

        (ecs.system.FpsLimiter.init(&reg, fps_entity, 60)).system(),
    };

    while (!reg.has(ecs.component.QuitEvent, events_holder_entity))
        for (systems) |system|
            try system.update();
}
