const component = @import("../component.zig");
const entt = @import("entt");

pub fn init(reg: *entt.Registry) !entt.Entity {
    const entity = reg.create();
    reg.add(entity, try component.Timer.start());
    return entity;
}
