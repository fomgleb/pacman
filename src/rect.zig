const Point = @import("point.zig").Point;

pub fn Rect(T: type) type {
    return struct {
        const Self = @This();

        position: Point(T),
        size: Point(T),

        pub fn floatFromInt(self: Self, NewType: type) Rect(NewType) {
            return Rect(NewType){
                .position = self.position.floatFromInt(NewType),
                .size = self.size.floatFromInt(NewType),
            };
        }
    };
}
