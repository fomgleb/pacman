const c = @import("c.zig");
const LinearController = @This();

position: c.SDL_FPoint = .{ .x = 100, .y = 100 },
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

pub fn update(self: *LinearController) void {
    if (self.desired_direction != self.actual_direction) {
        self.actual_direction = self.desired_direction;
    }

    switch (self.desired_direction) {
        .up => self.position.y -= self.speed,
        .down => self.position.y += self.speed,
        .left => self.position.x -= self.speed,
        .right => self.position.x += self.speed,
    }
}
