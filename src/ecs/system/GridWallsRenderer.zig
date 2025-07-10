const component = @import("../component.zig");
const Point = @import("../../point.zig").Point;
const Rect = @import("../../rect.zig").Rect;
const sdl = @import("../../sdl.zig");
const c = @import("../../c.zig");
const entt = @import("entt");

reg: *entt.Registry,
renderer: *c.SDL_Renderer,

pub fn update(self: @This()) !void {
    var view = self.reg.view(.{
        component.GridCells,
        component.RenderArea,
    }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const grid_cells = view.getConst(component.GridCells, entity);
        const render_area_f32 = view.getConst(component.RenderArea, entity).floatFromInt(f32);

        const cell_width = render_area_f32.size.x / @as(f32, @floatFromInt(grid_cells.size.x));
        const cell_height = render_area_f32.size.y / @as(f32, @floatFromInt(grid_cells.size.y));

        try sdl.setRenderDrawColor(self.renderer, 0, 0, 0, 255);
        for (0..grid_cells.size.x) |x| {
            for (0..grid_cells.size.y) |y| {
                if (grid_cells.get(.{ .x = x, .y = y }) != .wall) continue;

                const x_f32: f32 = @floatFromInt(x);
                const y_f32: f32 = @floatFromInt(y);
                try sdl.renderFillRect(self.renderer, Rect(f32){
                    .position = .{ .x = render_area_f32.position.x + x_f32 * cell_width, .y = render_area_f32.position.y + y_f32 * cell_height },
                    .size = .{ .x = cell_width, .y = cell_height },
                });
            }
        }
    }
}
