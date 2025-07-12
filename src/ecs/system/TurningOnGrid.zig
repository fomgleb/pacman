const time = @import("std").time;
const component = @import("../component.zig");
const Direction = @import("../../direction.zig").Direction;
const System = @import("../../System.zig");
const Vec2 = @import("../../Vec2.zig").Vec2;
const entt = @import("entt");

reg: *entt.Registry,

pub fn update(self: *const @This()) void {
    var view = self.reg.view(.{
        component.MovableOnGrid,
        component.GridCellPosition,
    }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const movable_on_grid = view.get(component.MovableOnGrid, entity);
        if (movable_on_grid.requested_direction == movable_on_grid.current_direction) continue;
        const grid_cell_position = view.get(component.GridCellPosition, entity);

        if (movable_on_grid.requested_direction.isOppositeOf(movable_on_grid.current_direction)) {
            movable_on_grid.current_direction = movable_on_grid.requested_direction;
            continue;
        }

        const curr_dir = movable_on_grid.current_direction;
        const req_dir = movable_on_grid.requested_direction;
        const curr_pos_f32 = grid_cell_position.current;
        const prev_pos_f32 = grid_cell_position.previous;
        switch (curr_dir) {
            .up, .down => {
                if (req_dir != .left and req_dir != .right) continue;
                const potential_y = if (curr_dir == .up) @floor(prev_pos_f32.y) else @ceil(prev_pos_f32.y);
                const left = if (curr_dir == .up) potential_y - curr_pos_f32.y else curr_pos_f32.y - potential_y;
                if (left < 0) continue;
                const new_x = switch (req_dir) {
                    .left => curr_pos_f32.x - left,
                    .right => curr_pos_f32.x + left,
                    else => unreachable,
                };
                grid_cell_position.current = .{ .x = new_x, .y = potential_y };
            },
            .left, .right => {
                if (req_dir != .up and req_dir != .down) continue;
                const potential_x = if (curr_dir == .left) @floor(prev_pos_f32.x) else @ceil(prev_pos_f32.x);
                const left = if (curr_dir == .left) potential_x - curr_pos_f32.x else curr_pos_f32.x - potential_x;
                if (left < 0) continue;
                const new_y = switch (req_dir) {
                    .up => curr_pos_f32.y - left,
                    .down => curr_pos_f32.y + left,
                    else => unreachable,
                };
                grid_cell_position.current = .{ .x = potential_x, .y = new_y };
            },
        }

        movable_on_grid.current_direction = movable_on_grid.requested_direction;
    }
}

pub fn system(self: *const @This()) System {
    return System.init(self);
}
