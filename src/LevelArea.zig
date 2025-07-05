const log = @import("std").log.scoped(.@"Level Area");
const Renderable = @import("Renderable.zig");
const Point = @import("point.zig").Point;
const Rect = @import("rect.zig").Rect;
const sdl = @import("sdl.zig");
const c = @import("c.zig");
const LevelArea = @This();

renderer: *c.SDL_Renderer,
aspect_ratio: Point(u8),
render_area: Rect(u32),

pub fn init(renderer: *c.SDL_Renderer, aspect_ratio: Point(u8), window_size: Point(u32)) LevelArea {
    const simplified_ratio = simplifyAspectRatio(aspect_ratio);
    return LevelArea{
        .renderer = renderer,
        .aspect_ratio = simplified_ratio,
        .render_area = computeScreenArea(simplified_ratio, window_size),
    };
}

/// Adjusts screen_area to maintain aspect ratio in new window size.
pub fn scale(self: *LevelArea, window_size: Point(u32)) void {
    self.render_area = computeScreenArea(self.aspect_ratio, window_size);
}

/// For debugging
pub fn render(self: *const LevelArea) error{SdlError}!void {
    try sdl.setRenderDrawColor(self.renderer, 50, 214, 24, 255);
    try sdl.renderFillRect(self.renderer, self.render_area.floatFromInt(f32));
}

/// For debugging
pub fn renderable(self: *const LevelArea) Renderable {
    return Renderable.init(self);
}

fn simplifyAspectRatio(ratio: Point(u8)) Point(u8) {
    const divisor = gcd(ratio.x, ratio.y);
    return Point(u8){ .x = ratio.x / divisor, .y = ratio.y / divisor };
}

fn computeScreenArea(aspect_ratio: Point(u8), window_size: Point(u32)) Rect(u32) {
    const scale_x = window_size.x / aspect_ratio.x;
    const scale_y = window_size.y / aspect_ratio.y;
    const scale_ = @min(scale_x, scale_y);

    const size = Point(u32){
        .x = aspect_ratio.x * scale_,
        .y = aspect_ratio.y * scale_,
    };

    const position = Point(u32){
        .x = (window_size.x - size.x) / 2,
        .y = (window_size.y - size.y) / 2,
    };

    return Rect(u32){
        .position = position,
        .size = size,
    };
}

// Helper to simplify a fraction (aspect ratio)
fn gcd(a: u8, b: u8) u8 {
    return if (b == 0) a else gcd(b, a % b);
}
