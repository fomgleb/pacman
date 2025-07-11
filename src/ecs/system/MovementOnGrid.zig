const time = @import("std").time;
const component = @import("../component.zig");
const System = @import("../../System.zig");
const entt = @import("entt");

reg: *entt.Registry,
events_holder_entity: entt.Entity,

pub fn update(self: *const @This()) void {
    const delta_time = self.reg.getConst(component.DeltaTimeMeasuredEvent, self.events_holder_entity).value;
    var view = self.reg.view(.{
        component.MovableOnGrid,
        component.GridCellPosition,
    }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const movable_on_grid = view.getConst(component.MovableOnGrid, entity);
        const grid_cell_position = view.get(component.GridCellPosition, entity);

        grid_cell_position.previous = grid_cell_position.current;

        const delta_time_f32_s = @as(f32, @floatFromInt(delta_time)) / time.ns_per_s;
        const step = movable_on_grid.speed * delta_time_f32_s;
        switch (movable_on_grid.real_direction) {
            .up => grid_cell_position.current.y -= step,
            .down => grid_cell_position.current.y += step,
            .left => grid_cell_position.current.x -= step,
            .right => grid_cell_position.current.x += step,
        }
    }
}

pub fn system(self: *const @This()) System {
    return System.init(self);
}
