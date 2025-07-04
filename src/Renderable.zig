const Renderable = @This();

context: *const anyopaque,
renderFn: *const fn (self: *const anyopaque) error{SdlError}!void,

pub fn init(context: anytype) Renderable {
    return Renderable{
        .context = context,
        .renderFn = struct {
            pub fn render(pointer: *const anyopaque) error{SdlError}!void {
                return @typeInfo(@TypeOf(context)).pointer.child.render(@ptrCast(@alignCast(pointer)));
            }
        }.render,
    };
}

pub fn render(self: Renderable) error{SdlError}!void {
    try self.renderFn(self.context);
}
