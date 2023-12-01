pub const day_1 = @import("day_1/day_1.zig");

test {
    @import("std").testing.refAllDecls(@This());
}
