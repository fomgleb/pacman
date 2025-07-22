const std = @import("std");
const component = @import("../component.zig");
const Direction = @import("../../Direction.zig").Direction;
const System = @import("../../System.zig");
const entt = @import("entt");

reg: *entt.Registry,

pub fn update(self: *const @This()) void {
    var view = self.reg.view(.{
        component.EnemyTag,
        component.FastStupidEnemyAi,
        component.MovableOnGrid,
    }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const has_fast_stupid_enemy_ai = view.get(component.FastStupidEnemyAi, entity);
        if (has_fast_stupid_enemy_ai.timer.read() < has_fast_stupid_enemy_ai.change_move_direction_delay) continue;
        const movable_on_grid = view.get(component.MovableOnGrid, entity);

        movable_on_grid.requested_direction = std.crypto.random.enumValue(Direction);
        has_fast_stupid_enemy_ai.timer.reset();
    }
}

pub fn system(self: *const @This()) System {
    return System.init(self);
}
