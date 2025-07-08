const component = @import("../component.zig");
const Point = @import("../../point.zig").Point;
const Rect = @import("../../rect.zig").Rect;
const entt = @import("entt");

reg: *entt.Registry,

pub fn update(self: @This(), window_size: Point(u32)) void {
    var view = self.reg.view(.{
        component.CenteredInWindowTag,
        component.RenderArea,
        component.AspectRatio,
    }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const aspect_ratio = view.getConst(component.AspectRatio, entity);
        const render_area = view.get(component.RenderArea, entity);

        render_area.* = computeScreenArea(.{ .x = aspect_ratio.w, .y = aspect_ratio.h }, window_size);
    }
}

fn computeScreenArea(aspect_ratio: Point(u16), window_size: Point(u32)) Rect(u32) {
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
