const Renderable = @This();

context: *const anyopaque,
render_fn: *const fn (self: *const anyopaque) error{SdlError}!void,

pub fn init(context: anytype) Renderable {
    return Renderable{
        .context = context,
        .render_fn = struct {
            pub fn render(pointer: *const anyopaque) error{SdlError}!void {
                const self: @TypeOf(context) = @ptrCast(@alignCast(pointer));
                return @typeInfo(@TypeOf(context)).pointer.child.render(self);
            }
        }.render,
    };
}

pub fn render(self: Renderable) error{SdlError}!void {
    try self.render_fn(self.context);
}
