const std = @import("std");
const time = std.time;
const sleep = std.Thread.sleep;
const FpsLimiter = @This();

timer: time.Timer,
max_ns_per_frame: u64,

pub fn init(required_fps: u64) !FpsLimiter {
    return @This(){
        .timer = try time.Timer.start(),
        .max_ns_per_frame = time.ns_per_s / required_fps,
    };
}

pub fn waitFrameEnd(self: *FpsLimiter) void {
    sleep(self.max_ns_per_frame -| self.timer.lap());
}
