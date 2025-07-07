const Direction = @import("../../direction.zig").Direction;
const component = @import("../component.zig");
const entt = @import("entt");
const PlayerInputHandler = @This();

reg: *entt.Registry,

pub fn update(self: PlayerInputHandler, direction: Direction) void {
    var view = self.reg.view(.{
        component.PacmanTag,
        component.MovableOnGrid,
    }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const movable_on_grid = view.get(component.MovableOnGrid, entity);
        movable_on_grid.direction = direction;
    }
}
