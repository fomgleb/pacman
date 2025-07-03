const std = @import("std");
const Timer = std.time.Timer;
const log = std.log;
const c = @import("c.zig");
const Pacman = @import("Pacman.zig");
const Renderable = @import("Renderable.zig");
const FpsLimiter = @import("FpsLimiter.zig");
const Point = @import("point.zig").Point;

const window_title = "Pacman";
const initial_window_size: Point(comptime_int) = .{ .x = 600, .y = 400 };

pub fn main() !void {
    try initSdl();
    defer deinitSdl();

    const sdlWindow = try initSdlWindow();
    defer c.SDL_DestroyWindow(sdlWindow);

    const sdlRenderer = try initSdlRenderer(sdlWindow);
    defer c.SDL_DestroyRenderer(sdlRenderer);

    var pacman = try Pacman.init(sdlRenderer, "resources/pacman.png");
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

        try sdlRenderClear(sdlRenderer);
        for (renderables) |renderable| {
            try renderable.render();
        }
        try sdlRenderPresent(sdlRenderer);

        pacman.update(delta_time_counter.lap());

        fps_limiter.waitFrameEnd();
    }
}

fn initSdl() error{SdlError}!void {
    if (!c.SDL_InitSubSystem(c.SDL_INIT_VIDEO)) {
        log.err("Failed to SDL_InitSubSystem(SDL_INIT_VIDEO): {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
}

fn deinitSdl() void {
    c.SDL_QuitSubSystem(c.SDL_INIT_VIDEO);
    c.SDL_Quit();
}

fn initSdlWindow() error{SdlError}!*c.SDL_Window {
    return c.SDL_CreateWindow(window_title, initial_window_size.x, initial_window_size.y, c.SDL_WINDOW_RESIZABLE) orelse {
        log.err("Failed to SDL_CreateWindow: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    };
}

fn initSdlRenderer(window: *c.SDL_Window) error{SdlError}!*c.SDL_Renderer {
    return c.SDL_CreateRenderer(window, null) orelse {
        log.err("Failed to SDL_CreateRenderer: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    };
}

fn sdlRenderClear(renderer: *c.SDL_Renderer) error{SdlError}!void {
    if (!c.SDL_RenderClear(renderer)) {
        log.err("Failed to SDL_RenderClear: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
}

fn sdlRenderPresent(renderer: *c.SDL_Renderer) error{SdlError}!void {
    if (!c.SDL_RenderPresent(renderer)) {
        log.err("Failed to SDL_RenderPresent: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
}
