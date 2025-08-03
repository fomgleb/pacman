const component = @import("../component.zig");
const c = @import("../../c.zig");
const Rect = @import("../../Rect.zig").Rect;
const sdl = @import("../../sdl.zig");
const Vec2 = @import("../../Vec2.zig").Vec2;
const entt = @import("entt");

pub fn update(reg: *entt.Registry, renderer: *c.SDL_Renderer, wall_texture: *c.SDL_Texture, pellet_texture: *c.SDL_Texture) !void {
    var view = reg.view(.{ component.GridCells, component.RenderArea }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const grid_cells = view.getConst(component.GridCells, entity);
        const render_area = view.getConst(component.RenderArea, entity);

        const cell_size = render_area.size.div(grid_cells.size.floatFromInt(f32));

        try sdl.setRenderDrawColor(renderer, 0, 0, 0, 255);
        for (0..grid_cells.size.x) |x| {
            for (0..grid_cells.size.y) |y| {
                const curr_cell_pos_f32 = Vec2(usize).init(x, y).floatFromInt(f32);
                const dst_render_area = Rect(f32){
                    .position = cell_size.mul(curr_cell_pos_f32).add(render_area.position),
                    .size = cell_size,
                };
                switch (grid_cells.get(.{ .x = x, .y = y })) {
                    .wall => try sdl.renderTexture(renderer, wall_texture, null, dst_render_area),
                    .pacman_spawn => {},
                    .pellet => try sdl.renderTexture(renderer, pellet_texture, null, dst_render_area),
                    .empty => {},
                }
            }
        }
    }
}
