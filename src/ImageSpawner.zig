const std = @import("std");
const component = @import("ecs/component.zig");
const game_kit = @import("game_kit");
const asset_loader = game_kit.asset_loader;
const sdl = game_kit.sdl;
const entt = @import("entt");
const ImageSpawner = @This();

reg: *entt.Registry,
renderer: *sdl.Renderer,
grid: entt.Entity,
image_textures: std.StringHashMap(*sdl.Texture),

pub fn init(
    reg: *entt.Registry,
    allocator: std.mem.Allocator,
    renderer: *sdl.Renderer,
    comptime images_to_preload: []const [:0]const u8,
    grid: entt.Entity,
) !ImageSpawner {
    var image_textures: std.StringHashMap(*sdl.Texture) = .init(allocator);
    inline for (images_to_preload) |image_to_preload| {
        const texture: *sdl.Texture = try asset_loader.loadTexture(renderer, image_to_preload, .nearest);
        try image_textures.put(image_to_preload, texture);
    }

    return .{
        .reg = reg,
        .renderer = renderer,
        .grid = grid,
        .image_textures = image_textures,
    };
}

pub fn deinit(self: *ImageSpawner) void {
    var iterator = self.image_textures.iterator();
    while (iterator.next()) |image_texture|
        sdl.destroyTexture(image_texture.value_ptr.*);
    self.image_textures.deinit();
}

pub fn spawn(
    self: *ImageSpawner,
    comptime image_path: [:0]const u8,
    layout: component.Layout,
    rel_size: component.RelativeSize,
) !entt.Entity {
    const image_texture: *sdl.Texture = if (self.image_textures.get(image_path)) |texture|
        texture
    else blk: {
        const texture: *sdl.Texture = try asset_loader.loadTexture(self.renderer, image_path, .nearest);
        try self.image_textures.put(image_path, texture);
        break :blk texture;
    };

    const image_entity: entt.Entity = self.reg.create();
    self.reg.add(image_entity, @as(component.Texture, image_texture));
    self.reg.add(image_entity, @as(component.RenderArea, undefined)); // Is set by some `Scaler` system
    self.reg.add(image_entity, @as(component.RelativeSize, rel_size));
    self.reg.add(image_entity, @as(component.GridMembership, .{ .grid_entity = self.grid }));
    self.reg.add(image_entity, @as(component.Layout, layout));
    return image_entity;
}
