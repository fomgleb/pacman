const Vec2 = @import("../../Vec2.zig").Vec2;
const AspectRatio = @This();

w: u16,
h: u16,

pub fn init(raw_aspect_ratio: Vec2(u16)) AspectRatio {
    const simplified_aspect_ratio = simplifyAspectRatio(raw_aspect_ratio);
    return AspectRatio{
        .w = simplified_aspect_ratio.x,
        .h = simplified_aspect_ratio.y,
    };
}

fn simplifyAspectRatio(ratio: Vec2(u16)) Vec2(u16) {
    const divisor = gcd(ratio.x, ratio.y);
    return Vec2(u16){ .x = ratio.x / divisor, .y = ratio.y / divisor };
}

// Helper to simplify a fraction (aspect ratio)
fn gcd(a: u16, b: u16) u16 {
    return if (b == 0) a else gcd(b, a % b);
}
