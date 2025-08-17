const std = @import("std");
const entity = @import("../entity.zig");
const component = @import("../component.zig");
const c = @import("../../c.zig");
const ImageSpawner = @import("../../ImageSpawner.zig");
const TextSpawner = @import("../../TextSpawner.zig");

const entt = @import("entt");
const GameWin = @This();

reg: *entt.Registry,
text_spawner: TextSpawner,
image_spawner: ImageSpawner,
spawned_entities: std.BoundedArray(entt.Entity, 2) = .{ .len = 0 },

pub fn init(
    reg: *entt.Registry,
    allocator: std.mem.Allocator,
    renderer: *c.SDL_Renderer,
    grid: entt.Entity,
    font: *c.TTF_Font,
) !GameWin {
    return .{
        .reg = reg,
        .text_spawner = .init(reg, renderer, grid, font),
        .image_spawner = try .init(reg, allocator, renderer, &.{"resources/smile-face.png"}, grid),
    };
}

pub fn deinit(self: *GameWin) void {
    for (self.spawned_entities.slice()) |spawned_entity| {
        self.text_spawner.despawn(spawned_entity);
    }
    self.image_spawner.deinit();
}

pub fn update(self: *GameWin, pacman: entt.Entity, game_is_paused: *bool) !void {
    const pellets_eater: component.PelletsEater = self.reg.getConst(component.PelletsEater, pacman);
    if (pellets_eater.left_pellets_count != 0) return;

    try self.spawned_entities.append(try self.text_spawner.spawn(
        "YOU WIN!",
        .{ .r = 255, .g = 0, .b = 255, .a = 255 },
        .{ .v = .center, .h = .center, .rel_offset = .{ .x = -0.15, .y = 0 } },
        .{ .w = null, .h = 0.2 },
    ));

    try self.spawned_entities.append(try self.image_spawner.spawn(
        "resources/smile-face.png",
        .{ .h = .center, .v = .center, .rel_offset = .{ .x = 0.4, .y = -0.05 } },
        .{ .w = null, .h = 0.3 },
    ));

    game_is_paused.* = true;
}
