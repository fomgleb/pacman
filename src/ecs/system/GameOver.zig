const std = @import("std");
const entity = @import("../entity.zig");
const component = @import("../component.zig");
const TextSpawner = @import("../../TextSpawner.zig");
const sdl = @import("game_kit").sdl;
const entt = @import("entt");
const GameOver = @This();

reg: *entt.Registry,
text_spawner: TextSpawner,
spawned_texts: [2]entt.Entity = undefined,
spawned_texts_len: usize = 0,

pub fn init(reg: *entt.Registry, renderer: *sdl.Renderer, grid: entt.Entity, font: *sdl.ttf.Font) GameOver {
    return .{
        .reg = reg,
        .text_spawner = .init(reg, renderer, grid, font),
    };
}

pub fn deinit(self: *GameOver) void {
    for (0..self.spawned_texts_len) |i| {
        self.text_spawner.despawn(self.spawned_texts[i]);
    }
}

pub fn update(self: *GameOver, game_is_paused: *bool) !void {
    var view = self.reg.view(.{ component.PlayerTag, component.DeadTag }, .{});
    if (view.entityIterator().internal_it.slice.len == 0) return;

    self.spawned_texts[self.spawned_texts_len] = try self.text_spawner.spawn(
        "GAME OVER",
        .{ .r = 255, .g = 0, .b = 0, .a = 255 },
        .{ .v = .center, .h = .center },
        .{ .w = null, .h = 0.2 },
    );
    self.spawned_texts_len += 1;

    self.spawned_texts[self.spawned_texts_len] = try self.text_spawner.spawn(
        "Press Space to restart",
        .{ .r = 255, .g = 255, .b = 255, .a = 255 },
        .{ .v = .center, .h = .bottom, .rel_offset = .{ .x = 0, .y = -0.1 } },
        .{ .w = null, .h = 0.09 },
    );
    self.spawned_texts_len += 1;

    game_is_paused.* = true;
}
