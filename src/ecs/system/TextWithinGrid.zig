const time = @import("std").time;
const component = @import("../component.zig");
const c = @import("../../c.zig");
const Rect = @import("../../Rect.zig").Rect;
const sdl = @import("../../sdl.zig");
const System = @import("../../System.zig");
const Vec2 = @import("../../Vec2.zig").Vec2;
const entt = @import("entt");

reg: *entt.Registry,
events_holder: entt.Entity,

pub fn update(self: *const @This()) error{SdlError}!void {
    var view = self.reg.view(.{
        component.TextTag,
        component.Texture,
        component.RenderArea,
        component.RelativeHeight,
        component.GridMembership,
        component.Layout,
    }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const relative_height: f32 = view.getConst(component.RelativeHeight, entity).value;
        const layout = view.getConst(component.Layout, entity);
        const grid_area = view.getConst(component.RenderArea, view.getConst(component.GridMembership, entity).grid_entity);
        const text_texture_size = try sdl.getTextureSize(view.getConst(component.Texture, entity));

        const render_area: *Rect(f32) = view.get(component.RenderArea, entity);

        render_area.size.y = grid_area.size.y * relative_height;
        render_area.size.x = render_area.size.y * (text_texture_size.x / text_texture_size.y);

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

pub fn system(self: *const @This()) System {
    return System.init(self);
}
