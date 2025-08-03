const component = @import("../component.zig");
const Rect = @import("../../Rect.zig").Rect;
const Vec2 = @import("../../Vec2.zig").Vec2;
const entt = @import("entt");

pub fn init(reg: *entt.Registry, window_size: Vec2(f32)) void {
    process(reg, window_size);
}

pub fn update(reg: *entt.Registry, events_holder: entt.Entity) void {
    if (reg.tryGetConst(component.WindowSizeChangedEvent, events_holder)) |e| {
        process(reg, e.new_value.floatFromInt(f32));
    }
}

fn process(reg: *entt.Registry, window_size: Vec2(f32)) void {
    var view = reg.view(.{
        component.BackgroundTag,
        component.GridMembership,
        component.RenderArea,
        component.ScreenSide,
    }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const grid = view.getConst(component.GridMembership, entity).grid_entity;
        const grid_area = reg.getConst(component.RenderArea, grid);
        const grid_cells = reg.getConst(component.GridCells, grid);
        const screen_side = view.getConst(component.ScreenSide, entity);
        const area = view.get(component.RenderArea, entity);

        const cell_size = grid_area.size.div(grid_cells.size.floatFromInt(f32));
        const background_cells = window_size.sub(grid_area.size).divNum(2).div(cell_size).ceil();

        area.* = switch (screen_side) {
            .up => .{
                .position = .{ .x = 0, .y = grid_area.position.y - background_cells.y * cell_size.y },
                .size = .{ .x = window_size.x, .y = background_cells.y * cell_size.y },
            },
            .down => .{
                .position = .{ .x = 0, .y = window_size.y - ((window_size.y - grid_area.size.y) / 2) },
                .size = .{ .x = window_size.x, .y = (window_size.y - grid_area.size.y) / 2 },
            },
            .left => .{
                .position = .{ .x = grid_area.position.x - background_cells.x * cell_size.x, .y = 0 },
                .size = .{ .x = background_cells.x * cell_size.x, .y = window_size.y },
            },
            .right => .{
                .position = .{ .x = window_size.x - ((window_size.x - grid_area.size.x) / 2), .y = 0 },
                .size = .{ .x = (window_size.x - grid_area.size.x) / 2, .y = window_size.y },
            },
        };
    }
}
