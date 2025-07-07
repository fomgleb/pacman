const std = @import("std");
const log = std.log;
const Timer = std.time.Timer;
const Renderable = @import("Renderable.zig");
const FpsLimiter = @import("FpsLimiter.zig");
const Point = @import("point.zig").Point;
const LevelArea = @import("LevelArea.zig");
const Grid = @import("Grid.zig");
const ecs = @import("ecs.zig");
const sdl = @import("sdl.zig");
const c = @import("c.zig");
const entt = @import("entt");

const window_title = "Pacman";
const initial_window_size = Point(u32){ .x = 600, .y = 400 };
const level_aspect_ratio = Point(u8){ .x = 2, .y = 1 };
const grid_size = Point(u16){ .x = 20, .y = 10 };

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

    var level_area = LevelArea.init(sdl_renderer, level_aspect_ratio, initial_window_size);
    var grid = Grid.init(sdl_renderer, level_area.render_area, grid_size);

    const texture_renderer = ecs.system.TextureRenderer{ .reg = &reg };
    const scaler_to_grid = ecs.system.ScalerToGrid{ .reg = &reg, .grid = &grid };
    const movement_on_grid = ecs.system.MovementOnGrid{ .reg = &reg };
    const player_input_handler = ecs.system.PlayerInputHandler{ .reg = &reg };

    var pacman_entity = try ecs.entity.Pacman.init(&reg, sdl_renderer);
    defer pacman_entity.deinit();

    const renderables = [_]Renderable{ level_area.renderable(), grid.renderable() };

    var fps_limiter = try FpsLimiter.init(60);
    var delta_time_counter = try Timer.start();

    while (true) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event)) {
            switch (event.type) {
                c.SDL_EVENT_WINDOW_CLOSE_REQUESTED => return,
                c.SDL_EVENT_KEY_DOWN => {
                    switch (event.key.key) {
                        c.SDLK_UP => player_input_handler.update(.up),
                        c.SDLK_DOWN => player_input_handler.update(.down),
                        c.SDLK_LEFT => player_input_handler.update(.left),
                        c.SDLK_RIGHT => player_input_handler.update(.right),
                        else => {},
                    }
                },
                c.SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED => {
                    const new_window_size = Point(i32){ .x = event.window.data1, .y = event.window.data2 };
                    level_area.scale(new_window_size.intCast(u32));
                    grid.scale(level_area.render_area);
                },
                else => {},
            }
        }

        const delta_time = delta_time_counter.lap();

        movement_on_grid.update(delta_time);
        scaler_to_grid.update();

        try sdl.setRenderDrawColor(sdl_renderer, 0, 0, 0, 255);
        try sdl.renderClear(sdl_renderer);
        for (renderables) |renderable| {
            try renderable.render();
        }
        try texture_renderer.update();
        try sdl.renderPresent(sdl_renderer);

        fps_limiter.waitFrameEnd();
    }
}
