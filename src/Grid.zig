const Renderable = @import("Renderable.zig");
const Point = @import("point.zig").Point;
const Rect = @import("rect.zig").Rect;
const c = @import("c.zig");
const Grid = @This();

renderer: *c.SDL_Renderer,
render_area: Rect(u32),
size: Point(u16),

pub fn init(renderer: *c.SDL_Renderer, render_area: Rect(u32), size: Point(u16)) Grid {
    return Grid{
        .renderer = renderer,
        .render_area = render_area,
        .size = size,
    };
}

pub fn renderable(self: *const Grid) Renderable {
    return Renderable.init(self);
}

// For debugging
pub fn render(self: *const Grid) error{SdlError}!void {
    _ = c.SDL_SetRenderDrawColor(self.renderer, 255, 255, 255, 255);

    const render_area = self.render_area.floatFromInt(f32);

    // Draw vertical lines
    const cell_width = render_area.size.x / @as(f32, @floatFromInt(self.size.x));
    for (0..(self.size.x + 1)) |i| {
        const i_f32 = @as(f32, @floatFromInt(i));
        _ = c.SDL_RenderLine(
            self.renderer,
            render_area.position.x + i_f32 * cell_width,
            render_area.position.y,
            render_area.position.x + i_f32 * cell_width,
            render_area.position.y + render_area.size.y,
        );
    }

    // Draw horizontal lines
    const cell_height = render_area.size.y / @as(f32, @floatFromInt(self.size.y));
    for (0..(self.size.y + 1)) |i| {
        const i_f32 = @as(f32, @floatFromInt(i));
        _ = c.SDL_RenderLine(
            self.renderer,
            render_area.position.x,
            render_area.position.y + i_f32 * cell_height,
            render_area.position.x + render_area.size.x,
            render_area.position.y + i_f32 * cell_height,
        );
    }
}

pub fn scale(self: *Grid, area: Rect(u32)) void {
    self.render_area = area;
}
