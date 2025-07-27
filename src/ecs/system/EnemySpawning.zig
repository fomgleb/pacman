const std = @import("std");
const random = std.crypto.random;
const component = @import("../component.zig");
const entity = @import("../entity.zig");
const c = @import("../../c.zig");
const Direction = @import("../../Direction.zig").Direction;
const System = @import("../../System.zig");
const Vec2 = @import("../../Vec2.zig").Vec2;
const entt = @import("entt");

const enemy_move_speed = 5;
const enemy_change_direction_period_s = 1;

reg: *entt.Registry,
renderer: *c.SDL_Renderer,
pacman: entt.Entity,
fast_stupid_enemy_creator: entity.FastStupidEnemyCreator,

pub fn init(
    reg: *entt.Registry,
    renderer: *c.SDL_Renderer,
    pacman: entt.Entity,
    fast_stupid_enemy_creator: entity.FastStupidEnemyCreator,
) @This() {
    return .{ .reg = reg, .renderer = renderer, .pacman = pacman, .fast_stupid_enemy_creator = fast_stupid_enemy_creator };
}

pub fn update(self: *const @This()) !void {
    var view = self.reg.view(.{ component.CanSpawnOne, component.GridMembership }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const enemy_spawner = view.get(component.CanSpawnOne, e);
        if (enemy_spawner.is_spawned or enemy_spawner.timer.read() < enemy_spawner.spawn_delay) continue;
        const grid = view.getConst(component.GridMembership, e).grid_entity;
        const grid_cells = view.getConst(component.GridCells, grid);
        const pacman_position = self.reg.getConst(component.PositionOnGrid, self.pacman);

        // TODO: Don't spawn an enemy near the pacman
        _ = pacman_position;

        const random_position = blk: while (true) {
            // TODO: Possible case: endlessly generating wall position
            const random_position = Vec2(usize){
                .x = random.uintLessThan(usize, grid_cells.size.x),
                .y = random.uintLessThan(usize, grid_cells.size.y),
            };
            if (grid_cells.get(random_position) == .wall) continue;

            break :blk random_position;
        };

        _ = try self.fast_stupid_enemy_creator.create(
            self.reg,
            random_position.floatFromInt(f32),
            .init(enemy_move_speed, random.enumValue(Direction)),
            grid,
            enemy_change_direction_period_s,
        );

        enemy_spawner.is_spawned = true;
    }
}

pub fn system(self: *const @This()) System {
    return System.init(self);
}
