const component = @import("../component.zig");
const game_kit = @import("game_kit");
const Rect = game_kit.Rect;
const Vec2 = game_kit.Vec2;
const entt = @import("entt");

pub fn init(reg: *entt.Registry, window_size: Vec2(f32)) void {
    process(reg, window_size);
}

pub fn update(reg: *entt.Registry, events_holder: entt.Entity) void {
    if (reg.tryGetConst(component.WindowSizeChangedEvent, events_holder)) |e| {
        process(reg, e.new_value.floatFromInt(f32));
    }
}

fn process(reg: *entt.Registry, window_size: Vec2(f32)) void {
    var view = reg.view(.{
        component.CenteredInWindowTag,
        component.RenderArea,
        component.AspectRatio,
    }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const aspect_ratio = view.getConst(component.AspectRatio, entity);
        const render_area = view.get(component.RenderArea, entity);

        const scale = window_size.div(aspect_ratio.value.floatFromInt(f32)).min();
        const area_size = aspect_ratio.value.floatFromInt(f32).mulNum(scale);
        const area_pos = window_size.sub(area_size).divNum(2);
        render_area.* = .{ .position = area_pos, .size = area_size };
    }
}
