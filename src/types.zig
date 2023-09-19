const std = @import("std");

pub const Stack = struct {
    stack: []usize,
    top: usize = 0,

    pub fn new(allocator: *std.mem.Allocator, max_size: usize) !Stack {
        return Stack{
            .stack = try allocator.alloc(usize, max_size),
        };
    }

    pub fn push(self: *Stack, value: usize) void {
        self.stack[self.top] = value;
        self.top += 1;
    }

    pub fn pop(self: *Stack) usize {
        self.top -= 1;
        return self.stack[self.top];
    }

    pub fn size(self: *Stack) usize {
        return self.top;
    }

    pub fn debug_stack(self: *Stack) void {
        std.debug.print("Stack: [", .{});
        for (0..self.top) |i| {
            std.debug.print("{}", .{self.stack[i]});
            if (i != self.top - 1) {
                std.debug.print(", ", .{});
            }
        }
        std.debug.print("]\n", .{});
    }
};

pub const Memory = struct {
    memory: []usize,
    max_written: usize = 0,

    pub fn new(allocator: *std.mem.Allocator, max_size: usize) !Memory {
        return Memory{
            .memory = try allocator.alloc(usize, max_size),
        };
    }

    pub fn read(self: *Memory, offset: usize) usize {
        if (offset > self.memory.len) {
            return 0;
        }
        return self.memory[offset];
    }

    pub fn write(self: *Memory, offset: usize, value: usize) !void {
        if (offset > self.memory.len) {
            return error.MemOutOfBounds;
        }
        self.memory[offset] = value;
        if (offset > self.max_written) {
            self.max_written = offset;
        }
    }

    pub fn size(self: *Memory) usize {
        return self.max_written;
    }
};
