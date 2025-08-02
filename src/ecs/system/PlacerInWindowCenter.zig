const component = @import("../component.zig");
const Rect = @import("../../Rect.zig").Rect;
const System = @import("../../System.zig");
const Vec2 = @import("../../Vec2.zig").Vec2;
const entt = @import("entt");

reg: *entt.Registry,
events_holder: entt.Entity,

pub fn update(self: *const @This()) void {
    const new_window_size: Vec2(f32) = (self.reg.tryGetConst(component.WindowSizeChangedEvent, self.events_holder) orelse return).new_value.floatFromInt(f32);

    var view = self.reg.view(.{
        component.CenteredInWindowTag,
        component.RenderArea,
        component.AspectRatio,
    }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const aspect_ratio = view.getConst(component.AspectRatio, entity);
        const render_area = view.get(component.RenderArea, entity);

        const scale = new_window_size.div(aspect_ratio.value.floatFromInt(f32)).min();
        const area_size = aspect_ratio.value.floatFromInt(f32).mulNum(scale);
        const area_pos = new_window_size.sub(area_size).divNum(2);
        render_area.* = .{ .position = area_pos, .size = area_size };
    }
}

pub fn system(self: *const @This()) System {
    return System.init(self);
}
