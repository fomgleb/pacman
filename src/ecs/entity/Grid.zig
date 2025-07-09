const component = @import("../component.zig");
const entt = @import("entt");

pub fn init(reg: *entt.Registry) entt.Entity {
    const entity = reg.create();

    reg.add(entity, component.CenteredInWindowTag{});
    reg.add(entity, component.AspectRatio{ .h = undefined, .w = undefined });
    reg.add(entity, component.GridSize{ .x = undefined, .y = undefined });
    reg.add(entity, component.GridMembers{ .mem = undefined, .size = undefined, .allocator = undefined });
    reg.add(entity, component.RenderArea{ .position = undefined, .size = undefined });

    return entity;
}
