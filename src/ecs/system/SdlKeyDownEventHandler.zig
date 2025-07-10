const component = @import("../component.zig");
const c = @import("../../c.zig");
const entt = @import("entt");

pub fn update(reg: *entt.Registry, events_holder_entity: entt.Entity, sdl_keycode: c.SDL_Keycode) void {
    switch (sdl_keycode) {
        c.SDLK_UP => reg.addOrReplace(events_holder_entity, component.PlayerInputEvent{ .direction = .up }),
        c.SDLK_DOWN => reg.addOrReplace(events_holder_entity, component.PlayerInputEvent{ .direction = .down }),
        c.SDLK_LEFT => reg.addOrReplace(events_holder_entity, component.PlayerInputEvent{ .direction = .left }),
        c.SDLK_RIGHT => reg.addOrReplace(events_holder_entity, component.PlayerInputEvent{ .direction = .right }),
        else => {},
    }
}
