const component = @import("../component.zig");
const sdl = @import("game_kit").sdl;
const entt = @import("entt");

pub fn update(reg: *entt.Registry, renderer: *sdl.Renderer) error{SdlError}!void {
    var view = reg.view(.{ component.GridCells, component.RenderArea }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const render_area = view.getConst(component.RenderArea, entity);
        try sdl.setRenderDrawColor(renderer, 50, 214, 24, 255);
        try sdl.renderFillRect(renderer, render_area);
    }
}
