//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.

fn RingBuffer(comptime T: type, comptime N: usize) type {
    return struct {
        buffer: [N]T = undefined,
        head: usize = 0,
        tail: usize = 0,

        pub fn init() @This() {
            return @This(){};
        }

        pub fn isEmpty(self: @This()) bool {
            return self.head == self.tail;
        }
    };
}

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var buf = RingBuffer(i32, 128).init();

    if (buf.isEmpty()) {
        try stdout.print("RingBuffer is empty.\n", .{});
    }

    try bw.flush(); // Don't forget to flush!
}

const std = @import("std");

/// This imports the separate module containing `root.zig`. Take a look in `build.zig` for details.
const lib = @import("zig_ring_lib");
