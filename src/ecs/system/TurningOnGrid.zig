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

        const result = getTurningPositionAndLeft(
            movable_on_grid.current_direction,
            movable_on_grid.requested_direction,
            grid_cell_position.previous,
            grid_cell_position.current,
        ) orelse continue;

        movable_on_grid.current_direction = movable_on_grid.requested_direction;
        grid_cell_position.current = result.new_position;
    }
}

pub fn system(self: *const @This()) System {
    return System.init(self);
}

fn getTurningPositionAndLeft(
    current_dir: Direction,
    requested_dir: Direction,
    prev_pos: Vec2(f32),
    curr_pos: Vec2(f32),
) ?struct { new_position: Vec2(f32), left: f32 } {
    switch (current_dir) {
        .up, .down => {
            if (requested_dir != .left and requested_dir != .right) return null;

            const potential_y = if (current_dir == .up) @floor(prev_pos.y) else @ceil(prev_pos.y);
            const left = if (current_dir == .up)
                potential_y - curr_pos.y
            else
                curr_pos.y - potential_y;

            if (left < 0) return null;

            const new_x = switch (requested_dir) {
                .left => curr_pos.x - left,
                .right => curr_pos.x + left,
                else => unreachable,
            };

            return .{
                .new_position = .{ .x = new_x, .y = potential_y },
                .left = left,
            };
        },
        .left, .right => {
            if (requested_dir != .up and requested_dir != .down) return null;

            const potential_x = if (current_dir == .left) @floor(prev_pos.x) else @ceil(prev_pos.x);
            const left = if (current_dir == .left)
                potential_x - curr_pos.x
            else
                curr_pos.x - potential_x;

            if (left < 0) return null;

            const new_y = switch (requested_dir) {
                .up => curr_pos.y - left,
                .down => curr_pos.y + left,
                else => unreachable,
            };

            return .{
                .new_position = .{ .x = potential_x, .y = new_y },
                .left = left,
            };
        },
    }
}
