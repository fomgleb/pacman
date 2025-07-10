pub const RenderArea = Rect(u32);
pub const Texture = *c.SDL_Texture;
pub const GridCellPosition = struct { current: Vec2(f32), previous: Vec2(f32) };
pub const GridSize = Vec2(u16);
pub const GridCells = Array2D(GridCell);
pub const PlayerTag = void;
pub const CenteredInWindowTag = void;
pub const PlayerInputEvent = struct { direction: Direction };
pub const AspectRatio = @import("component/AspectRatio.zig");
pub const MovableOnGrid = @import("component/MovableOnGrid.zig");

const Array2D = @import("../Array2D.zig").Array2D;
const c = @import("../c.zig");
const Direction = @import("../direction.zig").Direction;
const GridCell = @import("../GridCell.zig").GridCell;
const Vec2 = @import("../Vec2.zig").Vec2;
const Rect = @import("../rect.zig").Rect;
