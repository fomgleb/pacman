const component = @import("../component.zig");
const c = @import("../../c.zig");
const sdl = @import("../../sdl.zig");
const System = @import("../../System.zig");
const entt = @import("entt");

reg: *entt.Registry,
renderer: *c.SDL_Renderer,

pub fn update(self: *const @This()) error{SdlError}!void {
    var view = self.reg.view(.{ component.GridCells, component.RenderArea }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const render_area = view.getConst(component.RenderArea, entity);
        try sdl.setRenderDrawColor(self.renderer, 50, 214, 24, 255);
        try sdl.renderFillRect(self.renderer, render_area);
    }
}

pub fn system(self: *const @This()) System {
    return System.init(self);
}
