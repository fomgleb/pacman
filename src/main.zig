const std = @import("std");
const log = std.log;
const Window = @import("Window.zig");
const Pacman = @import("Pacman.zig");
const Renderable = @import("Renderable.zig");
const c = @import("c.zig");

const window_name = "Pacman";

pub fn main() !void {
    try initSdl();
    defer deinitSdl();

    var window = try Window.init(window_name, 600, 400, 0);
    defer window.deinit();

    var pacman = try Pacman.init(window.renderer, "resources/pacman.png");
    defer pacman.deinit();

    const renderables = [_]Renderable{pacman.renderable()};

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

        _ = c.SDL_RenderClear(@ptrCast(window.renderer));

        for (renderables) |renderable| {
            try renderable.render();
        }

        _ = c.SDL_RenderPresent(@ptrCast(window.renderer));

        pacman.update();
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
