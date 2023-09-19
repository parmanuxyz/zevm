const std = @import("std");

const evm = @import("evm.zig");
const types = @import("types.zig");

const Stack = types.Stack;
const Memory = types.Memory;

const Evm = evm.Evm;
const OpCodes = evm.OpCodes;
const CodeByte = evm.CodeByte;

const MAX_STACK = 10000;
const MAX_MEMORY = 10000;

pub fn main() !void {
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_allocator.deinit();
    var allocator = arena_allocator.allocator();

    var stack = try Stack.new(&allocator, MAX_STACK);
    var memory = try Memory.new(&allocator, MAX_MEMORY);

    const parsed_code = try Evm.codeliteral(&allocator, "620102036002018060016002809192");
    // const code = [_]u8{ @intFromEnum(OpCodes.PUSH2), 0x02, 0x01, @intFromEnum(OpCodes.PUSH1), 0x04, @intFromEnum(OpCodes.ADD) };
    // const code = [_]u8{ 0, 1, 2, 3 };
    const calldata = [_]u8{};

    var vm = Evm.new(&stack, &memory, parsed_code, &calldata);
    try vm.execute();
}
