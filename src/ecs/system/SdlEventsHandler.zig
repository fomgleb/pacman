const component = @import("../component.zig");
const System = @import("../../System.zig");
const c = @import("../../c.zig");
const Vec2 = @import("../../Vec2.zig").Vec2;
const entt = @import("entt");

reg: *entt.Registry,
events_holder_entity: entt.Entity,

pub fn update(self: *const @This()) void {
    self.reg.removeAll(self.events_holder_entity);

    var event: c.SDL_Event = undefined;
    while (c.SDL_PollEvent(&event)) {
        switch (event.type) {
            c.SDL_EVENT_WINDOW_CLOSE_REQUESTED => self.reg.addOrReplace(self.events_holder_entity, component.QuitEvent{}),
            c.SDL_EVENT_KEY_DOWN => switch (event.key.key) {
                c.SDLK_UP => self.reg.addOrReplace(self.events_holder_entity, component.PlayerInputEvent{ .direction = .up }),
                c.SDLK_DOWN => self.reg.addOrReplace(self.events_holder_entity, component.PlayerInputEvent{ .direction = .down }),
                c.SDLK_LEFT => self.reg.addOrReplace(self.events_holder_entity, component.PlayerInputEvent{ .direction = .left }),
                c.SDLK_RIGHT => self.reg.addOrReplace(self.events_holder_entity, component.PlayerInputEvent{ .direction = .right }),
                else => {},
            },
            c.SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED => {
                const new_window_size = Vec2(i32){ .x = event.window.data1, .y = event.window.data2 };
                self.reg.add(self.events_holder_entity, component.WindowSizeChangedEvent{ .new_value = new_window_size.intCast(u32) });
            },
            else => {},
        }
    }
}

pub fn system(self: *const @This()) System {
    return System.init(self);
}
