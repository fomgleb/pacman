const std = @import("std");

is_spawned: bool,
spawn_delay: u64,
timer: std.time.Timer,

pub fn init(spawn_delay_s: f32) !@This() {
    return .{
        .is_spawned = false,
        .spawn_delay = @intFromFloat(spawn_delay_s * std.time.ns_per_s),
        .timer = try .start(),
    };
}
