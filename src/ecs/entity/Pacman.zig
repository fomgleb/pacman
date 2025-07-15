const component = @import("../component.zig");
const entt = @import("entt");

pub fn init(reg: *entt.Registry) entt.Entity {
    const pacman = reg.create();

    reg.add(pacman, component.PlayerTag{});
    reg.add(pacman, @as(component.RenderArea, undefined));
    reg.add(pacman, @as(component.Texture, undefined));
    reg.add(pacman, @as(component.GridCellPosition, undefined));
    reg.add(pacman, @as(component.MovableOnGrid, undefined));
    reg.add(pacman, @as(component.GridMembership, undefined));
    reg.add(pacman, @as(component.PelletsEater, undefined));

    return pacman;
}
