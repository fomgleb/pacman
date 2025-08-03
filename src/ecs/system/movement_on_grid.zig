const time = @import("std").time;
const component = @import("../component.zig");
const entt = @import("entt");

pub fn update(reg: *entt.Registry, events_holder: entt.Entity) void {
    const delta_time = reg.getConst(component.DeltaTimeMeasuredEvent, events_holder).value;
    var view = reg.view(.{ component.MovableOnGrid, component.PositionOnGrid }, .{});
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
