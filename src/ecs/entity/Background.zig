const component = @import("../component.zig");
const sdl = @import("game_kit").sdl;
const entt = @import("entt");

pub fn init(reg: *entt.Registry, grid: entt.Entity, texture: *sdl.Texture, screen_side: component.ScreenSide) entt.Entity {
    const background = reg.create();

    reg.add(background, @as(component.BackgroundTag, .{}));
    reg.add(background, @as(component.GridMembership, .{ .grid_entity = grid }));
    reg.add(background, @as(component.Texture, texture));
    reg.add(background, @as(component.RenderArea, undefined)); // Is set by some `Scaler` system
    reg.add(background, @as(component.ScreenSide, screen_side));

    return background;
}
