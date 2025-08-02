const Vec2 = @import("../../Vec2.zig").Vec2;

v: enum { left, center, right },
h: enum { top, center, bottom },
rel_offset: Vec2(f32) = .{ .x = 0, .y = 0 },
