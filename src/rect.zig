const Vec2 = @import("Vec2.zig").Vec2;

pub fn Rect(T: type) type {
    return struct {
        const Self = @This();

        position: Vec2(T),
        size: Vec2(T),

        pub fn floatFromInt(self: Self, NewType: type) Rect(NewType) {
            return Rect(NewType){
                .position = self.position.floatFromInt(NewType),
                .size = self.size.floatFromInt(NewType),
            };
        }
    };
}
