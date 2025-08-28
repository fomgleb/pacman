const component = @import("../component.zig");
const sdl = @import("game_kit").sdl;
const entt = @import("entt");

pub fn update(reg: *entt.Registry, renderer: *sdl.Renderer) !void {
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
