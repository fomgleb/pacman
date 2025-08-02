value: f32,

pub fn init(comptime value: f32) @This() {
    if (value < 0 or value > 1) @compileError("`value` must be in range from 0 to 1");
    return .{ .value = value };
}
