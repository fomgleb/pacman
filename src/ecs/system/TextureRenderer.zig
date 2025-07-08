//! Renders Texture in RenderArea.

const component = @import("../component.zig");
const sdl = @import("../../sdl.zig");
const c = @import("../../c.zig");
const entt = @import("entt");

reg: *entt.Registry,

pub fn update(self: @This()) !void {
    var view = self.reg.view(.{
        component.RenderArea,
        component.Texture,
    }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const render_area = view.getConst(component.RenderArea, entity);
        const renderable_texture = view.getConst(component.Texture, entity);

        const renderer = try sdl.getRendererFromTexture(renderable_texture);
        try sdl.renderTexture(renderer, renderable_texture, null, render_area.floatFromInt(f32));
    }
}
