const time = @import("std").time;
const component = @import("../component.zig");
const entt = @import("entt");
const ScalerToGrid = @This();

reg: *entt.Registry,

pub fn update(self: ScalerToGrid, delta_time: u64) void {
    var view = self.reg.view(.{
        component.MovableOnGrid,
        component.PositionOnGrid,
    }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const movable_on_grid = view.getConst(component.MovableOnGrid, entity);
        const position_on_grid = view.get(component.PositionOnGrid, entity);

        const delta_time_f32_s = @as(f32, @floatFromInt(delta_time)) / time.ns_per_s;
        const step = movable_on_grid.speed * delta_time_f32_s;
        switch (movable_on_grid.direction) {
            .up => position_on_grid.y -= step,
            .down => position_on_grid.y += step,
            .left => position_on_grid.x -= step,
            .right => position_on_grid.x += step,
        }
    }
}
