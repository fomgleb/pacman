const Point = @import("../../point.zig").Point;
const component = @import("../component.zig");
const entt = @import("entt");
const Grid = @This();

pub fn init(reg: *entt.Registry, size: Point(u16)) entt.Entity {
    const entity = reg.create();
    reg.add(entity, component.CenteredInWindowTag{});
    reg.add(entity, component.AspectRatio.init(size));
    reg.add(entity, component.GridSize{ .x = size.x, .y = size.y });
    reg.add(entity, component.RenderArea{ .position = .{ .x = 0, .y = 0 }, .size = .{ .x = 0, .y = 0 } });
    return entity;
}
