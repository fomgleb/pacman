const component = @import("../component.zig");
const c = @import("../../c.zig");
const Direction = @import("../../Direction.zig").Direction;
const asset_loader = @import("../../asset_loader.zig");
const sdl = @import("../../sdl.zig");
const Vec2 = @import("../../Vec2.zig").Vec2;
const entt = @import("entt");

const texture_path = "resources/pacman.png";
const initial_direction = Direction.down;
const speed = 3.0;
const sprite_sheet_path = "resources/pacman/pacman-move.png";
const sprite_width = 17;
const sprite_fps = speed * 40.0;
const sprite_can_rotate = true;

pacman_move_sprite_sheet: *c.SDL_Texture,

pub fn init(reg: *entt.Registry, renderer: *c.SDL_Renderer, pacman_entity: entt.Entity, grid: entt.Entity) !@This() {
    // component.GridCellPosition
    const grid_cells = reg.getConst(component.GridCells, grid);
    const pacman_spawn_pos = findPacmanSpawn(grid_cells) orelse return error.NoPacmanSpawn;
    const pacman_spawn_pos_f32 = pacman_spawn_pos.floatFromInt(f32);
    reg.replace(pacman_entity, component.PositionOnGrid{ .current = pacman_spawn_pos_f32, .previous = pacman_spawn_pos_f32 });

    // component.MovableOnGrid
    reg.replace(pacman_entity, component.MovableOnGrid{
        .requested_speed = speed,
        .current_speed = speed,
        .requested_direction = initial_direction,
        .current_direction = initial_direction,
    });

    // component.GridMembership
    reg.replace(pacman_entity, component.GridMembership{ .grid_entity = grid });

    // component.MovementAnimation
    const move_sprite_sheet = try sdl.loadTextureIo(renderer, try asset_loader.openSdlIoStream(sprite_sheet_path), true);
    try sdl.setTextureScaleMode(move_sprite_sheet, .nearest);
    reg.replace(pacman_entity, try component.MovementAnimation.init(move_sprite_sheet, sprite_width, sprite_fps, sprite_can_rotate));

    return .{ .pacman_move_sprite_sheet = move_sprite_sheet };
}

pub fn deinit(self: @This()) void {
    c.SDL_DestroyTexture(self.pacman_move_sprite_sheet);
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
