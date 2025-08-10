const std = @import("std");
const random = std.crypto.random;
const component = @import("../component.zig");
const entity = @import("../entity.zig");
const c = @import("../../c.zig");
const Direction = @import("../../Direction.zig").Direction;
const Vec2 = @import("../../Vec2.zig").Vec2;
const entt = @import("entt");

const enemy_move_speed = 5;
const enemy_change_direction_period_s = 1;
const spawn_distance = 15;

pub fn update(reg: *entt.Registry, pacman: entt.Entity, fast_stupid_enemy_creator: entity.FastStupidEnemyCreator) !void {
    var view = reg.view(.{ component.CanSpawnOne, component.GridMembership }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const enemy_spawner: *component.CanSpawnOne = view.get(component.CanSpawnOne, e);
        if (enemy_spawner.is_spawned or enemy_spawner.timer.read() < enemy_spawner.spawn_delay) continue;
        const grid: entt.Entity = view.getConst(component.GridMembership, e).grid_entity;
        const grid_cells: component.GridCells = view.getConst(component.GridCells, grid);
        const pacman_position: component.PositionOnGrid = reg.getConst(component.PositionOnGrid, pacman);

        const random_position = try getEnemySpawnPosition(grid_cells, pacman_position.current.intFromFloat(usize));

        _ = try fast_stupid_enemy_creator.create(
            reg,
            random_position.floatFromInt(f32),
            .init(enemy_move_speed, random.enumValue(Direction)),
            grid,
            enemy_change_direction_period_s,
        );

        enemy_spawner.is_spawned = true;
    }
}

const Point = struct {
    position: Vec2(usize),
    distance: usize,

    pub fn init(position: Vec2(usize), distance: usize) @This() {
        return .{ .position = position, .distance = distance };
    }
};

// Spread waves from the pacman to find a point where to spawn an enemy.
fn getEnemySpawnPosition(grid_cells: component.GridCells, pacman_position: Vec2(usize)) !Vec2(usize) {
    var buffer: [std.math.pow(usize, spawn_distance * 2 + 1, 2) * @sizeOf(Point)]u8 = undefined;
    var fba_state: std.heap.FixedBufferAllocator = .init(&buffer);
    const allocator = fba_state.allocator();

    var points_to_check: std.fifo.LinearFifo(Point, .{ .Static = spawn_distance * 8 }) = .init();
    try points_to_check.writeItem(.{ .position = pacman_position, .distance = 0 });

    var checked_points: std.AutoHashMap(Point, void) = .init(allocator);

    var distance_from_pacman: usize = 0;
    while (points_to_check.count != 0 and distance_from_pacman != spawn_distance + 2) {
        const checking_point: Point = points_to_check.readItem().?;

        const potential_points_to_check: [4]Vec2(usize) = .{
            .{ .x = checking_point.position.x, .y = checking_point.position.y - 1 },
            .{ .x = checking_point.position.x + 1, .y = checking_point.position.y },
            .{ .x = checking_point.position.x, .y = checking_point.position.y + 1 },
            .{ .x = checking_point.position.x - 1, .y = checking_point.position.y },
        };

        for (potential_points_to_check) |potential_point| {
            if (grid_cells.get(potential_point) != .wall and
                !checked_points.contains(.init(potential_point, checking_point.distance -| 1)))
            {
                try points_to_check.writeItem(.init(potential_point, checking_point.distance + 1));
                distance_from_pacman = checking_point.distance + 1;
            }
        }

        try checked_points.put(checking_point, {});
    }

    const possible_spawn_points: std.fifo.LinearFifo(Point, .{ .Static = spawn_distance * 8 }) = blk: {
        points_to_check.discard(points_to_check.count);
        var furthest_points = points_to_check;
        var iterator = checked_points.keyIterator();
        while (iterator.next()) |checked_point|
            if (checked_point.distance == spawn_distance)
                try furthest_points.writeItem(checked_point.*);
        break :blk furthest_points;
    };

    const random_index = random.uintLessThan(usize, possible_spawn_points.count);
    return possible_spawn_points.buf[possible_spawn_points.head + random_index].position;
}
