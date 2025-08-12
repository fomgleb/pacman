const std = @import("std");
const EntityCreator = @import("../../EntityCreator.zig");

entity_creator: EntityCreator,
is_spawned: bool,
spawn_delay: u64,
timer: std.time.Timer,

pub fn init(entity_creator: EntityCreator, spawn_delay_s: f32) !@This() {
    return .{
        .entity_creator = entity_creator,
        .is_spawned = false,
        .spawn_delay = @intFromFloat(spawn_delay_s * std.time.ns_per_s),
        .timer = try .start(),
    };
}
