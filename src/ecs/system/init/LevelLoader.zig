const std = @import("std");
const log = std.log.scoped(.@"Level Loader");
const Point = @import("../../../point.zig").Point;
const GridCell = @import("../../../GridCell.zig").GridCell;
const Allocator = std.mem.Allocator;
const component = @import("../../component.zig");
const entt = @import("entt");

grid_members: component.GridCells,

const max_level_file_size = 1_000_000_000;

pub fn init(allocator: Allocator, reg: *entt.Registry, level_file_path: []const u8, grid_entity: entt.Entity) !@This() {
    const level_file = try std.fs.cwd().readFileAlloc(allocator, level_file_path, max_level_file_size);
    const level_size = try getLevelDimensions(level_file);

    const aspect_ratio = reg.get(component.AspectRatio, grid_entity);
    aspect_ratio.* = component.AspectRatio.init(level_size);

    const grid_size = reg.get(component.GridSize, grid_entity);
    grid_size.* = component.GridSize{ .x = level_size.x, .y = level_size.y };

    const grid_cells = reg.get(component.GridCells, grid_entity);
    grid_cells.* = try component.GridCells.init(allocator, level_size.as(usize));

    var row_iterator = std.mem.splitScalar(u8, level_file, '\n');
    var row_idx: usize = 0;
    while (row_iterator.next()) |row| : (row_idx += 1) {
        for (row, 0..) |character, column_idx| {
            const new_grid_cell: GridCell = switch (character) {
                '#' => .wall,
                'P' => .pacman_spawn,
                ' ' => .empty,
                else => {
                    log.err("Failed to parse `{}` in {s}: Illegal symbol (row: {}; col: {})", .{ character, level_file_path, row_idx + 1, column_idx + 1 });
                    return error.BadLevelFile;
                },
            };
            grid_cells.set(.{ .x = column_idx, .y = row_idx }, new_grid_cell);
        }
    }

    return .{ .grid_members = grid_cells.* };
}

pub fn deinit(self: @This()) void {
    self.grid_members.deinit();
}

fn getLevelDimensions(level_content: []const u8) error{NotAllRowSizesAreSame}!Point(u16) {
    var rows = std.mem.splitScalar(u8, level_content, '\n');

    var width: ?u16 = null;
    var height: u16 = 0;
    while (rows.next()) |row_size| {
        if (row_size.len == 0) continue; // skip empty lines

        height += 1;
        if (width) |h| {
            if (h != row_size.len)
                return error.NotAllRowSizesAreSame;
        } else {
            width = @intCast(row_size.len);
        }
    }

    return Point(u16){ .x = width.?, .y = height };
}
