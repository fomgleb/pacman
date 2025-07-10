const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const Vec2 = @import("Vec2.zig").Vec2;

pub fn Array2D(T: type) type {
    return struct {
        const Self = @This();

        mem: []T,
        size: Vec2(usize),
        allocator: Allocator,

        pub fn init(allocator: Allocator, size: Vec2(usize)) !Self {
            return Self{
                .mem = try allocator.alloc(T, size.x * size.y),
                .size = size,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: Self) void {
            self.allocator.free(self.mem);
        }

        pub fn get(self: Self, position: Vec2(usize)) T {
            assert(position.x < self.size.x and position.y < self.size.y);
            return self.mem[position.y * self.size.x + position.x];
        }

        pub fn getPtr(self: Self, position: Vec2(usize)) *T {
            assert(position.x < self.size.x and position.y < self.size.y);
            return &self.mem[position.y * self.size.x + position.x];
        }

        pub fn getRow(self: Self, y: usize) []T {
            assert(y < self.size.y);
            return self.mem[(y * self.size.x)..][0..self.size.x];
        }

        pub fn set(self: Self, position: Vec2(usize), value: T) void {
            assert(position.x < self.size.x and position.y < self.size.y);
            self.mem[position.y * self.size.x + position.x] = value;
        }
    };
}
