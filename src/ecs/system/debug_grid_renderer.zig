const component = @import("../component.zig");
const c = @import("../../c.zig").c;
const sdl = @import("../../sdl.zig");
const entt = @import("entt");

pub fn update(reg: *entt.Registry, renderer: *c.SDL_Renderer) error{SdlError}!void {
    var view = reg.view(.{ component.GridCells, component.RenderArea }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const render_area = view.getConst(component.RenderArea, entity);
        try sdl.setRenderDrawColor(renderer, 50, 214, 24, 255);
        try sdl.renderFillRect(renderer, render_area);
    }
}
