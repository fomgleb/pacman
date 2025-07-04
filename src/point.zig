pub fn Point(T: type) type {
    return struct {
        const Self = @This();

        x: T,
        y: T,

        pub fn as(self: Self, NewType: type) Point(NewType) {
            return Point(NewType){ .x = self.x, .y = self.y };
        }

        pub fn intCast(self: Self, NewType: type) Point(NewType) {
            return Point(NewType){ .x = @intCast(self.x), .y = @intCast(self.y) };
        }

        pub fn floatFromInt(self: Self, NewType: type) Point(NewType) {
            return Point(NewType){ .x = @floatFromInt(self.x), .y = @floatFromInt(self.y) };
        }
    };
}
