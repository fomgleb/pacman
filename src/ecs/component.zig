pub const RenderArea = Rect(f32);
pub const Texture = *c.SDL_Texture;
pub const GridCellPosition = struct { current: Vec2(f32), previous: Vec2(f32) };
pub const GridSize = Vec2(u16);
pub const GridCells = Array2D(GridCell);
pub const PlayerTag = void;
pub const CenteredInWindowTag = void;
pub const PlayerInputEvent = struct { direction: Direction };
pub const WindowSizeChangedEvent = struct { new_value: Vec2(u32) };
pub const DeltaTimeMeasuredEvent = struct { value: u64 };
pub const QuitEvent = void;
pub const Timer = std.time.Timer;
pub const GridMembership = struct { grid_entity: entt.Entity };
pub const PelletsEater = struct { left_pellets_count: u32, eaten_pellets_count: u32 };
pub const MovementAnimation = struct {
    sprite_sheet: *c.SDL_Texture,
    sprite_size: Vec2(f32),
    fps: f32,
    current_frame_index: f32,
    sprite_sheet_read_direction: enum { right, left },
};
pub const AspectRatio = @import("component/AspectRatio.zig");
pub const MovableOnGrid = @import("component/MovableOnGrid.zig");

const std = @import("std");
const Array2D = @import("../Array2D.zig").Array2D;
const c = @import("../c.zig");
const Direction = @import("../Direction.zig").Direction;
const GridCell = @import("../GridCell.zig").GridCell;
const Vec2 = @import("../Vec2.zig").Vec2;
const Rect = @import("../Rect.zig").Rect;
const entt = @import("entt");
