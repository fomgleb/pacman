const std = @import("std");
const Timer = std.time.Timer;
const log = std.log;
const c = @import("c.zig");
const Pacman = @import("Pacman.zig");
const Renderable = @import("Renderable.zig");
const FpsLimiter = @import("FpsLimiter.zig");
const Point = @import("point.zig").Point;
const sdl = @import("sdl.zig");

const window_title = "Pacman";
const initial_window_size = Point(u32){ .x = 600, .y = 400 };

pub fn main() !void {
    try sdl.initSubSystem(c.SDL_INIT_VIDEO);
    defer c.SDL_Quit();
    defer c.SDL_QuitSubSystem(c.SDL_INIT_VIDEO);

    const sdl_window = try sdl.createWindow(window_title, initial_window_size, c.SDL_WINDOW_RESIZABLE);
    defer c.SDL_DestroyWindow(sdl_window);

    const sdl_renderer = try sdl.createRenderer(sdl_window, null);
    defer c.SDL_DestroyRenderer(sdl_renderer);

    var pacman = try Pacman.init(sdl_renderer, "resources/pacman.png");
    defer pacman.deinit();

    const renderables = [_]Renderable{pacman.renderable()};
    var fps_limiter = try FpsLimiter.init(60);
    var delta_time_counter = try Timer.start();

    while (true) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event)) {
            switch (event.type) {
                c.SDL_EVENT_WINDOW_CLOSE_REQUESTED => return,
                c.SDL_EVENT_KEY_DOWN => {
                    switch (event.key.key) {
                        c.SDLK_UP => pacman.controller.desired_direction = .up,
                        c.SDLK_DOWN => pacman.controller.desired_direction = .down,
                        c.SDLK_LEFT => pacman.controller.desired_direction = .left,
                        c.SDLK_RIGHT => pacman.controller.desired_direction = .right,
                        else => {},
                    }
                },
                else => {},
            }
        }

        try sdl.setRenderDrawColor(sdl_renderer, 0, 0, 0, 255);
        try sdl.renderClear(sdl_renderer);
        for (renderables) |renderable| {
            try renderable.render();
        }
        try sdl.renderPresent(sdl_renderer);

        pacman.update(delta_time_counter.lap());

        fps_limiter.waitFrameEnd();
    }
}
