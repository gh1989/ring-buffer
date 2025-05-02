fn RingBuffer(comptime T: type, comptime N: usize) type {
    return struct {
        buffer: [N]T = undefined,
        head: usize = 0,
        tail: usize = 0,

        const Self = @This();

        pub fn init() Self {
            return Self{};
        }

        pub fn isEmpty(self: Self) bool {
            return self.head == self.tail;
        }

        pub fn isFull(self: Self) bool {
            // independeny of capacity
            return (self.head + 1) % N == self.tail;
        }

        pub fn capacity(_: Self) usize {
            return N - 1;
        }

        pub fn push(self: *Self, value: T) !void {
            if (self.isFull()) return error.BufferFull;
            self.buffer[self.head] = value;
            self.head = (self.head + 1) % N;
        }

        pub fn pop(self: *Self) !T {
            if (self.isEmpty()) return error.BufferEmpty;
            // const
            const value = self.buffer[self.tail];
            self.tail = (self.tail + 1) % N;
            return value;
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

    try buf.push(1);
    try buf.push(2);

    if (!buf.isEmpty()) {
        try stdout.print("RingBuffer is now non-empty, as expected.\n", .{});
    }

    while (!buf.isEmpty()) {
        const popped = try buf.pop(); // must try
        try stdout.print("RingBuffer pops: {}\n", .{popped});
    }

    if (buf.isEmpty()) {
        try stdout.print("RingBuffer is now empty again.\n", .{});
    } else {
        try stdout.print("Something went wrong!\n", .{});
    }

    try bw.flush(); // must flush the buffered writer
}

const std = @import("std");
const lib = @import("zig_ring_lib");
