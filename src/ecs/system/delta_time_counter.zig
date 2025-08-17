const component = @import("../component.zig");
const entt = @import("entt");

pub fn update(reg: *entt.Registry, events_holder: entt.Entity, delta_time: entt.Entity) void {
    const delta_time_timer = reg.get(component.Timer, delta_time);
    const delta_time_value = delta_time_timer.lap();
    reg.add(events_holder, component.DeltaTimeMeasuredEvent{ .value = delta_time_value });
}
