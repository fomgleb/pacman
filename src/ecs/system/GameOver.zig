const component = @import("../component.zig");
const System = @import("../../System.zig");
const entt = @import("entt");

reg: *entt.Registry,
events_holder: entt.Entity,

pub fn update(self: *const @This()) !void {
    var view = self.reg.view(.{ component.PlayerTag, component.KilledTag }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |_| {
        self.reg.addOrReplace(self.events_holder, component.QuitEvent{});
    }
}

pub fn system(self: *const @This()) System {
    return System.init(self);
}
