const c = @import("../../c.zig");
const sdl = @import("../../sdl.zig");
const Vec2 = @import("../../Vec2.zig").Vec2;

sprite_sheet: *c.SDL_Texture,
sprite_size: Vec2(f32),
fps: f32,
sprite_can_rotate: bool,
current_frame_index: f32 = 0,
sprite_sheet_read_direction: enum { right, left } = .right,

pub fn init(sprite_sheet: *c.SDL_Texture, sprite_width: f32, fps: f32, sprite_can_rotate: bool) !@This() {
    return .{
        .sprite_sheet = sprite_sheet,
        .sprite_size = .init(sprite_width, (try sdl.getTextureSize(sprite_sheet)).y),
        .fps = fps,
        .sprite_can_rotate = sprite_can_rotate,
    };
}
