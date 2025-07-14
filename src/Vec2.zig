pub fn Vec2(T: type) type {
    return struct {
        const Self = @This();

        x: T,
        y: T,

        pub fn init(x: T, y: T) Self {
            return .{ .x = x, .y = y };
        }

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

        pub fn round(self: Self) Self {
            return .{ .x = @round(self.x), .y = @round(self.y) };
        }

        pub fn ceil(self: Self) Self {
            return .{ .x = @ceil(self.x), .y = @ceil(self.y) };
        }

        pub fn floor(self: Self) Self {
            return .{ .x = @floor(self.x), .y = @floor(self.y) };
        }

        pub fn mulNum(self: Self, num: T) Self {
            return .{ .x = self.x * num, .y = self.y * num };
        }

        pub fn divNum(self: Self, num: T) Self {
            return .{ .x = self.x / num, .y = self.y / num };
        }

        pub fn addNum(self: Self, num: T) Self {
            return .{ .x = self.x + num, .y = self.y + num };
        }

        pub fn subNum(self: Self, num: T) Self {
            return .{ .x = self.x - num, .y = self.y - num };
        }

        pub fn modNum(self: Self, num: T) Self {
            return .{ .x = self.x % num, .y = self.y % num };
        }

        pub fn mul(self: Self, other: Self) Self {
            return .{ .x = self.x * other.x, .y = self.y * other.y };
        }

        pub fn div(self: Self, other: Self) Self {
            return .{ .x = self.x / other.x, .y = self.y / other.y };
        }

        pub fn add(self: Self, other: Self) Self {
            return .{ .x = self.x + other.x, .y = self.y + other.y };
        }

        pub fn sub(self: Self, other: Self) Self {
            return .{ .x = self.x - other.x, .y = self.y - other.y };
        }

        pub fn mod(self: Self, other: Self) Self {
            return .{ .x = self.x % other.x, .y = self.y % other.y };
        }

        pub fn max(self: Self) T {
            return @max(self.x, self.y);
        }

        pub fn min(self: Self) T {
            return @min(self.x, self.y);
        }
    };
}
