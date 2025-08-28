const game_kit = @import("game_kit");
const sdl = game_kit.sdl;
const Vec2 = game_kit.Vec2;

sprite_sheet: *sdl.Texture,
sprite_size: Vec2(f32),
fps: f32,
sprite_can_rotate: bool,
current_frame_index: f32 = 0,
sprite_sheet_read_direction: enum { right, left } = .right,

pub fn init(sprite_sheet: *sdl.Texture, sprite_width: f32, fps: f32, sprite_can_rotate: bool) error{SdlError}!@This() {
    return .{
        .sprite_sheet = sprite_sheet,
        .sprite_size = .init(sprite_width, (try sdl.getTextureSize(sprite_sheet)).y),
        .fps = fps,
        .sprite_can_rotate = sprite_can_rotate,
    };
}
