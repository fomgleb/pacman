const component = @import("../component.zig");
const c = @import("../../c.zig").c;
const sdl = @import("../../sdl.zig");
const entt = @import("entt");

pub fn update(reg: *entt.Registry, renderer: *c.SDL_Renderer) !void {
    var view = reg.view(.{ component.Texture, component.PositionInWindow }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const texture = view.getConst(component.Texture, entity);
        const position_in_window = view.getConst(component.PositionInWindow, entity);

        try sdl.renderTexture(renderer, texture, null, .{
            .position = position_in_window,
            .size = try sdl.getTextureSize(texture),
        });
    }
}
