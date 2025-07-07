const c = @import("c.zig");
const log = @import("std").log.scoped(.sdl);
const Point = @import("point.zig").Point;
const Rect = @import("rect.zig").Rect;

pub fn initSubSystem(flags: c.SDL_InitFlags) error{SdlError}!void {
    if (!c.SDL_InitSubSystem(flags)) {
        log.err("Failed to SDL_InitSubSystem: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
}

pub fn createWindow(title: [*:0]const u8, size: Point(u32), flags: c.SDL_WindowFlags) error{SdlError}!*c.SDL_Window {
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

pub fn loadTexture(renderer: *c.SDL_Renderer, file: [*:0]const u8) error{SdlError}!*c.SDL_Texture {
    return c.IMG_LoadTexture(renderer, file) orelse {
        log.err("Failed to IMG_LoadTexture: {s}", .{c.SDL_GetError()});
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
