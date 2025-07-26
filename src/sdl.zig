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

pub fn renderTextureRotated(
    renderer: *c.SDL_Renderer,
    texture: *c.SDL_Texture,
    srcrect: ?Rect(f32),
    dstrect: ?Rect(f32),
    angle: f64,
    center: ?Vec2(f32),
    flip: enum { none, horizontal, vertical },
) !void {
    if (!c.SDL_RenderTextureRotated(
        renderer,
        texture,
        if (srcrect) |r| &c.SDL_FRect{ .x = r.position.x, .y = r.position.y, .w = r.size.x, .h = r.size.y } else null,
        if (dstrect) |r| &c.SDL_FRect{ .x = r.position.x, .y = r.position.y, .w = r.size.x, .h = r.size.y } else null,
        angle,
        if (center) |c_vec| &c.SDL_FPoint{ .x = c_vec.x, .y = c_vec.y } else null,
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
