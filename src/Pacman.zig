const c = @import("c.zig");
const log = @import("std").log.scoped(.Pacman);
const Renderable = @import("Renderable.zig");
const LinearController = @import("LinearController.zig");
const Point = @import("point.zig").Point;
const Rect = @import("rect.zig").Rect;
const Grid = @import("Grid.zig");
const sdl = @import("sdl.zig");
const Pacman = @This();

texture: *c.SDL_Texture,
controller: LinearController = .init(5, .right),
render_area: Rect(u32),
cell_position: Point(f32),
grid: *const Grid,

pub fn init(renderer: *c.SDL_Renderer, texture_path: [*:0]const u8, grid: *const Grid, cell_position: Point(f32)) error{SdlError}!Pacman {
    const texture: *c.SDL_Texture = c.IMG_LoadTexture(renderer, texture_path) orelse {
        log.err("Failed to IMG_LoadTexture: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    };
    if (!c.SDL_SetTextureScaleMode(texture, c.SDL_SCALEMODE_NEAREST)) {
        log.err("Failed to SDL_SetTextureScaleMode: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }

    const render_area_f32 = grid.render_area.floatFromInt(f32);
    const cell_size = render_area_f32.size.x / @as(f32, @floatFromInt(grid.size.x));

    const render_area = Rect(u32){
        .position = .{
            .x = @intFromFloat(render_area_f32.position.x + cell_size * cell_position.x),
            .y = @intFromFloat(render_area_f32.position.y + cell_size * cell_position.y),
        },
        .size = .{ .x = @intFromFloat(cell_size), .y = @intFromFloat(cell_size) },
    };

    return Pacman{
        .texture = texture,
        .render_area = render_area,
        .cell_position = cell_position,
        .grid = grid,
    };
}

pub fn deinit(self: Pacman) void {
    c.SDL_DestroyTexture(self.texture);
}

pub fn renderable(self: *const Pacman) Renderable {
    return Renderable.init(self);
}

pub fn render(self: *const Pacman) error{SdlError}!void {
    const render_area_f32 = self.grid.render_area.floatFromInt(f32);
    const cell_size = render_area_f32.size.x / @as(f32, @floatFromInt(self.grid.size.x));
    const render_area = Rect(u32){
        .position = .{
            .x = @intFromFloat(render_area_f32.position.x + cell_size * self.cell_position.x),
            .y = @intFromFloat(render_area_f32.position.y + cell_size * self.cell_position.y),
        },
        .size = .{ .x = @intFromFloat(cell_size), .y = @intFromFloat(cell_size) },
    };

    const renderer = try sdl.getRendererFromTexture(self.texture);
    try sdl.renderTexture(renderer, self.texture, null, render_area.floatFromInt(f32));
}

pub fn update(self: *Pacman, delta_time: u64) void {
    self.cell_position = self.controller.update(delta_time, self.cell_position);
}

pub fn scale(self: *Pacman, render_area: Rect(u32)) void {
    const render_area_f32 = render_area.floatFromInt(f32);
    const cell_size = render_area_f32.size.x / @as(f32, @floatFromInt(self.grid.size.x));

    self.render_area = Rect(u32){
        .position = .{
            .x = @intFromFloat(render_area_f32.position.x + cell_size * self.cell_position.x),
            .y = @intFromFloat(render_area_f32.position.y + cell_size * self.cell_position.y),
        },
        .size = .{ .x = @intFromFloat(cell_size), .y = @intFromFloat(cell_size) },
    };
}
