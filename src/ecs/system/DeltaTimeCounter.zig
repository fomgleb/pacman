const component = @import("../component.zig");
const System = @import("../../System.zig");
const entt = @import("entt");

reg: *entt.Registry,
events_holder: entt.Entity,
delta_time: entt.Entity,

pub fn update(self: *const @This()) void {
    const delta_time_timer = self.reg.get(component.Timer, self.delta_time);
    const delta_time_value = if (self.reg.has(component.StoppedTag, self.delta_time)) 0 else delta_time_timer.lap();
    self.reg.add(self.events_holder, component.DeltaTimeMeasuredEvent{ .value = delta_time_value });
}

pub fn system(self: *const @This()) System {
    return System.init(self);
}
