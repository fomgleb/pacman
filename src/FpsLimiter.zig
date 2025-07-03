const time = @import("std").time;
const Timer = time.Timer;
const FpsLimiter = @This();

timer: Timer,
max_ns_per_frame: u64,

pub fn init(desired_fps: u64) error{TimerUnsupported}!FpsLimiter {
    return FpsLimiter{
        .timer = try .start(),
        .max_ns_per_frame = time.ns_per_s / desired_fps,
    };
}

pub fn waitFrameEnd(self: *FpsLimiter) void {
    time.sleep(self.max_ns_per_frame -| self.timer.lap());
}
