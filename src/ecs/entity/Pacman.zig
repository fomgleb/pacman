const component = @import("../component.zig");
const sdl = @import("../../sdl.zig");
const c = @import("../../c.zig");
const entt = @import("entt");

texture: *c.SDL_Texture,
entity: entt.Entity,

pub fn init(reg: *entt.Registry, renderer: *c.SDL_Renderer) error{SdlError}!@This() {
    const texture = try sdl.loadTexture(renderer, "resources/pacman.png");
    try sdl.setTextureScaleMode(texture, .nearest);

    const pacman_entity = reg.create();
    reg.add(pacman_entity, component.PlayerTag{});
    reg.add(pacman_entity, component.RenderArea{ .position = .{ .x = 0, .y = 0 }, .size = .{ .x = 0, .y = 0 } });
    reg.add(pacman_entity, texture);
    reg.add(pacman_entity, component.GridCellPosition{ .current = .{ .x = 5, .y = 5 }, .previous = .{ .x = 5, .y = 5 } });
    reg.add(pacman_entity, component.MovableOnGrid{ .desired_direction = .right, .real_direction = .right, .speed = 3 });

    return .{ .texture = texture, .entity = pacman_entity };
}

pub fn deinit(self: *@This()) void {
    c.SDL_DestroyTexture(self.texture);
}
