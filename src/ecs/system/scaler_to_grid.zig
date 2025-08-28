const component = @import("../component.zig");
const game_kit = @import("game_kit");
const Rect = game_kit.Rect;
const Vec2 = game_kit.Vec2;
const entt = @import("entt");

pub fn update(reg: *entt.Registry) void {
    var view = reg.view(.{
        component.PositionOnGrid,
        component.RenderArea,
        component.GridMembership,
    }, .{});
    var iter = view.entityIterator();

    while (iter.next()) |entity| {
        const position_on_grid = view.getConst(component.PositionOnGrid, entity);
        const render_area = view.get(component.RenderArea, entity);

        const grid = view.getConst(component.GridMembership, entity).grid_entity;
        const grid_size_f32 = reg.getConst(component.GridCells, grid).size.floatFromInt(f32);
        const grid_render_area = reg.getConst(component.RenderArea, grid);

        const cell_size = grid_render_area.size.div(grid_size_f32);

        render_area.* = Rect(f32){
            .position = cell_size.mul(position_on_grid.current).add(grid_render_area.position),
            .size = cell_size,
        };
    }
}
