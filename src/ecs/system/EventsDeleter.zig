const entt = @import("entt");

reg: *entt.Registry,
events_holder_entity: entt.Entity,

pub fn update(self: @This()) void {
    self.reg.removeAll(self.events_holder_entity);
}
