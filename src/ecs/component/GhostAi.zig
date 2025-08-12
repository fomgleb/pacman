const std = @import("std");

timer: std.time.Timer,
find_path_period: u64,
find_path_chance: f32,

/// `find_path_chance` - A chance of finding the path to the pacman. The number from 0 to 1.
pub fn init(find_path_period_s: f32, find_path_chance: f32) !@This() {
    return .{
        .timer = try .start(),
        .find_path_period = @intFromFloat(find_path_period_s * std.time.ns_per_s),
        .find_path_chance = find_path_chance,
    };
}
