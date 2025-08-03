const entity = @import("../entity.zig");
const component = @import("../component.zig");
const c = @import("../../c.zig");
const entt = @import("entt");

pub fn update(reg: *entt.Registry, delta_time: entt.Entity, text_creator: *entity.TextCreator) !void {
    var view = reg.view(.{ component.PlayerTag, component.DiedEvent }, .{});
    if (view.entityIterator().internal_it.slice.len == 0) return;

    reg.add(delta_time, component.StoppedTag{});
    _ = try text_creator.create("GAME OVER", .init(255, 0, 0, 255), .{ .v = .center, .h = .center }, 0.2);
    _ = try text_creator.create("Press Space to restart", .init(255, 255, 255, 255), .{ .v = .center, .h = .bottom, .rel_offset = .{ .x = 0, .y = -0.1 } }, 0.09);
}
