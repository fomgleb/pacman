const Direction = @import("../../direction.zig").Direction;
const component = @import("../component.zig");
const entt = @import("entt");

reg: *entt.Registry,
pacman_entity: entt.Entity,
events_holder_entity: entt.Entity,

pub fn update(self: @This()) void {
    const player_input_event = self.reg.tryGetConst(component.PlayerInputEvent, self.events_holder_entity) orelse return;
    const movable_on_grid = self.reg.get(component.MovableOnGrid, self.pacman_entity);
    movable_on_grid.desired_direction = player_input_event.direction;
}
