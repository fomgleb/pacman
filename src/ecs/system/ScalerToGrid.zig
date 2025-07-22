const component = @import("../component.zig");
const Rect = @import("../../Rect.zig").Rect;
const System = @import("../../System.zig");
const Vec2 = @import("../../Vec2.zig").Vec2;
const entt = @import("entt");

reg: *entt.Registry,

pub fn update(self: *const @This()) void {
    var view = self.reg.view(.{
        component.GridCellPosition,
        component.RenderArea,
        component.GridMembership,
    }, .{});
    var iter = view.entityIterator();

    while (iter.next()) |entity| {
        const grid_cell_position = view.getConst(component.GridCellPosition, entity);
        const render_area = view.get(component.RenderArea, entity);

        const grid = view.getConst(component.GridMembership, entity).grid_entity;
        const grid_size_f32 = self.reg.getConst(component.GridCells, grid).size.floatFromInt(f32);
        const grid_render_area = self.reg.getConst(component.RenderArea, grid);

        const cell_size = grid_render_area.size.div(grid_size_f32);

        render_area.* = Rect(f32){
            .position = cell_size.mul(grid_cell_position.current).add(grid_render_area.position),
            .size = cell_size,
        };
    }
}

pub fn system(self: *const @This()) System {
    return System.init(self);
}
