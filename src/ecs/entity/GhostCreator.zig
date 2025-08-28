const std = @import("std");
const Allocator = std.mem.Allocator;
const component = @import("../component.zig");
const Direction = @import("../../Direction.zig").Direction;
const EntityCreator = @import("../../EntityCreator.zig");
const entt = @import("entt");
const game_kit = @import("game_kit");
const asset_loader = game_kit.asset_loader;
const sdl = game_kit.sdl;
const Vec2 = game_kit.Vec2;
const EnemyCreator = @This();

const sprite_width = 17;
const sprite_can_rotate = false;

reg: *entt.Registry,
allocator: Allocator,
grid: entt.Entity,
victims: std.AutoArrayHashMap(entt.Entity, void),
move_sprite_sheet: *sdl.Texture,
config: Config,

/// TODO: Use in component.GhostAi.
pub const Config = struct {
    /// A chance of finding the path to the pacman. The number from 0 to 1.
    find_path_chance: f32,
    /// A chance that the ghost will ignore the left or/and right turn. The number from 0 to 1.
    ignore_turn_chance: f32,
    find_path_period_s: f32,
    move_speed: f32,
    sprite_fps: f32,
};

pub fn init(
    reg: *entt.Registry,
    renderer: *sdl.Renderer,
    allocator: Allocator,
    grid: entt.Entity,
    pacman: entt.Entity,
    comptime move_sprite_sheet_path: [:0]const u8,
    config: Config,
) !EnemyCreator {
    const move_sprite_sheet = try asset_loader.loadTexture(
        renderer,
        move_sprite_sheet_path,
        .nearest,
    );

    var victims = std.AutoArrayHashMap(entt.Entity, void).init(allocator);
    try victims.put(pacman, {});

    return .{
        .reg = reg,
        .allocator = allocator,
        .grid = grid,
        .victims = victims,
        .move_sprite_sheet = move_sprite_sheet,
        .config = config,
    };
}

pub fn deinit(self: *EnemyCreator) void {
    self.victims.deinit();
    sdl.destroyTexture(self.move_sprite_sheet);
}

pub fn create(self: *const EnemyCreator) !entt.Entity {
    const entity: entt.Entity = self.reg.create();

    self.reg.add(entity, @as(component.EnemyTag, .{}));
    self.reg.add(entity, @as(component.RenderArea, undefined));
    self.reg.add(entity, @as(component.PositionOnGrid, undefined));
    self.reg.add(entity, @as(component.MovableOnGrid, .init(self.config.move_speed, undefined)));
    self.reg.add(entity, @as(component.GridMembership, .{ .grid_entity = self.grid }));
    self.reg.add(entity, @as(component.MovementAnimation, try .init(self.move_sprite_sheet, sprite_width, self.config.sprite_fps, sprite_can_rotate)));
    self.reg.add(entity, @as(component.GhostAi, try .init(self.config.find_path_period_s, self.config.find_path_chance, self.config.ignore_turn_chance)));
    self.reg.add(entity, @as(component.Killer, .{ .victims = self.victims }));

    return entity;
}

pub fn entityCreator(self: *const EnemyCreator) EntityCreator {
    return EntityCreator.init(self);
}
