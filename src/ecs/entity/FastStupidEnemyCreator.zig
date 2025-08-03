const std = @import("std");
const Allocator = std.mem.Allocator;
const component = @import("../component.zig");
const c = @import("../../c.zig");
const Direction = @import("../../Direction.zig").Direction;
const asset_loader = @import("../../asset_loader.zig");
const sdl = @import("../../sdl.zig");
const Vec2 = @import("../../Vec2.zig").Vec2;
const entt = @import("entt");

const move_sprite_sheet_path = "resources/ghost/ghost-move.png";
const sprite_width = 17;
const sprite_fps = 30;
const sprite_can_rotate = false;

allocator: Allocator,
victims: std.AutoArrayHashMap(entt.Entity, void),
move_sprite_sheet: *c.SDL_Texture,

pub fn init(renderer: *c.SDL_Renderer, allocator: Allocator, pacman: entt.Entity) !@This() {
    const move_sprite_sheet = try asset_loader.loadSdlTexture(renderer, move_sprite_sheet_path, .nearest);

    var victims = std.AutoArrayHashMap(entt.Entity, void).init(allocator);
    try victims.put(pacman, {});

    return .{
        .allocator = allocator,
        .victims = victims,
        .move_sprite_sheet = move_sprite_sheet,
    };
}

pub fn deinit(self: *@This()) void {
    self.victims.deinit();
    c.SDL_DestroyTexture(self.move_sprite_sheet);
}

pub fn create(
    self: @This(),
    reg: *entt.Registry,
    position_on_grid: Vec2(f32),
    movable_on_grid: component.MovableOnGrid,
    grid: entt.Entity,
    change_move_direction_delay_s: f32,
) !entt.Entity {
    const entity = reg.create();

    reg.add(entity, @as(component.EnemyTag, .{}));
    reg.add(entity, @as(component.RenderArea, undefined));
    reg.add(entity, @as(component.PositionOnGrid, .init(position_on_grid)));
    reg.add(entity, @as(component.MovableOnGrid, movable_on_grid));
    reg.add(entity, @as(component.GridMembership, .{ .grid_entity = grid }));
    reg.add(entity, @as(component.MovementAnimation, try .init(self.move_sprite_sheet, sprite_width, sprite_fps, sprite_can_rotate)));
    reg.add(entity, @as(component.FastStupidEnemyAi, try .init(change_move_direction_delay_s)));
    reg.add(entity, @as(component.Killer, .{ .victims = self.victims }));

    return entity;
}
