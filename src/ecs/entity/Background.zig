const component = @import("../component.zig");
const c = @import("../../c.zig");
const entt = @import("entt");

pub fn init(reg: *entt.Registry, grid: entt.Entity, texture: *c.SDL_Texture, screen_side: component.ScreenSide) entt.Entity {
    const background = reg.create();

    reg.add(background, @as(component.BackgroundTag, .{}));
    reg.add(background, @as(component.GridMembership, .{ .grid_entity = grid }));
    reg.add(background, @as(component.Texture, texture));
    reg.add(background, @as(component.RenderArea, undefined)); // Is set by some `Scaler` system
    reg.add(background, @as(component.ScreenSide, screen_side));

    return background;
}
