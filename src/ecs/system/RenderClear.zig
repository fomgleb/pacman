const c = @import("../../c.zig");
const sdl = @import("../../sdl.zig");
const System = @import("../../System.zig");

renderer: *c.SDL_Renderer,

pub fn update(self: *const @This()) !void {
    try sdl.renderClear(self.renderer);
}

pub fn system(self: *const @This()) System {
    return System.init(self);
}
