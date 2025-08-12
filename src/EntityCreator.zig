const EntityCreator = @This();
const entt = @import("entt");

context: *const anyopaque,
createFn: *const fn (self: *const anyopaque) anyerror!entt.Entity,

pub fn init(context: anytype) EntityCreator {
    return EntityCreator{
        .context = context,
        .createFn = struct {
            pub fn create(pointer: *const anyopaque) anyerror!entt.Entity {
                return @typeInfo(@TypeOf(context)).pointer.child.create(@ptrCast(@alignCast(pointer)));
            }
        }.create,
    };
}

pub fn create(self: EntityCreator) anyerror!entt.Entity {
    return try self.createFn(self.context);
}
