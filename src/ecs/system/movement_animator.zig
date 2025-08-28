const time = @import("std").time;
const component = @import("../component.zig");
const game_kit = @import("game_kit");
const c = game_kit.c;
const Rect = game_kit.Rect;
const sdl = game_kit.sdl;
const entt = @import("entt");

pub fn update(reg: *entt.Registry, events_holder: entt.Entity) error{SdlError}!void {
    const delta_time = reg.getConst(component.DeltaTimeMeasuredEvent, events_holder).value;

    var view = reg.view(.{ component.MovableOnGrid, component.MovementAnimation }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const movable_on_grid = view.getConst(component.MovableOnGrid, entity);
        if (movable_on_grid.current_speed == 0) continue;
        const movement_animation = view.get(component.MovementAnimation, entity);
        const curr_frame_idx = &movement_animation.current_frame_index;
        const sprite_sheet_read_dir = &movement_animation.sprite_sheet_read_direction;

        const texture_width = (try sdl.getTextureSize(movement_animation.sprite_sheet)).x;
        const frames_count = texture_width / movement_animation.sprite_size.x;

        const delta_time_s = @as(f32, @floatFromInt(delta_time)) / time.ns_per_s;
        var add_to_frame_index = switch (sprite_sheet_read_dir.*) {
            .left => -(movement_animation.fps * delta_time_s),
            .right => movement_animation.fps * delta_time_s,
        };
        while (add_to_frame_index != 0) {
            curr_frame_idx.* += add_to_frame_index;
            add_to_frame_index = 0;

            if (curr_frame_idx.* > (frames_count - 1)) {
                add_to_frame_index = (frames_count - 1) - curr_frame_idx.*;
                sprite_sheet_read_dir.* = .left;
            } else if (curr_frame_idx.* < 0) {
                add_to_frame_index = 0 - curr_frame_idx.*;
                sprite_sheet_read_dir.* = .right;
            }
        }
    }
}
