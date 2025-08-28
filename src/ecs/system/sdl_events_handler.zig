const component = @import("../component.zig");
const game_kit = @import("game_kit");
const Vec2 = game_kit.Vec2;
const sdl = game_kit.sdl;
const c = game_kit.c;
const entt = @import("entt");

pub fn update(reg: *entt.Registry, events_holder: entt.Entity) void {
    reg.removeAll(events_holder);

    while (sdl.pollEvent()) |event| switch (event.type) {
        c.SDL_EVENT_WINDOW_CLOSE_REQUESTED => reg.addOrReplace(events_holder, component.QuitEvent{}),
        c.SDL_EVENT_KEY_DOWN => switch (event.key.key) {
            c.SDLK_UP => reg.addOrReplace(events_holder, component.PlayerInputEvent{ .direction = .up }),
            c.SDLK_DOWN => reg.addOrReplace(events_holder, component.PlayerInputEvent{ .direction = .down }),
            c.SDLK_LEFT => reg.addOrReplace(events_holder, component.PlayerInputEvent{ .direction = .left }),
            c.SDLK_RIGHT => reg.addOrReplace(events_holder, component.PlayerInputEvent{ .direction = .right }),
            c.SDLK_SPACE => reg.addOrReplace(events_holder, component.PlayerRequestedRestartEvent{}),
            else => {},
        },
        c.SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED => {
            const new_window_size = Vec2(i32){ .x = event.window.data1, .y = event.window.data2 };
            reg.add(events_holder, component.WindowSizeChangedEvent{ .new_value = new_window_size.intCast(u32) });
        },
        else => {},
    };
}
