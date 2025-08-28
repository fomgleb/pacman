//! Renders Texture in RenderArea.

const component = @import("../component.zig");
const sdl = @import("game_kit").sdl;
const entt = @import("entt");

pub fn update(reg: *entt.Registry, renderer: *sdl.Renderer) !void {
    var view = reg.view(.{ component.RenderArea, component.Texture }, .{component.BackgroundTag});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const render_area = view.getConst(component.RenderArea, entity);
        const renderable_texture = view.getConst(component.Texture, entity);

        try sdl.renderTexture(renderer, renderable_texture, null, render_area);
    }
}
