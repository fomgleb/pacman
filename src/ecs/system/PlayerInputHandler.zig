const Direction = @import("../../direction.zig").Direction;
const component = @import("../component.zig");
const entt = @import("entt");

reg: *entt.Registry,

pub fn setDesiredDirection(self: @This(), direction: Direction) void {
    var view = self.reg.view(.{
        component.PlayerTag,
        component.MovableOnGrid,
    }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const movable_on_grid = view.get(component.MovableOnGrid, entity);
        movable_on_grid.desired_direction = direction;
    }
}
