const log = @import("std").log.scoped(.Window);
const c = @import("c.zig");
const Window = @This();

window: *c.SDL_Window,
renderer: *c.SDL_Renderer,

pub fn init(title: [*:0]const u8, width: c_int, height: c_int, flags: c.SDL_WindowFlags) error{SdlError}!Window {
    const window = c.SDL_CreateWindow(title, width, height, flags) orelse {
        log.err("Failed to SDL_CreateWindow: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    };
    const renderer = c.SDL_CreateRenderer(window, null) orelse {
        log.err("Failed to SDL_CreateRenderer: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    };

    return Window{
        .window = window,
        .renderer = renderer,
    };
}

pub fn deinit(self: *const Window) void {
    c.SDL_DestroyWindow(self.window);
}
