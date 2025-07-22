const time = @import("std").time;
const component = @import("../component.zig");
const System = @import("../../System.zig");
const entt = @import("entt");

reg: *entt.Registry,
events_holder: entt.Entity,

pub fn update(self: *const @This()) void {
    const delta_time = self.reg.getConst(component.DeltaTimeMeasuredEvent, self.events_holder).value;
    var view = self.reg.view(.{ component.MovableOnGrid, component.PositionOnGrid }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const movable_on_grid = view.get(component.MovableOnGrid, entity);
        const position_on_grid = view.get(component.PositionOnGrid, entity);

        movable_on_grid.current_speed = movable_on_grid.requested_speed;
        position_on_grid.previous = position_on_grid.current;

        const delta_time_f32_s = @as(f32, @floatFromInt(delta_time)) / time.ns_per_s;
        const step = movable_on_grid.current_speed * delta_time_f32_s;
        switch (movable_on_grid.current_direction) {
            .up => position_on_grid.current.y -= step,
            .down => position_on_grid.current.y += step,
            .left => position_on_grid.current.x -= step,
            .right => position_on_grid.current.x += step,
        }
    }
}

pub fn system(self: *const @This()) System {
    return System.init(self);
}
