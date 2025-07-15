const Vec2 = @import("../../Vec2.zig").Vec2;
const AspectRatio = @This();

value: Vec2(u16),

pub fn init(raw_aspect_ratio: Vec2(u16)) AspectRatio {
    const simplified_aspect_ratio = simplifyAspectRatio(raw_aspect_ratio);
    return AspectRatio{ .value = simplified_aspect_ratio };
}

fn simplifyAspectRatio(ratio: Vec2(u16)) Vec2(u16) {
    const divisor = gcd(ratio.x, ratio.y);
    return ratio.divNum(divisor);
}

// Helper to simplify a fraction (aspect ratio)
fn gcd(a: u16, b: u16) u16 {
    return if (b == 0) a else gcd(b, a % b);
}
