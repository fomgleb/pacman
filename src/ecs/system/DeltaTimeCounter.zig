const component = @import("../component.zig");
const System = @import("../../System.zig");
const entt = @import("entt");

reg: *entt.Registry,
events_holder_entity: entt.Entity,
delta_time_entity: entt.Entity,

pub fn update(self: *const @This()) void {
    const delta_time_timer = self.reg.get(component.Timer, self.delta_time_entity);
    self.reg.add(self.events_holder_entity, component.DeltaTimeMeasuredEvent{ .value = delta_time_timer.lap() });
}

pub fn system(self: *const @This()) System {
    return System.init(self);
}
