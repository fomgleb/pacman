const time = @import("std").time;
const component = @import("../component.zig");
const System = @import("../../System.zig");
const entt = @import("entt");

reg: *entt.Registry,
fps: entt.Entity,
max_ns_per_frame: u64,

pub fn init(reg: *entt.Registry, fps: entt.Entity, desired_fps: u64) @This() {
    return @This(){
        .reg = reg,
        .fps = fps,
        .max_ns_per_frame = time.ns_per_s / desired_fps,
    };
}

pub fn update(self: *const @This()) void {
    const fps_timer = self.reg.get(component.Timer, self.fps);
    time.sleep(self.max_ns_per_frame -| fps_timer.lap());
}

pub fn system(self: *const @This()) System {
    return System.init(self);
}
