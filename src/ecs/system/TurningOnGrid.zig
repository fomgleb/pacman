const Vec2 = @import("../../Vec2.zig").Vec2;
const Direction = @import("../../direction.zig").Direction;
const time = @import("std").time;
const component = @import("../component.zig");
const entt = @import("entt");

reg: *entt.Registry,

pub fn update(self: @This()) void {
    var view = self.reg.view(.{
        component.MovableOnGrid,
        component.GridCellPosition,
    }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const movable_on_grid = view.get(component.MovableOnGrid, entity);
        if (movable_on_grid.desired_direction == movable_on_grid.real_direction) continue;
        const grid_cell_position = view.get(component.GridCellPosition, entity);

        if (movable_on_grid.desired_direction.isOppositeOf(movable_on_grid.real_direction)) {
            movable_on_grid.real_direction = movable_on_grid.desired_direction;
            continue;
        }

        const result = getTurningPositionAndLeft(
            movable_on_grid.real_direction,
            movable_on_grid.desired_direction,
            grid_cell_position.previous,
            grid_cell_position.current,
        ) orelse continue;

        movable_on_grid.real_direction = movable_on_grid.desired_direction;
        grid_cell_position.current = result.new_position;
    }
}

fn getTurningPositionAndLeft(
    real_dir: Direction,
    desired_dir: Direction,
    prev_pos: Vec2(f32),
    curr_pos: Vec2(f32),
) ?struct { new_position: Vec2(f32), left: f32 } {
    switch (real_dir) {
        .up, .down => {
            if (desired_dir != .left and desired_dir != .right) return null;

            const potential_y = if (real_dir == .up) @floor(prev_pos.y) else @ceil(prev_pos.y);
            const left = if (real_dir == .up)
                potential_y - curr_pos.y
            else
                curr_pos.y - potential_y;

            if (left < 0) return null;

            const new_x = switch (desired_dir) {
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
            if (desired_dir != .up and desired_dir != .down) return null;

            const potential_x = if (real_dir == .left) @floor(prev_pos.x) else @ceil(prev_pos.x);
            const left = if (real_dir == .left)
                potential_x - curr_pos.x
            else
                curr_pos.x - potential_x;

            if (left < 0) return null;

            const new_y = switch (desired_dir) {
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
