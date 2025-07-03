const time = @import("std").time;
const c = @import("c.zig");
const LinearController = @This();

position: c.SDL_FPoint = .{ .x = 100, .y = 100 },
/// A number of pixels per second.
speed: u32,
desired_direction: Direction,
actual_direction: Direction,

const Direction = enum {
    up,
    down,
    left,
    right,
};

pub fn init(speed: u32, initial_direction: Direction) LinearController {
    return LinearController{
        .speed = speed,
        .desired_direction = initial_direction,
        .actual_direction = initial_direction,
    };
}

pub fn update(self: *LinearController, delta_time: u64) void {
    if (self.desired_direction != self.actual_direction) {
        self.actual_direction = self.desired_direction;
    }

    const delta_time_f32: f32 = @floatFromInt(delta_time);
    const speed_f32: f32 = @floatFromInt(self.speed);
    const step_pixels = speed_f32 * (delta_time_f32 / time.ns_per_s);
    switch (self.desired_direction) {
        .up => self.position.y -= step_pixels,
        .down => self.position.y += step_pixels,
        .left => self.position.x -= step_pixels,
        .right => self.position.x += step_pixels,
    }
}
