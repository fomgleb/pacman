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
        component.GridSize,
        component.RenderArea,
    }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const grid_size: Point(u16) = view.getConst(component.GridSize, entity);
        const render_area_f32 = view.getConst(component.RenderArea, entity).floatFromInt(f32);

        try sdl.setRenderDrawColor(self.renderer, 50, 214, 24, 255);
        try sdl.renderFillRect(self.renderer, render_area_f32);

        try sdl.setRenderDrawColor(self.renderer, 255, 255, 255, 255);
        // Draw vertical lines
        const cell_width = render_area_f32.size.x / @as(f32, @floatFromInt(grid_size.x));
        for (0..(grid_size.x + 1)) |i| {
            const i_f32 = @as(f32, @floatFromInt(i));
            _ = c.SDL_RenderLine(
                self.renderer,
                render_area_f32.position.x + i_f32 * cell_width,
                render_area_f32.position.y,
                render_area_f32.position.x + i_f32 * cell_width,
                render_area_f32.position.y + render_area_f32.size.y,
            );
        }
        // Draw horizontal lines
        const cell_height = render_area_f32.size.y / @as(f32, @floatFromInt(grid_size.y));
        for (0..(grid_size.y + 1)) |i| {
            const i_f32 = @as(f32, @floatFromInt(i));
            _ = c.SDL_RenderLine(
                self.renderer,
                render_area_f32.position.x,
                render_area_f32.position.y + i_f32 * cell_height,
                render_area_f32.position.x + render_area_f32.size.x,
                render_area_f32.position.y + i_f32 * cell_height,
            );
        }
    }
}
