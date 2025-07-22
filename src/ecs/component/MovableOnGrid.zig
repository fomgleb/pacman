const Direction = @import("../../Direction.zig").Direction;

requested_speed: f32,
current_speed: f32,
requested_direction: Direction,
current_direction: Direction,

pub fn init(speed: f32, direction: Direction) @This() {
    return .{
        .requested_speed = speed,
        .current_speed = speed,
        .requested_direction = direction,
        .current_direction = direction,
    };
}
