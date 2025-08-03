const component = @import("../component.zig");
const Direction = @import("../../Direction.zig").Direction;
const entt = @import("entt");

pub fn update(reg: *entt.Registry, events_holder: entt.Entity, pacman: entt.Entity) void {
    const player_input_event = reg.tryGetConst(component.PlayerInputEvent, events_holder) orelse return;
    const movable_on_grid = reg.get(component.MovableOnGrid, pacman);
    movable_on_grid.requested_direction = player_input_event.direction;
}
