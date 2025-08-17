const std = @import("std");
const RelativeSize = @This();

w: ?f32,
h: ?f32,

pub fn init(w: ?f32, h: ?f32) RelativeSize {
    if (w == null and h == null) @panic("Either `w` or `h` must be not null");
    if (w) |w_| if (w_ < 0 or w_ > 1) @panic("`w` must be in range from 0 to 1");
    if (h) |h_| if (h_ < 0 or h_ > 1) @panic("`h` must be in range from 0 to 1");

    return .{ .w = w, .h = h };
}
