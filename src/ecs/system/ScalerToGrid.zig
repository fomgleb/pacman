const Point = @import("../../point.zig").Point;
const Rect = @import("../../rect.zig").Rect;
const Grid = @import("../../Grid.zig");
const component = @import("../component.zig");
const entt = @import("entt");
const ScalerToGrid = @This();

reg: *entt.Registry,
grid: *const Grid,

pub fn update(self: ScalerToGrid) void {
    var view = self.reg.view(.{
        component.PositionOnGrid,
        component.RenderArea,
    }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const position_on_grid = view.getConst(component.PositionOnGrid, entity);
        const render_area = view.get(component.RenderArea, entity);

        const render_area_f32 = self.grid.render_area.floatFromInt(f32);
        const grid_size_f32 = self.grid.size.floatFromInt(f32);
        const cell_size = Point(f32){
            .x = render_area_f32.size.x / grid_size_f32.x,
            .y = render_area_f32.size.y / grid_size_f32.y,
        };

        render_area.* = Rect(u32){
            .position = .{
                .x = @intFromFloat(render_area_f32.position.x + cell_size.x * position_on_grid.x),
                .y = @intFromFloat(render_area_f32.position.y + cell_size.y * position_on_grid.y),
            },
            .size = cell_size.intFromFloat(u32),
        };
    }
}
