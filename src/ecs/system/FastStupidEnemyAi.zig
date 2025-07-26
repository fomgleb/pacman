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
        const brain = view.get(component.FastStupidEnemyAi, entity);
        const movable_on_grid = view.get(component.MovableOnGrid, entity);
        if (movable_on_grid.current_speed != 0 and brain.timer.read() < brain.change_move_direction_delay) continue;

        movable_on_grid.requested_direction = std.crypto.random.enumValue(Direction);
        brain.timer.reset();
    }
}

pub fn system(self: *const @This()) System {
    return System.init(self);
}
