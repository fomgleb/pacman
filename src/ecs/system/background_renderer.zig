const component = @import("../component.zig");
const c = @import("../../c.zig");
const Rect = @import("../../Rect.zig").Rect;
const sdl = @import("../../sdl.zig");
const Vec2 = @import("../../Vec2.zig").Vec2;
const entt = @import("entt");

pub fn update(reg: *entt.Registry, renderer: *c.SDL_Renderer) !void {
    var view = reg.view(.{
        component.BackgroundTag,
        component.GridMembership,
        component.Texture,
        component.RenderArea,
    }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const grid = view.getConst(component.GridMembership, entity).grid_entity;
        const grid_cells = view.getConst(component.GridCells, grid);
        const grid_area = view.getConst(component.RenderArea, grid);

        const texture = view.getConst(component.Texture, entity);
        const area = view.getConst(component.RenderArea, entity);

        const cell_size = grid_area.size.div(grid_cells.size.floatFromInt(f32));

        const background_cells = area.size.div(cell_size).ceil().intFromFloat(usize);
        for (0..background_cells.x) |x| {
            for (0..background_cells.y) |y| {
                const cell_pos_f32 = Vec2(usize).init(x, y).floatFromInt(f32);
                const dst_area = Rect(f32){
                    .position = cell_size.mul(cell_pos_f32).add(area.position),
                    .size = cell_size,
                };

                try sdl.renderTexture(renderer, texture, null, dst_area);
            }
        }
    }
}
