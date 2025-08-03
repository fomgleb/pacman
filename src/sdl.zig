const Color = @import("Color.zig");
const c = @import("c.zig");
const log = @import("std").log.scoped(.sdl);
const Vec2 = @import("Vec2.zig").Vec2;
const Rect = @import("Rect.zig").Rect;

pub fn initSubSystem(flags: c.SDL_InitFlags) error{SdlError}!void {
    if (!c.SDL_InitSubSystem(flags)) {
        log.err("Failed to SDL_InitSubSystem: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
}

pub fn createWindow(title: [*:0]const u8, size: Vec2(u32), flags: c.SDL_WindowFlags) error{SdlError}!*c.SDL_Window {
    return c.SDL_CreateWindow(title, @intCast(size.x), @intCast(size.y), flags) orelse {
        log.err("Failed to SDL_CreateWindow: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    };
}

pub fn createRenderer(window: *c.SDL_Window, name: ?[*:0]const u8) error{SdlError}!*c.SDL_Renderer {
    return c.SDL_CreateRenderer(window, name) orelse {
        log.err("Failed to SDL_CreateRenderer: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    };
}

pub fn renderClear(renderer: *c.SDL_Renderer) error{SdlError}!void {
    if (!c.SDL_RenderClear(renderer)) {
        log.err("Failed to SDL_RenderClear: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
}

pub fn renderPresent(renderer: *c.SDL_Renderer) error{SdlError}!void {
    if (!c.SDL_RenderPresent(renderer)) {
        log.err("Failed to SDL_RenderPresent: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
}

pub fn setRenderDrawColor(renderer: *c.SDL_Renderer, r: u8, g: u8, b: u8, a: u8) error{SdlError}!void {
    if (!c.SDL_SetRenderDrawColor(renderer, r, g, b, a)) {
        log.err("Failed to SDL_SetRenderDrawColor: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
}

pub fn renderFillRect(renderer: *c.SDL_Renderer, rect: Rect(f32)) error{SdlError}!void {
    if (!c.SDL_RenderFillRect(renderer, &.{
        .x = rect.position.x,
        .y = rect.position.y,
        .w = rect.size.x,
        .h = rect.size.y,
    })) {
        log.err("Failed to SDL_SetRenderDrawColor: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
}

pub fn getRendererFromTexture(texture: *c.SDL_Texture) !*c.SDL_Renderer {
    return c.SDL_GetRendererFromTexture(texture) orelse {
        log.err("Failed to SDL_GetRendererFromTexture: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    };
}

pub fn renderTexture(
    renderer: *c.SDL_Renderer,
    texture: *c.SDL_Texture,
    srcrect: ?Rect(f32),
    dstrect: ?Rect(f32),
) !void {
    if (!c.SDL_RenderTexture(
        renderer,
        texture,
        if (srcrect) |r| &c.SDL_FRect{ .x = r.position.x, .y = r.position.y, .w = r.size.x, .h = r.size.y } else null,
        if (dstrect) |r| &c.SDL_FRect{ .x = r.position.x, .y = r.position.y, .w = r.size.x, .h = r.size.y } else null,
    )) {
        log.err("Failed to SDL_RenderTexture: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
}

pub const Flip = enum { none, horizontal, vertical };

pub fn renderTextureRotated(
    renderer: *c.SDL_Renderer,
    texture: *c.SDL_Texture,
    srcrect: ?Rect(f32),
    dstrect: ?Rect(f32),
    angle: f64,
    center: ?Vec2(f32),
    flip: Flip,
) !void {
    if (!c.SDL_RenderTextureRotated(
        renderer,
        texture,
        if (srcrect) |r| &.{ .x = r.position.x, .y = r.position.y, .w = r.size.x, .h = r.size.y } else null,
        if (dstrect) |r| &.{ .x = r.position.x, .y = r.position.y, .w = r.size.x, .h = r.size.y } else null,
        angle,
        if (center) |c_vec| &.{ .x = c_vec.x, .y = c_vec.y } else null,
        switch (flip) {
            .none => c.SDL_FLIP_NONE,
            .horizontal => c.SDL_FLIP_HORIZONTAL,
            .vertical => c.SDL_FLIP_VERTICAL,
        },
    )) {
        log.err("Failed to SDL_RenderTexture: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
}

pub fn loadTexture(renderer: *c.SDL_Renderer, file: [*:0]const u8) error{SdlError}!*c.SDL_Texture {
    return c.IMG_LoadTexture(renderer, file) orelse {
        log.err("Failed to IMG_LoadTexture: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    };
}

pub fn loadTextureIo(renderer: *c.SDL_Renderer, src: *c.SDL_IOStream, closeio: bool) error{SdlError}!*c.SDL_Texture {
    return c.IMG_LoadTexture_IO(renderer, src, closeio) orelse {
        log.err("Failed to IMG_LoadTexture_IO: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    };
}

pub fn setTextureScaleMode(texture: *c.SDL_Texture, scale_mode: enum { nearest, linear }) error{SdlError}!void {
    const c_scale_mode = switch (scale_mode) {
        .nearest => c.SDL_SCALEMODE_NEAREST,
        .linear => c.SDL_SCALEMODE_LINEAR,
    };
    if (!c.SDL_SetTextureScaleMode(texture, c_scale_mode)) {
        log.err("Failed to SDL_SetTextureScaleMode: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
}

pub fn getTextureSize(texture: *c.SDL_Texture) error{SdlError}!Vec2(f32) {
    var width: f32 = 0;
    var height: f32 = 0;
    if (!c.SDL_GetTextureSize(texture, &width, &height)) {
        log.err("Failed to SDL_SetTextureScaleMode: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
    return Vec2(f32).init(width, height);
}

pub fn hasRectIntersectionFloat(a: Rect(f32), b: Rect(f32)) bool {
    return c.SDL_HasRectIntersectionFloat(
        &.{ .x = a.position.x, .y = a.position.y, .w = a.size.x, .h = a.size.y },
        &.{ .x = b.position.x, .y = b.position.y, .w = b.size.x, .h = b.size.y },
    );
}

pub fn createTextureFromSurface(renderer: *c.SDL_Renderer, surface: *c.SDL_Surface) error{SdlError}!*c.SDL_Texture {
    return c.SDL_CreateTextureFromSurface(renderer, surface) orelse {
        log.err("Failed to SDL_CreateTextureFromSurface: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    };
}

pub fn ioFromConstMem(mem: []const u8) error{SdlError}!*c.SDL_IOStream {
    return c.SDL_IOFromConstMem(mem.ptr, mem.len) orelse {
        log.err("Failed to SDL_IOFromConstMem: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    };
}

pub fn ioFromFile(path: [*:0]const u8, mode: [*:0]const u8) error{SdlError}!*c.SDL_IOStream {
    return c.SDL_IOFromFile(path, mode) orelse {
        log.err("Failed to SDL_IOFromFile: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    };
}

pub fn closeIO(io_stream: *c.SDL_IOStream) error{SdlError}!void {
    if (!c.SDL_CloseIO(io_stream)) {
        log.err("Failed to SDL_CloseIO: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
}

pub fn getWindowSize(window: *c.SDL_Window) error{SdlError}!Vec2(u32) {
    var window_size: Vec2(c_int) = undefined;
    if (!c.SDL_GetWindowSize(window, &window_size.x, &window_size.y)) {
        log.err("Failed to SDL_GetWindowSize: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
    return window_size.intCast(u32);
}

pub const ttf = struct {
    pub fn init() error{SdlError}!void {
        if (!c.TTF_Init()) {
            log.err("Failed to TTF_Init: {s}", .{c.SDL_GetError()});
            return error.SdlError;
        }
    }

    pub fn openFont(file: [*:0]const u8, ptsize: f32) error{SdlError}!*c.TTF_Font {
        return c.TTF_OpenFont(file, ptsize) orelse {
            log.err("Failed to TTF_OpenFont: {s}", .{c.SDL_GetError()});
            return error.SdlError;
        };
    }

    pub fn openFontIo(src: *c.SDL_IOStream, closeio: bool, ptsize: f32) error{SdlError}!*c.TTF_Font {
        return c.TTF_OpenFontIO(src, closeio, ptsize) orelse {
            log.err("Failed to TTF_OpenFontIO: {s}", .{c.SDL_GetError()});
            return error.SdlError;
        };
    }

    pub fn renderTextBlended(font: *c.TTF_Font, text: []const u8, fg: Color) error{SdlError}!*c.SDL_Surface {
        return c.TTF_RenderText_Blended(font, text.ptr, text.len, .{ .r = fg.r, .g = fg.g, .b = fg.b, .a = fg.a }) orelse {
            log.err("Failed to TTF_RenderText_Blended: {s}", .{c.SDL_GetError()});
            return error.SdlError;
        };
    }
};
