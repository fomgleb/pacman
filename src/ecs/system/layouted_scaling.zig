const component = @import("../component.zig");
const Rect = @import("../../Rect.zig").Rect;
const sdl = @import("../../sdl.zig");
const entt = @import("entt");

pub fn update(reg: *entt.Registry) error{SdlError}!void {
    var view = reg.view(.{
        component.Texture,
        component.RenderArea,
        component.RelativeSize,
        component.GridMembership,
        component.Layout,
    }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const relative_size: component.RelativeSize = view.getConst(component.RelativeSize, entity);
        const layout = view.getConst(component.Layout, entity);
        const grid_area = view.getConst(component.RenderArea, view.getConst(component.GridMembership, entity).grid_entity);
        const texture_size = try sdl.getTextureSize(view.getConst(component.Texture, entity));

        const render_area: *Rect(f32) = view.get(component.RenderArea, entity);

        if (relative_size.w != null and relative_size.h != null) {
            render_area.size = .{ .x = relative_size.w.?, .y = relative_size.h.? };
        } else {
            if (relative_size.w) |w| {
                render_area.size.x = grid_area.size.x * w;
                render_area.size.y = render_area.size.x * (texture_size.y / texture_size.x);
            }
            if (relative_size.h) |h| {
                render_area.size.y = grid_area.size.y * h;
                render_area.size.x = render_area.size.y * (texture_size.x / texture_size.y);
            }
        }

        render_area.position = .{
            .x = switch (layout.v) {
                .left => grid_area.position.x,
                .center => (grid_area.position.x + grid_area.size.x / 2) - (render_area.size.x / 2),
                .right => grid_area.position.x + grid_area.size.x - render_area.size.x,
            },
            .y = switch (layout.h) {
                .top => grid_area.position.y,
                .center => (grid_area.position.y + grid_area.size.y / 2) - (render_area.size.y / 2),
                .bottom => grid_area.position.y + grid_area.size.y - render_area.size.y,
            },
        };
        const offset = grid_area.size.mul(layout.rel_offset);
        render_area.position = render_area.position.add(offset);
    }
}
