const time = @import("std").time;
const component = @import("../component.zig");
const Vec2 = @import("../../Vec2.zig").Vec2;
const entt = @import("entt");

pub fn update(reg: *entt.Registry) void {
    var view = reg.view(.{
        component.MovableOnGrid,
        component.PositionOnGrid,
        component.GridMembership,
    }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const movable_on_grid = view.get(component.MovableOnGrid, entity);
        const position_on_grid = view.get(component.PositionOnGrid, entity);
        const grid_entity = view.getConst(component.GridMembership, entity).grid_entity;
        const grid_cells = reg.getConst(component.GridCells, grid_entity);

        const prev_pos_f32 = position_on_grid.previous;
        const curr_pos_f32 = position_on_grid.current;
        const curr_direction = movable_on_grid.current_direction;
        switch (curr_direction) {
            .up, .down => {
                const collision_y = if (curr_direction == .up) @floor(prev_pos_f32.y) else @ceil(prev_pos_f32.y);
                const next_cell_y: usize = @intFromFloat(if (curr_direction == .up) collision_y - 1 else collision_y + 1);
                if (grid_cells.get(.{ .x = @intFromFloat(curr_pos_f32.x), .y = next_cell_y }) != .wall) continue;
                const offset = if (curr_direction == .up) collision_y - curr_pos_f32.y else curr_pos_f32.y - collision_y;
                if (offset >= 0) {
                    movable_on_grid.current_speed = 0;
                    position_on_grid.current.y = collision_y;
                } else {
                    movable_on_grid.current_speed = movable_on_grid.requested_speed;
                }
            },
            .left, .right => {
                const collision_x = if (curr_direction == .left) @floor(prev_pos_f32.x) else @ceil(prev_pos_f32.x);
                const next_cell_x: usize = @intFromFloat(if (curr_direction == .left) collision_x - 1 else collision_x + 1);
                if (grid_cells.get(.{ .x = next_cell_x, .y = @intFromFloat(curr_pos_f32.y) }) != .wall) continue;
                const offset = if (curr_direction == .left) collision_x - curr_pos_f32.x else curr_pos_f32.x - collision_x;
                if (offset >= 0) {
                    movable_on_grid.current_speed = 0;
                    position_on_grid.current.x = collision_x;
                } else {
                    movable_on_grid.current_speed = movable_on_grid.requested_speed;
                }
            },
        }
    }
}
