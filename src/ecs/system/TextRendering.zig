const component = @import("../component.zig");
const sdl = @import("../../sdl.zig");
const System = @import("../../System.zig");
const entt = @import("entt");

reg: *entt.Registry,

pub fn update(self: *const @This()) !void {
    var view = self.reg.view(.{ component.Texture, component.PositionInWindow }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const texture = view.getConst(component.Texture, entity);
        const position_in_window = view.getConst(component.PositionInWindow, entity);

        try sdl.renderTexture((try sdl.getRendererFromTexture(texture)), texture, null, .{
            .position = position_in_window,
            .size = try sdl.getTextureSize(texture),
        });
    }
}

pub fn system(self: *const @This()) System {
    return System.init(self);
}
