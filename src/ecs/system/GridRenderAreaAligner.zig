const component = @import("../component.zig");
const System = @import("../../System.zig");
const entt = @import("entt");

reg: *entt.Registry,
events_holder: entt.Entity,

pub fn update(self: *const @This()) void {
    if (!self.reg.has(component.WindowSizeChangedEvent, self.events_holder)) return;

    var view = self.reg.view(.{ component.GridCells, component.RenderArea }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const grid_cells = view.getConst(component.GridCells, entity);
        const render_area = view.get(component.RenderArea, entity);

        const remainder = render_area.size.mod(grid_cells.size.intCast(u32));
        render_area.position = render_area.position.add(remainder.divNum(2));
        render_area.size = render_area.size.sub(remainder);
    }
}

pub fn system(self: *const @This()) System {
    return System.init(self);
}
