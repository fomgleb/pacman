const std = @import("std");
const Allocator = std.mem.Allocator;
const random = std.crypto.random;
const pow = std.math.pow;
const component = @import("../component.zig");
const Direction = @import("../../Direction.zig").Direction;
const rand = @import("../../rand.zig");
const Vec2 = @import("../../Vec2.zig").Vec2;
const entt = @import("entt");

pub fn update(reg: *entt.Registry, allocator: Allocator, pacman: entt.Entity) !void {
    var view = reg.view(.{
        component.EnemyTag,
        component.GhostAi,
        component.MovableOnGrid,
    }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const ghost_ai: *component.GhostAi = view.get(component.GhostAi, entity);
        const movable_on_grid: *component.MovableOnGrid = view.get(component.MovableOnGrid, entity);

        const ghost_pos: Vec2(usize) = roundToDirection(view.getConst(component.PositionOnGrid, entity).current, movable_on_grid.current_direction);
        const grid: entt.Entity = view.getConst(component.GridMembership, entity).grid_entity;
        const grid_cells: component.GridCells = reg.getConst(component.GridCells, grid);
        const pacman_pos: Vec2(usize) = reg.getConst(component.PositionOnGrid, pacman).current.round().intFromFloat(usize);

        // If a ghost hit a wall.
        if (movable_on_grid.current_speed == 0) {
            if (random.float(f32) < ghost_ai.find_path_chance) {
                movable_on_grid.requested_direction = try calculateNextDirection(allocator, grid_cells, pacman_pos, ghost_pos) orelse movable_on_grid.current_direction;
            } else {
                movable_on_grid.requested_direction = rand.randomEnumExcluding(random, Direction, getDirectionsWithoutWalls(grid_cells, ghost_pos).complement());
            }
            ghost_ai.timer.reset();
            continue;
        }

        // If a ghost can turn left or right.
        if (rightOrLeftCellIsNotWall(grid_cells, ghost_pos, movable_on_grid.current_direction)) {
            // If the turn is ignored.
            if (random.float(f32) < ghost_ai.ignore_turn_chance)
                continue;

            if (random.float(f32) < ghost_ai.find_path_chance) {
                const dir = try calculateNextDirection(allocator, grid_cells, pacman_pos, ghost_pos) orelse movable_on_grid.current_direction;
                if (dir.isOppositeOf(movable_on_grid.current_direction))
                    continue;
                movable_on_grid.requested_direction = dir;
            } else {
                var possible_dirs: std.EnumSet(Direction) = getDirectionsWithoutWalls(grid_cells, ghost_pos);
                possible_dirs.remove(movable_on_grid.current_direction.opposite());
                movable_on_grid.requested_direction = rand.randomEnumExcluding(random, Direction, possible_dirs.complement());
            }

            ghost_ai.timer.reset();
            continue;
        }

        if (ghost_ai.timer.read() >= ghost_ai.find_path_period) {
            movable_on_grid.requested_direction = if (random.float(f32) < ghost_ai.find_path_chance)
                try calculateNextDirection(allocator, grid_cells, pacman_pos, ghost_pos) orelse movable_on_grid.current_direction
            else
                rand.randomEnumExcluding(random, Direction, getDirectionsWithoutWalls(grid_cells, ghost_pos).complement());
            ghost_ai.timer.reset();
            continue;
        }
    }
}

fn roundToDirection(pos: Vec2(f32), dir: Direction) Vec2(usize) {
    const rounded: Vec2(f32) = switch (dir) {
        .up => .{ .x = pos.x, .y = @floor(pos.y) },
        .down => .{ .x = pos.x, .y = @ceil(pos.y) },
        .left => .{ .x = @floor(pos.x), .y = pos.y },
        .right => .{ .x = @ceil(pos.x), .y = pos.y },
    };
    return rounded.intFromFloat(usize);
}

fn getDirectionsWithoutWalls(cells: component.GridCells, pos: Vec2(usize)) std.EnumSet(Direction) {
    var dirs_without_walls: std.EnumSet(Direction) = .initEmpty();
    if (cells.get(.init(pos.x, pos.y - 1)) != .wall) dirs_without_walls.insert(.up);
    if (cells.get(.init(pos.x, pos.y + 1)) != .wall) dirs_without_walls.insert(.down);
    if (cells.get(.init(pos.x - 1, pos.y)) != .wall) dirs_without_walls.insert(.left);
    if (cells.get(.init(pos.x + 1, pos.y)) != .wall) dirs_without_walls.insert(.right);
    return dirs_without_walls;
}

fn rightOrLeftCellIsNotWall(cells: component.GridCells, pos: Vec2(usize), dir: Direction) bool {
    switch (dir) {
        .up, .down => return cells.get(.init(pos.x - 1, pos.y)) != .wall or cells.get(.init(pos.x + 1, pos.y)) != .wall,
        .left, .right => return cells.get(.init(pos.x, pos.y - 1)) != .wall or cells.get(.init(pos.x, pos.y + 1)) != .wall,
    }
}

/// Calculates the next turn towards the pacman.
/// Uses BFS algorithm.
fn calculateNextDirection(
    allocator: Allocator,
    grid_cells: component.GridCells,
    pacman_pos: Vec2(usize),
    enemy_pos: Vec2(usize),
) !?Direction {
    // Key - Cell position; Value - Parent position.
    var cells: std.AutoHashMap(Vec2(usize), Vec2(usize)) = .init(allocator);
    defer cells.deinit();

    var queue: std.fifo.LinearFifo(Vec2(usize), .Dynamic) = .init(allocator);
    defer queue.deinit();
    try queue.writeItem(pacman_pos);

    while (true) {
        const current_pos: Vec2(usize) = queue.readItem().?;

        if (std.meta.eql(current_pos, enemy_pos)) break;

        const potential_positions_to_check: [4]Vec2(usize) = .{
            .{ .x = current_pos.x, .y = current_pos.y - 1 },
            .{ .x = current_pos.x + 1, .y = current_pos.y },
            .{ .x = current_pos.x, .y = current_pos.y + 1 },
            .{ .x = current_pos.x - 1, .y = current_pos.y },
        };

        for (potential_positions_to_check) |potential_position| {
            if (grid_cells.get(potential_position) != .wall and !cells.contains(potential_position)) {
                try queue.writeItem(potential_position);
                try cells.put(potential_position, current_pos);
            }
        }
    }

    if (cells.get(enemy_pos)) |target_position| {
        if (target_position.y < enemy_pos.y)
            return .up
        else if (target_position.y > enemy_pos.y)
            return .down
        else if (target_position.x < enemy_pos.x)
            return .left
        else if (target_position.x > enemy_pos.x)
            return .right;
    }
    return null;
}
