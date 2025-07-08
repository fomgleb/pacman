const Point = @import("../../point.zig").Point;
const Rect = @import("../../rect.zig").Rect;
const component = @import("../component.zig");
const entt = @import("entt");
const ScalerToGrid = @This();

reg: *entt.Registry,
grid: entt.Entity,

pub fn update(self: ScalerToGrid) void {
    var view = self.reg.view(.{
        component.PositionOnGrid,
        component.RenderArea,
    }, .{});
    var iter = view.entityIterator();

    const grid_size_f32 = self.reg.getConst(component.GridSize, self.grid).floatFromInt(f32);
    const grid_render_area_f32 = self.reg.getConst(component.RenderArea, self.grid).floatFromInt(f32);

    while (iter.next()) |entity| {
        const position_on_grid = view.getConst(component.PositionOnGrid, entity);
        const render_area = view.get(component.RenderArea, entity);

        const cell_size = Point(f32){
            .x = grid_render_area_f32.size.x / grid_size_f32.x,
            .y = grid_render_area_f32.size.y / grid_size_f32.y,
        };

        render_area.* = Rect(u32){
            .position = .{
                .x = @intFromFloat(grid_render_area_f32.position.x + cell_size.x * position_on_grid.x),
                .y = @intFromFloat(grid_render_area_f32.position.y + cell_size.y * position_on_grid.y),
            },
            .size = cell_size.intFromFloat(u32),
        };
    }
}
