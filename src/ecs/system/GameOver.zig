const entity = @import("../entity.zig");
const component = @import("../component.zig");
const c = @import("../../c.zig");
const System = @import("../../System.zig");
const entt = @import("entt");

reg: *entt.Registry,
events_holder: entt.Entity,
delta_time: entt.Entity,
text_creator: *entity.TextCreator,

pub fn init(reg: *entt.Registry, events_holder: entt.Entity, delta_time: entt.Entity, text_creator: *entity.TextCreator) @This() {
    return .{
        .reg = reg,
        .events_holder = events_holder,
        .delta_time = delta_time,
        .text_creator = text_creator,
    };
}

pub fn update(self: *const @This()) !void {
    var view = self.reg.view(.{ component.PlayerTag, component.DiedEvent }, .{});
    if (view.entityIterator().internal_it.slice.len == 0) return;

    self.reg.add(self.delta_time, component.StoppedTag{});
    _ = try self.text_creator.create("GAME OVER", .init(255, 0, 0, 255), .{ .v = .center, .h = .center }, 0.2);
    _ = try self.text_creator.create("Press Space to restart", .init(255, 255, 255, 255), .{ .v = .center, .h = .bottom, .offset = .{ .x = 0, .y = -50 } }, 0.09);
}

pub fn system(self: *const @This()) System {
    return System.init(self);
}
