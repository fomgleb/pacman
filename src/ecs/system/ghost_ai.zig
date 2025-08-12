const std = @import("std");
const Allocator = std.mem.Allocator;
const random = std.crypto.random;
const pow = std.math.pow;
const component = @import("../component.zig");
const Direction = @import("../../Direction.zig").Direction;
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
        if (movable_on_grid.current_speed != 0 and ghost_ai.timer.read() < ghost_ai.find_path_period) continue;

        if (ghost_ai.find_path_chance == 0) {
            movable_on_grid.requested_direction = std.crypto.random.enumValue(Direction);
            ghost_ai.timer.reset();
            continue;
        }

        const position: Vec2(usize) = view.getConst(component.PositionOnGrid, entity).current.round().intFromFloat(usize);
        const grid: entt.Entity = view.getConst(component.GridMembership, entity).grid_entity;
        const grid_cells: component.GridCells = reg.getConst(component.GridCells, grid);
        const pacman_position: Vec2(usize) = reg.getConst(component.PositionOnGrid, pacman).current.round().intFromFloat(usize);

        if (random.float(f32) <= ghost_ai.find_path_chance) {
            if (try getDirection(allocator, grid_cells, pacman_position, position)) |dir| {
                movable_on_grid.requested_direction = dir;
            }
        } else {
            movable_on_grid.requested_direction = std.crypto.random.enumValue(Direction);
        }
        ghost_ai.timer.reset();
    }
}

/// Uses BFS algorithm.
fn getDirection(
    allocator: Allocator,
    grid_cells: component.GridCells,
    pacman_position: Vec2(usize),
    enemy_position: Vec2(usize),
) !?Direction {
    // Key - Cell position; Value - Parent position.
    var cells: std.AutoHashMap(Vec2(usize), Vec2(usize)) = .init(allocator);
    defer cells.deinit();

    var queue: std.fifo.LinearFifo(Vec2(usize), .Dynamic) = .init(allocator);
    defer queue.deinit();
    try queue.writeItem(pacman_position);

    while (true) {
        const current_position: Vec2(usize) = queue.readItem().?;

        if (std.meta.eql(current_position, enemy_position)) break;

        const potential_positions_to_check: [4]Vec2(usize) = .{
            .{ .x = current_position.x, .y = current_position.y - 1 },
            .{ .x = current_position.x + 1, .y = current_position.y },
            .{ .x = current_position.x, .y = current_position.y + 1 },
            .{ .x = current_position.x - 1, .y = current_position.y },
        };

        for (potential_positions_to_check) |potential_position| {
            if (grid_cells.get(potential_position) != .wall and !cells.contains(potential_position)) {
                try queue.writeItem(potential_position);
                try cells.put(potential_position, current_position);
            }
        }
    }

    if (cells.get(enemy_position)) |target_position| {
        if (target_position.y < enemy_position.y)
            return .up
        else if (target_position.y > enemy_position.y)
            return .down
        else if (target_position.x < enemy_position.x)
            return .left
        else if (target_position.x > enemy_position.x)
            return .right;
    }
    return null;
}
