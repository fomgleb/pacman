const component = @import("../component.zig");
const entt = @import("entt");

pub fn init(
    reg: *entt.Registry,
    can_spawn_one: component.CanSpawnOne,
    grid: entt.Entity,
) entt.Entity {
    const entity = reg.create();

    reg.add(entity, @as(component.CanSpawnOne, can_spawn_one));
    reg.add(entity, @as(component.GridMembership, .{ .grid_entity = grid }));

    return entity;
}
