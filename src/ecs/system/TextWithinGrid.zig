const time = @import("std").time;
const component = @import("../component.zig");
const c = @import("../../c.zig");
const Rect = @import("../../Rect.zig").Rect;
const sdl = @import("../../sdl.zig");
const System = @import("../../System.zig");
const Vec2 = @import("../../Vec2.zig").Vec2;
const entt = @import("entt");

reg: *entt.Registry,

pub fn update(self: *const @This()) error{SdlError}!void {
    var view = self.reg.view(.{
        component.TextTag,
        component.Texture,
        component.PositionInWindow,
        component.GridMembership,
        component.Layout,
    }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const position_in_window = view.get(component.PositionInWindow, entity);
        const layout = view.getConst(component.Layout, entity);
        const grid = view.getConst(component.GridMembership, entity).grid_entity;
        const grid_area = view.getConst(component.RenderArea, grid);
        const text_size = try sdl.getTextureSize(view.getConst(component.Texture, entity));

        position_in_window.* = .{
            .x = switch (layout.v) {
                .left => grid_area.position.x,
                .center => (grid_area.position.x + grid_area.size.x / 2) - (text_size.x / 2),
                .right => grid_area.position.x + grid_area.size.x - text_size.x,
            },
            .y = switch (layout.h) {
                .top => grid_area.position.y,
                .center => (grid_area.position.y + grid_area.size.y / 2) - (text_size.y / 2),
                .bottom => grid_area.position.y + grid_area.size.y - text_size.y,
            },
        };
        position_in_window.* = position_in_window.add(layout.offset);
    }
}

pub fn system(self: *const @This()) System {
    return System.init(self);
}
