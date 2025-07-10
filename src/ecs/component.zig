pub const RenderArea = Rect(u32);
pub const Texture = *c.SDL_Texture;
pub const PositionOnGrid = struct { curr: Point(f32), prev: Point(f32) };
pub const GridSize = Point(u16);
pub const GridCells = Array2D(GridMember);
pub const PlayerTag = void;
pub const CenteredInWindowTag = void;
pub const AspectRatio = @import("component/AspectRatio.zig");
pub const MovableOnGrid = @import("component/MovableOnGrid.zig");

const Array2D = @import("../Array2D.zig").Array2D;
const c = @import("../c.zig");
const GridMember = @import("../GridMember.zig").GridMember;
const Point = @import("../point.zig").Point;
const Rect = @import("../rect.zig").Rect;
