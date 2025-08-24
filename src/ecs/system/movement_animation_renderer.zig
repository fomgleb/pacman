const time = @import("std").time;
const component = @import("../component.zig");
const c = @import("../../c.zig").c;
const Rect = @import("../../Rect.zig").Rect;
const sdl = @import("../../sdl.zig");
const entt = @import("entt");

pub fn update(reg: *entt.Registry, renderer: *c.SDL_Renderer) error{SdlError}!void {
    var view = reg.view(.{
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
            const angle: f64, const flip: sdl.Flip = switch (movable_on_grid.current_direction) {
                .up => .{ -90, .none },
                .down => .{ 90, .none },
                .left => .{ 0, .horizontal },
                .right => .{ 0, .none },
            };

            try sdl.renderTextureRotated(renderer, movement_animation.sprite_sheet, src_area, render_area, angle, null, flip);
        } else {
            try sdl.renderTexture(renderer, movement_animation.sprite_sheet, src_area, render_area);
        }
    }
}
