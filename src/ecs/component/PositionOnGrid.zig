const Vec2 = @import("game_kit").Vec2;

current: Vec2(f32),
previous: Vec2(f32),

pub fn init(initial_position: Vec2(f32)) @This() {
    return .{
        .current = initial_position,
        .previous = initial_position,
    };
}
