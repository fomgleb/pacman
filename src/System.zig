const System = @This();

context: *const anyopaque,
updateFn: *const fn (self: *const anyopaque) anyerror!void,

pub fn init(context: anytype) System {
    return System{
        .context = context,
        .updateFn = struct {
            pub fn update(pointer: *const anyopaque) !void {
                return @typeInfo(@TypeOf(context)).pointer.child.update(@ptrCast(@alignCast(pointer)));
            }
        }.update,
    };
}

pub fn update(self: System) anyerror!void {
    try self.updateFn(self.context);
}
