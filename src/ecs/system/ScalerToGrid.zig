const component = @import("../component.zig");
const Rect = @import("../../rect.zig").Rect;
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
        const grid_size_f32 = self.reg.getConst(component.GridSize, grid).floatFromInt(f32);
        const grid_render_area_f32 = self.reg.getConst(component.RenderArea, grid).floatFromInt(f32);

        const cell_size = Vec2(f32){
            .x = grid_render_area_f32.size.x / grid_size_f32.x,
            .y = grid_render_area_f32.size.y / grid_size_f32.y,
        };

        render_area.* = Rect(u32){
            .position = .{
                .x = @intFromFloat(grid_render_area_f32.position.x + cell_size.x * grid_cell_position.current.x),
                .y = @intFromFloat(grid_render_area_f32.position.y + cell_size.y * grid_cell_position.current.y),
            },
            .size = cell_size.intFromFloat(u32),
        };
    }
}

pub fn system(self: *const @This()) System {
    return System.init(self);
}
