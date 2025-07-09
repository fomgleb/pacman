const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const Point = @import("point.zig").Point;

pub fn Array2D(T: type) type {
    return struct {
        const Self = @This();

        mem: []T,
        size: Point(usize),
        allocator: Allocator,

        pub fn init(allocator: Allocator, size: Point(usize)) !Self {
            return Self{
                .mem = try allocator.alloc(T, size.x * size.y),
                .size = size,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: Self) void {
            self.allocator.free(self.mem);
        }

        pub fn get(self: Self, position: Point(usize)) T {
            assert(position.x < self.size.x and position.y < self.size.y);
            return self.mem[position.y * self.size.x + position.x];
        }

        pub fn getPtr(self: Self, position: Point(usize)) *T {
            assert(position.x < self.size.x and position.y < self.size.y);
            return &self.mem[position.y * self.size.x + position.x];
        }

        pub fn getRow(self: Self, y: usize) []T {
            assert(y < self.size.y);
            return self.mem[(y * self.size.x)..][0..self.size.x];
        }

        pub fn set(self: Self, position: Point(usize), value: T) void {
            assert(position.x < self.size.x and position.y < self.size.y);
            self.mem[position.y * self.size.x + position.x] = value;
        }
    };
}
