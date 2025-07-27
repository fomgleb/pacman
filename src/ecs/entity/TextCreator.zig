const component = @import("../component.zig");
const Color = @import("../../Color.zig");
const c = @import("../../c.zig");
const sdl = @import("../../sdl.zig");
const entt = @import("entt");
const TextCreator = @This();

reg: *entt.Registry,
renderer: *c.SDL_Renderer,
grid: entt.Entity,
font: *c.TTF_Font,

pub fn init(reg: *entt.Registry, renderer: *c.SDL_Renderer, grid: entt.Entity, file_path: [*:0]const u8, pt_size: f32) !TextCreator {
    return .{
        .reg = reg,
        .renderer = renderer,
        .grid = grid,
        .font = try sdl.ttf.openFont(file_path, pt_size),
    };
}

pub fn deinit(self: TextCreator) void {
    c.TTF_CloseFont(self.font);
}

pub fn create(self: *TextCreator, text: []const u8, color: Color, layout: component.Layout) !entt.Entity {
    const text_surface = try sdl.ttf.renderTextBlended(self.font, text, color);
    defer c.SDL_DestroySurface(text_surface);
    const texture = try sdl.createTextureFromSurface(self.renderer, text_surface);

    const text_entity = self.reg.create();
    self.reg.add(text_entity, @as(component.TextTag, .{}));
    self.reg.add(text_entity, @as(component.Texture, texture));
    self.reg.add(text_entity, @as(component.PositionInWindow, undefined));
    self.reg.add(text_entity, @as(component.GridMembership, .{ .grid_entity = self.grid }));
    self.reg.add(text_entity, @as(component.Layout, layout));
    return text_entity;
}

pub fn destory(self: TextCreator) void {
    var view = self.reg.view(.{
        component.TextTag,
        component.Texture,
        component.PositionInWindow,
        component.GridMembership,
        component.Layout,
    }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const texture = view.getConst(component.Texture, entity);
        c.SDL_DestroyTexture(texture);
    }
}
