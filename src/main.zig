const std = @import("std");
const log = std.log;
const Window = @import("Window.zig");
const c = @cImport({
    @cInclude("SDL3/SDL_init.h");
});

const window_name = "Pacman";

pub fn main() !void {
    try initSdl();
    defer deinitSdl();

    const window = try Window.init(window_name, 600, 400, 0);
    defer window.deinit();

    while (true) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event)) {
            switch (event.type) {
                c.SDL_EVENT_WINDOW_CLOSE_REQUESTED => return,
                else => {},
            }
        }
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
