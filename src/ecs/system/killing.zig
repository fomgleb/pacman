const component = @import("../component.zig");
const sdl = @import("../../sdl.zig");
const Vec2 = @import("../../Vec2.zig").Vec2;
const entt = @import("entt");

const collision_size = Vec2(f32){ .x = 0.4, .y = 0.4 };

pub fn update(reg: *entt.Registry) void {
    var view = reg.view(.{ component.Killer, component.PositionOnGrid }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const position_on_grid = view.getConst(component.PositionOnGrid, entity);
        const victims = view.getConst(component.Killer, entity).victims;
        var victims_iterator = victims.iterator();
        while (victims_iterator.next()) |victim| {
            if (reg.has(component.DeadTag, victim.key_ptr.*)) continue;
            const victim_position_on_grid = reg.getConst(component.PositionOnGrid, victim.key_ptr.*);
            const collided = sdl.hasRectIntersectionFloat(
                .{ .position = position_on_grid.current, .size = collision_size },
                .{ .position = victim_position_on_grid.current, .size = collision_size },
            );
            if (collided) {
                reg.add(victim.key_ptr.*, component.DeadTag{});
            }
        }
    }
}
