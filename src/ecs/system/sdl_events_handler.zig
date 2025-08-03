const component = @import("../component.zig");
const c = @import("../../c.zig");
const Vec2 = @import("../../Vec2.zig").Vec2;
const entt = @import("entt");

pub fn update(reg: *entt.Registry, events_holder: entt.Entity) void {
    reg.removeAll(events_holder);

    var event: c.SDL_Event = undefined;
    while (c.SDL_PollEvent(&event)) {
        switch (event.type) {
            c.SDL_EVENT_WINDOW_CLOSE_REQUESTED => reg.addOrReplace(events_holder, component.QuitEvent{}),
            c.SDL_EVENT_KEY_DOWN => switch (event.key.key) {
                c.SDLK_UP => reg.addOrReplace(events_holder, component.PlayerInputEvent{ .direction = .up }),
                c.SDLK_DOWN => reg.addOrReplace(events_holder, component.PlayerInputEvent{ .direction = .down }),
                c.SDLK_LEFT => reg.addOrReplace(events_holder, component.PlayerInputEvent{ .direction = .left }),
                c.SDLK_RIGHT => reg.addOrReplace(events_holder, component.PlayerInputEvent{ .direction = .right }),
                else => {},
            },
            c.SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED => {
                const new_window_size = Vec2(i32){ .x = event.window.data1, .y = event.window.data2 };
                reg.add(events_holder, component.WindowSizeChangedEvent{ .new_value = new_window_size.intCast(u32) });
            },
            else => {},
        }
    }
}
