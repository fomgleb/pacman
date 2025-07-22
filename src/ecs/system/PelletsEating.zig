const component = @import("../component.zig");
const Direction = @import("../../Direction.zig").Direction;
const System = @import("../../System.zig");
const Vec2 = @import("../../Vec2.zig").Vec2;
const entt = @import("entt");

const pellet_eat_distance = 0.2;

reg: *entt.Registry,
events_holder: entt.Entity,

pub fn update(self: *const @This()) void {
    var view = self.reg.view(.{
        component.GridMembership,
        component.PositionOnGrid,
        component.MovableOnGrid,
        component.PelletsEater,
    }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const grid = self.reg.getConst(component.GridMembership, entity).grid_entity;
        const grid_cells = self.reg.get(component.GridCells, grid);
        const entity_position = self.reg.getConst(component.PositionOnGrid, entity).current;
        const potential_pellet_pos = entity_position.round();
        if (grid_cells.get(potential_pellet_pos.intFromFloat(usize)) != .pellet) continue;
        const movable_on_grid = self.reg.getConst(component.MovableOnGrid, entity);
        switch (movable_on_grid.current_direction) {
            .up, .down => {
                const distance = @abs(entity_position.y - potential_pellet_pos.y);
                if (distance > pellet_eat_distance) continue;
            },
            .left, .right => {
                const distance = @abs(entity_position.x - potential_pellet_pos.x);
                if (distance > pellet_eat_distance) continue;
            },
        }
        const pellets_eater = self.reg.get(component.PelletsEater, entity);

        grid_cells.set(potential_pellet_pos.intFromFloat(usize), .empty);
        pellets_eater.eaten_pellets_count += 1;
        pellets_eater.left_pellets_count -= 1;
        if (pellets_eater.left_pellets_count == 0) {
            self.reg.addOrReplace(self.events_holder, component.QuitEvent{});
        }
    }
}

pub fn system(self: *const @This()) System {
    return System.init(self);
}
