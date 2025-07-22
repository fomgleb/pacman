const std = @import("std");

timer: std.time.Timer,
change_move_direction_delay: u64,

pub fn init(change_move_direction_delay_s: f32) !@This() {
    return .{
        .timer = try .start(),
        .change_move_direction_delay = @intFromFloat(change_move_direction_delay_s * std.time.ns_per_s),
    };
}
