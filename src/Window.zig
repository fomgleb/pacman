const log = @import("std").log.scoped(.Window);
const c = @cImport({
    @cInclude("SDL3/SDL_video.h");
});
const Self = @This();

window: *c.SDL_Window,

pub fn init(title: [*:0]const u8, width: c_int, height: c_int, flags: c.SDL_WindowFlags) error{SdlError}!Self {
    return Self{
        .window = c.SDL_CreateWindow(title, width, height, flags) orelse {
            log.err("Failed to SDL_CreateWindow: {s}", .{c.SDL_GetError()});
            return error.SdlError;
        },
    };
}

pub fn deinit(self: *const Self) void {
    c.SDL_DestroyWindow(self.window);
}
