const component = @import("../component.zig");
const Direction = @import("../../Direction.zig").Direction;
const System = @import("../../System.zig");
const Vec2 = @import("../../Vec2.zig").Vec2;
const entt = @import("entt");

reg: *entt.Registry,
events_holder: entt.Entity,

pub fn update(self: *const @This()) void {
    var view = self.reg.view(.{
        component.PlayerTag,
        component.GridMembership,
        component.GridCellPosition,
        component.PelletsEater,
    }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const grid = self.reg.getConst(component.GridMembership, entity).grid_entity;
        const grid_cells = self.reg.get(component.GridCells, grid);
        const entity_cell_pos_f32 = self.reg.getConst(component.GridCellPosition, entity).current;
        const entity_cell_pos = roundVec2f32(entity_cell_pos_f32);
        const pellets_eater = self.reg.get(component.PelletsEater, entity);

        if (grid_cells.get(entity_cell_pos) == .pellet) {
            grid_cells.set(entity_cell_pos, .empty);
            pellets_eater.eaten_pellets_count += 1;
            pellets_eater.left_pellets_count -= 1;
            if (pellets_eater.left_pellets_count == 0) {
                self.reg.addOrReplace(self.events_holder, component.QuitEvent{});
            }
        }
    }
}

pub fn system(self: *const @This()) System {
    return System.init(self);
}

pub fn roundVec2f32(vec: Vec2(f32)) Vec2(usize) {
    return .{ .x = @intFromFloat(@round(vec.x)), .y = @intFromFloat(@round(vec.y)) };
}
