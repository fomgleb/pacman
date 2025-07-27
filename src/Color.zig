r: u8,
g: u8,
b: u8,
a: u8,

pub fn init(r: u8, g: u8, b: u8, a: u8) @This() {
    return .{ .r = r, .g = g, .b = b, .a = a };
}
