const component = @import("../component.zig");
const Direction = @import("../../Direction.zig").Direction;
const System = @import("../../System.zig");
const entt = @import("entt");

reg: *entt.Registry,
events_holder: entt.Entity,
pacman: entt.Entity,

pub fn update(self: *const @This()) void {
    const player_input_event = self.reg.tryGetConst(component.PlayerInputEvent, self.events_holder) orelse return;
    const movable_on_grid = self.reg.get(component.MovableOnGrid, self.pacman);
    movable_on_grid.requested_direction = player_input_event.direction;
}

pub fn system(self: *const @This()) System {
    return System.init(self);
}
