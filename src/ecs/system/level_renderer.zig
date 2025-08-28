const component = @import("../component.zig");
const game_kit = @import("game_kit");
const Rect = game_kit.Rect;
const sdl = game_kit.sdl;
const Vec2 = game_kit.Vec2;
const entt = @import("entt");

pub fn update(
    reg: *entt.Registry,
    renderer: *sdl.Renderer,
    wall_texture: *sdl.Texture,
    pellet_texture: *sdl.Texture,
    grass_texture: *sdl.Texture,
) !void {
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
                    .pacman_spawn => try sdl.renderTexture(renderer, grass_texture, null, dst_render_area),
                    .pellet => {
                        try sdl.renderTexture(renderer, grass_texture, null, dst_render_area);
                        try sdl.renderTexture(renderer, pellet_texture, null, dst_render_area);
                    },
                    .empty => try sdl.renderTexture(renderer, grass_texture, null, dst_render_area),
                }
            }
        }
    }
}
