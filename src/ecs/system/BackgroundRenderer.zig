const c = @import("../../c.zig");
const sdl = @import("../../sdl.zig");
const System = @import("../../System.zig");
const entt = @import("entt");

reg: *entt.Registry,
renderer: *c.SDL_Renderer,

pub fn update(self: *const @This()) error{SdlError}!void {
    try sdl.setRenderDrawColor(self.renderer, 0, 0, 0, 255);
    try sdl.renderClear(self.renderer);
}

pub fn system(self: *const @This()) System {
    return System.init(self);
}
