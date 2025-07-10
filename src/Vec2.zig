pub fn Vec2(T: type) type {
    return struct {
        const Self = @This();

        x: T,
        y: T,

        pub fn as(self: Self, NewType: type) Vec2(NewType) {
            return Vec2(NewType){ .x = self.x, .y = self.y };
        }

        pub fn intCast(self: Self, NewType: type) Vec2(NewType) {
            return Vec2(NewType){ .x = @intCast(self.x), .y = @intCast(self.y) };
        }

        pub fn floatFromInt(self: Self, NewType: type) Vec2(NewType) {
            return Vec2(NewType){ .x = @floatFromInt(self.x), .y = @floatFromInt(self.y) };
        }

        pub fn intFromFloat(self: Self, NewType: type) Vec2(NewType) {
            return Vec2(NewType){ .x = @intFromFloat(self.x), .y = @intFromFloat(self.y) };
        }
    };
}
