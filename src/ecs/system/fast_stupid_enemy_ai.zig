const std = @import("std");
const component = @import("../component.zig");
const Direction = @import("../../Direction.zig").Direction;
const entt = @import("entt");

pub fn update(reg: *entt.Registry) void {
    var view = reg.view(.{
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
