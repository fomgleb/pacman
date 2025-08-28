const std = @import("std");
const log = std.log.scoped(.@"Enemy Spawning");
const Allocator = std.mem.Allocator;
const random = std.crypto.random;
const pow = std.math.pow;
const component = @import("../component.zig");
const entity = @import("../entity.zig");
const Direction = @import("../../Direction.zig").Direction;
const Queue = @import("../../Queue.zig").Queue;
const game_kit = @import("game_kit");
const c = game_kit.c;
const Vec2 = game_kit.Vec2;
const entt = @import("entt");

const spawn_distance = 15;

pub fn update(reg: *entt.Registry, allocator: Allocator, pacman: entt.Entity) !void {
    var view = reg.view(.{ component.CanSpawnOne, component.GridMembership }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const can_spawn_one: *component.CanSpawnOne = view.get(component.CanSpawnOne, e);
        if (can_spawn_one.is_spawned or can_spawn_one.timer.read() < can_spawn_one.spawn_delay) continue;
        const grid: entt.Entity = view.getConst(component.GridMembership, e).grid_entity;
        const grid_cells: component.GridCells = view.getConst(component.GridCells, grid);
        const pacman_position: component.PositionOnGrid = reg.getConst(component.PositionOnGrid, pacman);

        const random_position = try getEnemySpawnPosition(allocator, grid_cells, pacman_position.current.intFromFloat(usize)) orelse {
            log.warn("Can't spawn an enemy at the distance of {} cells from the pacman", .{spawn_distance});
            continue;
        };

        const enemy: entt.Entity = try can_spawn_one.entity_creator.create();
        reg.get(component.PositionOnGrid, enemy).* = .init(random_position.floatFromInt(f32));
        const random_direction: Direction = random.enumValue(Direction);
        const movable_on_grid: *component.MovableOnGrid = reg.get(component.MovableOnGrid, enemy);
        movable_on_grid.requested_direction = random_direction;
        movable_on_grid.current_direction = random_direction;

        can_spawn_one.is_spawned = true;
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
    var points_to_check_buf: [pow(usize, spawn_distance * 2 + 1, 2) * @sizeOf(Point)]u8 = undefined;
    var fba_state: std.heap.FixedBufferAllocator = .init(&points_to_check_buf);
    const fb_allocator: Allocator = fba_state.allocator();
    var points_to_check: Queue(Point) = .init(fb_allocator);
    try points_to_check.enqueue(.{ .position = pacman_position, .distance = 0 });

    var checked_points: std.AutoHashMap(Point, void) = .init(allocator);
    defer checked_points.deinit();
    try checked_points.put(.{ .position = pacman_position, .distance = 0 }, {});

    var distance_from_pacman: usize = 0;
    while (!points_to_check.empty() and distance_from_pacman != spawn_distance + 1) {
        const current_point: Point = points_to_check.dequeue().?;

        const potential_positions_to_check: [4]Vec2(usize) = .{
            .{ .x = current_point.position.x, .y = current_point.position.y - 1 },
            .{ .x = current_point.position.x + 1, .y = current_point.position.y },
            .{ .x = current_point.position.x, .y = current_point.position.y + 1 },
            .{ .x = current_point.position.x - 1, .y = current_point.position.y },
        };

        for (potential_positions_to_check) |potential_position| {
            if (grid_cells.get(potential_position) != .wall and
                !checked_points.contains(.init(potential_position, current_point.distance -| 1)) and
                !checked_points.contains(.init(potential_position, current_point.distance + 1)))
            {
                const new_point: Point = .init(potential_position, current_point.distance + 1);
                try points_to_check.enqueue(new_point);
                try checked_points.put(new_point, {});
                distance_from_pacman = current_point.distance + 1;
            }
        }
    }

    fba_state.reset();
    const possible_spawn_points: std.ArrayList(Point) = blk: {
        var furthest_points: std.ArrayList(Point) = try .initCapacity(fb_allocator, points_to_check_buf.len / @sizeOf(Point) - 1);
        var iterator = checked_points.keyIterator();
        while (iterator.next()) |checked_point|
            if (checked_point.distance == spawn_distance)
                try furthest_points.append(fb_allocator, checked_point.*);
        break :blk furthest_points;
    };

    if (possible_spawn_points.items.len == 0) return null;

    const random_index = random.uintLessThan(usize, possible_spawn_points.items.len);
    return possible_spawn_points.items[random_index].position;
}
