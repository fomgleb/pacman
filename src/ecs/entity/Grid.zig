const component = @import("../component.zig");
const entt = @import("entt");

pub fn init(reg: *entt.Registry) entt.Entity {
    const entity = reg.create();

    reg.add(entity, component.CenteredInWindowTag{});
    reg.add(entity, @as(component.AspectRatio, undefined));
    reg.add(entity, @as(component.GridCells, undefined));
    reg.add(entity, @as(component.RenderArea, undefined));

    return entity;
}
