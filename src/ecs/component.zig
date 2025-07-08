pub const RenderArea = Rect(u32);
pub const Texture = *c.SDL_Texture;
pub const PositionOnGrid = Point(f32);
pub const GridSize = Point(u16);
pub const PacmanTag = void;
pub const CenteredInWindowTag = void;
pub const AspectRatio = @import("component/AspectRatio.zig");
pub const MovableOnGrid = @import("component/MovableOnGrid.zig");

const Point = @import("../point.zig").Point;
const Rect = @import("../rect.zig").Rect;
const c = @import("../c.zig");
