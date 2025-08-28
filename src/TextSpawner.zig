const component = @import("ecs/component.zig");
const entt = @import("entt");
const game_kit = @import("game_kit");
const Color = game_kit.Color;
const sdl = game_kit.sdl;
const TextSpawner = @This();

reg: *entt.Registry,
renderer: *sdl.Renderer,
grid: entt.Entity,
font: *sdl.ttf.Font,

pub fn init(reg: *entt.Registry, renderer: *sdl.Renderer, grid: entt.Entity, font: *sdl.ttf.Font) TextSpawner {
    return .{
        .reg = reg,
        .renderer = renderer,
        .grid = grid,
        .font = font,
    };
}

/// `height` is relative to level height. The number from 0 to 1.
pub fn spawn(self: *TextSpawner, text: []const u8, color: Color, layout: component.Layout, rel_size: component.RelativeSize) !entt.Entity {
    const text_surface: *sdl.Surface = try sdl.ttf.renderTextBlended(self.font, text, color);
    defer sdl.destroySurface(text_surface);
    const texture: *sdl.Texture = try sdl.createTextureFromSurface(self.renderer, text_surface);
    try sdl.setTextureScaleMode(texture, .nearest);

    const text_entity: entt.Entity = self.reg.create();
    self.reg.add(text_entity, @as(component.Texture, texture));
    self.reg.add(text_entity, @as(component.RenderArea, undefined)); // Is set by some `Scaler` system
    self.reg.add(text_entity, @as(component.RelativeSize, rel_size));
    self.reg.add(text_entity, @as(component.GridMembership, .{ .grid_entity = self.grid }));
    self.reg.add(text_entity, @as(component.Layout, layout));
    return text_entity;
}

pub fn despawn(self: TextSpawner, text: entt.Entity) void {
    sdl.destroyTexture(self.reg.getConst(component.Texture, text));
    self.reg.destroy(text);
}
