pub const Direction = enum {
    up,
    down,
    left,
    right,

    pub fn isOppositeOf(self: Direction, other: Direction) bool {
        return switch (self) {
            .up => other == .down,
            .down => other == .up,
            .left => other == .right,
            .right => other == .left,
        };
    }

    pub fn opposite(self: Direction) Direction {
        return switch (self) {
            .up => .down,
            .down => .up,
            .left => .right,
            .right => .left,
        };
    }
};
