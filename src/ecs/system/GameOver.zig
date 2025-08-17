const std = @import("std");
const entity = @import("../entity.zig");
const component = @import("../component.zig");
const c = @import("../../c.zig");
const TextSpawner = @import("../../TextSpawner.zig");
const entt = @import("entt");
const GameOver = @This();

reg: *entt.Registry,
text_spawner: TextSpawner,
spawned_texts: std.BoundedArray(entt.Entity, 2) = .{ .len = 0 },

pub fn init(reg: *entt.Registry, renderer: *c.SDL_Renderer, grid: entt.Entity, font: *c.TTF_Font) GameOver {
    return .{
        .reg = reg,
        .text_spawner = .init(reg, renderer, grid, font),
    };
}

pub fn deinit(self: *GameOver) void {
    for (self.spawned_texts.slice()) |spawned_text| {
        self.text_spawner.despawn(spawned_text);
    }
}

pub fn update(self: *GameOver, game_is_paused: *bool) !void {
    var view = self.reg.view(.{ component.PlayerTag, component.DeadTag }, .{});
    if (view.entityIterator().internal_it.slice.len == 0) return;

    try self.spawned_texts.append(try self.text_spawner.spawn(
        "GAME OVER",
        .{ .r = 255, .g = 0, .b = 0, .a = 255 },
        .{ .v = .center, .h = .center },
        .{ .w = null, .h = 0.2 },
    ));

    try self.spawned_texts.append(try self.text_spawner.spawn(
        "Press Space to restart",
        .{ .r = 255, .g = 255, .b = 255, .a = 255 },
        .{ .v = .center, .h = .bottom, .rel_offset = .{ .x = 0, .y = -0.1 } },
        .{ .w = null, .h = 0.09 },
    ));

    game_is_paused.* = true;
}
