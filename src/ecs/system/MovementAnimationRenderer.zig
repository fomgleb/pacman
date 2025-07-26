const time = @import("std").time;
const component = @import("../component.zig");
const c = @import("../../c.zig");
const Rect = @import("../../Rect.zig").Rect;
const sdl = @import("../../sdl.zig");
const System = @import("../../System.zig");
const entt = @import("entt");

reg: *entt.Registry,
renderer: *c.SDL_Renderer,

pub fn update(self: *const @This()) error{SdlError}!void {
    var view = self.reg.view(.{
        component.MovableOnGrid,
        component.RenderArea,
        component.MovementAnimation,
    }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const render_area = view.getConst(component.RenderArea, entity);
        const movable_on_grid = view.getConst(component.MovableOnGrid, entity);
        const movement_animation = view.getConst(component.MovementAnimation, entity);

        const src_area = Rect(f32){
            .position = .{ .x = @round(movement_animation.current_frame_index) * movement_animation.sprite_size.x, .y = 0 },
            .size = movement_animation.sprite_size,
        };

        if (movement_animation.sprite_can_rotate) {
            const angle: f64 = switch (movable_on_grid.current_direction) {
                .up => -90,
                .down => 90,
                .left => 180,
                .right => 0,
            };

            try sdl.renderTextureRotated(self.renderer, movement_animation.sprite_sheet, src_area, render_area, angle, null, .none);
        } else {
            try sdl.renderTexture(self.renderer, movement_animation.sprite_sheet, src_area, render_area);
        }
    }
}

pub fn system(self: *const @This()) System {
    return System.init(self);
}
