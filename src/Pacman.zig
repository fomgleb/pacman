const c = @import("c.zig");
const log = @import("std").log.scoped(.Pacman);
const Renderable = @import("Renderable.zig");
const Pacman = @This();

texture: *c.SDL_Texture,
renderer: *c.SDL_Renderer,

pub fn init(renderer: *c.SDL_Renderer, texture_path: [*:0]const u8) error{SdlError}!Pacman {
    const texture: *c.SDL_Texture = c.IMG_LoadTexture(renderer, texture_path) orelse {
        log.err("Failed to IMG_LoadTexture: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    };
    if (!c.SDL_SetTextureScaleMode(texture, c.SDL_SCALEMODE_NEAREST)) {
        log.err("Failed to SDL_SetTextureScaleMode: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }

    return Pacman{
        .texture = texture,
        .renderer = renderer,
    };
}

pub fn deinit(self: Pacman) void {
    c.SDL_DestroyTexture(self.texture);
}

pub fn renderable(self: *const Pacman) Renderable {
    return Renderable.init(self);
}

pub fn render(self: *const Pacman) error{SdlError}!void {
    const rectangle = c.SDL_FRect{
        .x = 100,
        .y = 100,
        .w = @floatFromInt(self.texture.w * 5),
        .h = @floatFromInt(self.texture.h * 5),
    };

    if (!c.SDL_RenderTexture(self.renderer, self.texture, null, &rectangle)) {
        log.err("Failed to SDL_RenderTexture: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
}
