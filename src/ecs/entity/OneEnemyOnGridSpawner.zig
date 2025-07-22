const component = @import("../component.zig");
const entt = @import("entt");

pub fn init(
    reg: *entt.Registry,
    enemy_spawner: component.CanSpawnOne,
    grid: entt.Entity,
) entt.Entity {
    const entity = reg.create();

    reg.add(entity, @as(component.CanSpawnOne, enemy_spawner));
    reg.add(entity, @as(component.GridMembership, .{ .grid_entity = grid }));

    return entity;
}
