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
    const T = i32;
    const N = 10_000;
    var rb = RingBuffer(T, N).init();
    
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) @panic("MEMORY LEAK");
    }

    if (rb.isEmpty()) {
        try stdout.print("RingBuffer is empty.\n", .{});
    }

    try rb.push(1);
    try rb.push(2);

    if (!rb.isEmpty()) {
        try stdout.print("RingBuffer is now non-empty, as expected.\n", .{});
    }

    while (!rb.isEmpty()) {
        const popped = try rb.pop(); // must try
        try stdout.print("RingBuffer pops: {}\n", .{popped});
    }

    if (rb.isEmpty()) {
        try stdout.print("RingBuffer is now empty again.\n", .{});
    } else {
        try stdout.print("Something went wrong!\n", .{});
    }

    const queue_size = 1000;
    const iterations = 100_000;
    
    var timer1 = try std.time.Timer.start();
    for (0..iterations) |i| {
        if (rb.isFull()) {
            _ = try rb.pop();
        }
        try rb.push(@intCast(i));
    }
    const elapsed1 = timer1.read();
    
    // Array-based queue benchmark 
    var timer2 = try std.time.Timer.start();
    var array = try allocator.alloc(T, queue_size);
    defer allocator.free(array);
    var array_count: usize = 0;
    
    for (0..iterations) |i| {
        // If array is full, remove the first element and shift all others
        if (array_count == queue_size) {
            for (1..queue_size) |j| {
                array[j - 1] = array[j];
            }
            array_count -= 1;
        }
        // Add new element at the end
        array[array_count] = @intCast(i);
        array_count += 1;
    }
    const elapsed2 = timer2.read();

    try stdout.print("ring buffer: {} ns (avg: {} ns)\n", 
        .{ elapsed1, elapsed1 / iterations });
    try stdout.print("array with shifting: {} ns (avg: {} ns)\n", 
        .{ elapsed2, elapsed2 / iterations });
    try stdout.print("Ring buffer is {d:.2}x faster\n", 
        .{@as(f64, @floatFromInt(elapsed2)) / @as(f64, @floatFromInt(elapsed1))});
        
    try bw.flush();
}

const std = @import("std");
const lib = @import("zig_ring_lib");
