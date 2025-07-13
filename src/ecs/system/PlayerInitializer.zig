const component = @import("../component.zig");
const c = @import("../../c.zig");
const Direction = @import("../../direction.zig").Direction;
const sdl = @import("../../sdl.zig");
const Vec2 = @import("../../Vec2.zig").Vec2;
const entt = @import("entt");

const texture_path = "resources/pacman.png";
const initial_direction = Direction.down;
const speed = 3.0;

texture: *c.SDL_Texture,

pub fn init(reg: *entt.Registry, renderer: *c.SDL_Renderer, pacman_entity: entt.Entity, grid: entt.Entity) !@This() {
    // component.Texture
    const pacman_texture: component.Texture = try sdl.loadTexture(renderer, "resources/pacman.png");
    try sdl.setTextureScaleMode(pacman_texture, .nearest);
    reg.replace(pacman_entity, pacman_texture);

    // component.GridCellPosition
    const grid_cells = reg.getConst(component.GridCells, grid);
    const pacman_spawn_pos = findPacmanSpawn(grid_cells) orelse return error.NoPacmanSpawn;
    const pacman_spawn_pos_f32 = pacman_spawn_pos.floatFromInt(f32);
    reg.replace(pacman_entity, component.GridCellPosition{ .current = pacman_spawn_pos_f32, .previous = pacman_spawn_pos_f32 });

    // component.MovableOnGrid
    reg.replace(pacman_entity, component.MovableOnGrid{
        .requested_speed = speed,
        .current_speed = speed,
        .requested_direction = initial_direction,
        .current_direction = initial_direction,
    });

    // component.GridMembership
    reg.replace(pacman_entity, component.GridMembership{ .grid_entity = grid });

    return .{ .texture = pacman_texture };
}

pub fn deinit(self: @This()) void {
    c.SDL_DestroyTexture(self.texture);
}

fn findPacmanSpawn(grid_cells: component.GridCells) ?Vec2(usize) {
    for (0..grid_cells.size.x) |x| {
        for (0..grid_cells.size.y) |y| {
            if (grid_cells.get(.{ .x = x, .y = y }) == .pacman_spawn) {
                return .{ .x = x, .y = y };
            }
        }
    }

    return null;
}
