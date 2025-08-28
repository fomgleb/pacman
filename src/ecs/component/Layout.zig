const Vec2 = @import("game_kit").Vec2;

v: enum { left, center, right },
h: enum { top, center, bottom },
rel_offset: Vec2(f32) = .{ .x = 0, .y = 0 },
