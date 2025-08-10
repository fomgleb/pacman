const std = @import("std");
const log = std.log.scoped(.@"Enemy Spawning");
const Allocator = std.mem.Allocator;
const random = std.crypto.random;
const pow = std.math.pow;
const component = @import("../component.zig");
const entity = @import("../entity.zig");
const c = @import("../../c.zig");
const Direction = @import("../../Direction.zig").Direction;
const Vec2 = @import("../../Vec2.zig").Vec2;
const entt = @import("entt");

const enemy_move_speed = 5;
const enemy_change_direction_period_s = 1;
const spawn_distance = 15;

pub fn update(reg: *entt.Registry, allocator: Allocator, pacman: entt.Entity, fast_stupid_enemy_creator: entity.FastStupidEnemyCreator) !void {
    var view = reg.view(.{ component.CanSpawnOne, component.GridMembership }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const enemy_spawner: *component.CanSpawnOne = view.get(component.CanSpawnOne, e);
        if (enemy_spawner.is_spawned or enemy_spawner.timer.read() < enemy_spawner.spawn_delay) continue;
        const grid: entt.Entity = view.getConst(component.GridMembership, e).grid_entity;
        const grid_cells: component.GridCells = view.getConst(component.GridCells, grid);
        const pacman_position: component.PositionOnGrid = reg.getConst(component.PositionOnGrid, pacman);

        const random_position = try getEnemySpawnPosition(allocator, grid_cells, pacman_position.current.intFromFloat(usize)) orelse {
            log.warn("Can't spawn an enemy at the distance of {} cells from the pacman", .{spawn_distance});
            continue;
        };

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
fn getEnemySpawnPosition(allocator: Allocator, grid_cells: component.GridCells, pacman_position: Vec2(usize)) !?Vec2(usize) {
    var points_to_check: std.fifo.LinearFifo(Point, .{ .Static = pow(usize, spawn_distance * 2 + 1, 2) }) = .init();
    try points_to_check.writeItem(.{ .position = pacman_position, .distance = 0 });

    var checked_points: std.AutoHashMap(Point, void) = .init(allocator);
    defer checked_points.deinit();
    try checked_points.put(.{ .position = pacman_position, .distance = 0 }, {});

    var distance_from_pacman: usize = 0;
    while (points_to_check.count != 0 and distance_from_pacman != spawn_distance + 1) {
        const checking_point: Point = points_to_check.readItem().?;

        const potential_points_to_check: [4]Vec2(usize) = .{
            .{ .x = checking_point.position.x, .y = checking_point.position.y - 1 },
            .{ .x = checking_point.position.x + 1, .y = checking_point.position.y },
            .{ .x = checking_point.position.x, .y = checking_point.position.y + 1 },
            .{ .x = checking_point.position.x - 1, .y = checking_point.position.y },
        };

        for (potential_points_to_check) |potential_point| {
            if (grid_cells.get(potential_point) != .wall and
                !checked_points.contains(.init(potential_point, checking_point.distance -| 1)) and
                !checked_points.contains(.init(potential_point, checking_point.distance + 1)))
            {
                const point: Point = .init(potential_point, checking_point.distance + 1);
                try points_to_check.writeItem(point);
                try checked_points.put(point, {}); // TODO: Bad naming: `point` will become `checking_point`, but it's already in `checked_points`
                distance_from_pacman = checking_point.distance + 1;
            }
        }
    }

    const possible_spawn_points: std.fifo.LinearFifo(Point, .{ .Static = pow(usize, spawn_distance * 2 + 1, 2) }) = blk: {
        points_to_check.discard(points_to_check.count);
        var furthest_points = points_to_check;
        var iterator = checked_points.keyIterator();
        while (iterator.next()) |checked_point|
            if (checked_point.distance == spawn_distance)
                try furthest_points.writeItem(checked_point.*);
        break :blk furthest_points;
    };

    if (possible_spawn_points.count == 0) return null;

    const random_index = random.uintLessThan(usize, possible_spawn_points.count);
    return possible_spawn_points.buf[possible_spawn_points.head + random_index].position;
}
