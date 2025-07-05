const time = @import("std").time;
const Point = @import("point.zig").Point;
const LinearController = @This();

speed: f32,
desired_direction: Direction,
actual_direction: Direction,

const Direction = enum {
    up,
    down,
    left,
    right,
};

pub fn init(speed: f32, initial_direction: Direction) LinearController {
    return LinearController{
        .speed = speed,
        .desired_direction = initial_direction,
        .actual_direction = initial_direction,
    };
}

pub fn update(self: *LinearController, delta_time: u64, old_position: Point(f32)) Point(f32) {
    if (self.desired_direction != self.actual_direction) {
        self.actual_direction = self.desired_direction;
    }

    const delta_time_f32: f32 = @floatFromInt(delta_time);
    const step_pixels = self.speed * (delta_time_f32 / time.ns_per_s);
    var new_position = old_position;
    switch (self.desired_direction) {
        .up => new_position.y -= step_pixels,
        .down => new_position.y += step_pixels,
        .left => new_position.x -= step_pixels,
        .right => new_position.x += step_pixels,
    }

    return new_position;
}
