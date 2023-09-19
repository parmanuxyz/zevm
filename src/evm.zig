const std = @import("std");
const types = @import("types.zig");
const Stack = types.Stack;
const Memory = types.Memory;

pub const OpCodes = enum(u8) {
    // math
    STOP = 0x00,
    ADD = 0x01,
    MUL = 0x02,
    SUB = 0x03,
    DIV = 0x04,
    SDIV = 0x05,
    MOD = 0x06,
    SMOD = 0x07,
    ADDMOD = 0x08,
    MULMOD = 0x09,
    EXP = 0x0a,
    SIGNEXTEND = 0x0b,

    // comparison & bitwise
    LT = 0x10,
    GT = 0x11,
    SLT = 0x12,
    SGT = 0x13,
    EQ = 0x14,
    ISZERO = 0x15,
    AND = 0x16,
    OR = 0x17,
    XOR = 0x18,
    NOT = 0x19,
    BYTE = 0x1a,
    SHL = 0x1b,
    SHR = 0x1c,
    SAR = 0x1d,

    // hashing
    SHA3 = 0x20,

    // environment
    ADDRESS = 0x30,
    BALANCE = 0x31,
    ORIGIN = 0x32,
    CALLER = 0x33,
    CALLVALUE = 0x34,
    CALLDATALOAD = 0x35,
    CALLDATASIZE = 0x36,
    CALLDATACOPY = 0x37,
    CODESIZE = 0x38,
    CODECOPY = 0x39,
    GASPRICE = 0x3a,
    EXTCODESIZE = 0x3b,
    EXTCODECOPY = 0x3c,
    RETURNDATASIZE = 0x3d,
    RETURNDATACOPY = 0x3e,
    EXTCODEHASH = 0x3f,
    BLOCKHASH = 0x40,
    COINBASE = 0x41,
    TIMESTAMP = 0x42,
    NUMBER = 0x43,
    PREVRANDAO = 0x44,
    GASLIMIT = 0x45,
    CHAINID = 0x46,
    SELFBALANCE = 0x47,
    BASEFEE = 0x48,

    //
    POP = 0x50,
    MLOAD = 0x51,
    MSTORE = 0x52,
    MSTORE8 = 0x53,
    SLOAD = 0x54,
    STORE = 0x55,
    JUMP = 0x56,
    JUMPI = 0x57,
    PC = 0x58,
    MSIZE = 0x59,
    GAS = 0x5a,
    JUMPDEST = 0x5b,

    // push stack operations
    PUSH0 = 0x5f,
    PUSH1 = 0x60,
    PUSH2 = 0x61,
    PUSH3 = 0x62,
    PUSH4 = 0x63,
    PUSH5 = 0x64,
    PUSH6 = 0x65,
    PUSH7 = 0x66,
    PUSH8 = 0x67,
    PUSH9 = 0x68,
    PUSH10 = 0x69,
    PUSH11 = 0x6a,
    PUSH12 = 0x6b,
    PUSH13 = 0x6c,
    PUSH14 = 0x6d,
    PUSH15 = 0x6e,
    PUSH16 = 0x6f,
    PUSH17 = 0x70,
    PUSH18 = 0x71,
    PUSH19 = 0x72,
    PUSH20 = 0x73,
    PUSH21 = 0x74,
    PUSH22 = 0x75,
    PUSH23 = 0x76,
    PUSH24 = 0x77,
    PUSH25 = 0x78,
    PUSH26 = 0x79,
    PUSH27 = 0x7a,
    PUSH28 = 0x7b,
    PUSH29 = 0x7c,
    PUSH30 = 0x7d,
    PUSH31 = 0x7e,
    PUSH32 = 0x7f,

    // dup stack operations
    DUP1 = 0x80,
    DUP2 = 0x81,
    DUP3 = 0x82,
    DUP4 = 0x83,
    DUP5 = 0x84,
    DUP6 = 0x85,
    DUP7 = 0x86,
    DUP8 = 0x87,
    DUP9 = 0x88,
    DUP10 = 0x89,
    DUP11 = 0x8a,
    DUP12 = 0x8b,
    DUP13 = 0x8c,
    DUP14 = 0x8d,
    DUP15 = 0x8e,
    DUP16 = 0x8f,

    // swap stack operations
    SWAP1 = 0x90,
    SWAP2 = 0x91,
    SWAP3 = 0x92,
    SWAP4 = 0x93,
    SWAP5 = 0x94,
    SWAP6 = 0x95,
    SWAP7 = 0x96,
    SWAP8 = 0x97,
    SWAP9 = 0x98,
    SWAP10 = 0x99,
    SWAP11 = 0x9a,
    SWAP12 = 0x9b,
    SWAP13 = 0x9c,
    SWAP14 = 0x9d,
    SWAP15 = 0x9e,
    SWAP16 = 0x9f,

    // log operations
    LOG0 = 0xa0,
    LOG1 = 0xa1,
    LOG2 = 0xa2,
    LOG3 = 0xa3,
    LOG4 = 0xa4,

    // creates and calls
    CREATE = 0xf0,
    CALL = 0xf1,
    CALLCODE = 0xf2,
    RETURN = 0xf3,
    DELEGATECALL = 0xf4,
    CREATE2 = 0xf5,
    STATICCALL = 0xfa,

    REVERT = 0xfd,
    INVALID = 0xfe,
    SELFDESTRUCT = 0xff,
};

pub const Environment = struct {
    // pub fn blockhash(blockNumber: u128)

    // BLOCKHASH = 0x40,
    // COINBASE = 0x41,
    // TIMESTAMP = 0x42,
    // NUMBER = 0x43,
    // PREVRANDAO = 0x44,
    // GASLIMIT = 0x45,
    // CHAINID = 0x46,
    // SELFBALANCE = 0x47,
    // BASEFEE = 0x48,
};

pub const CallFrame = struct {};

const MAX_CODE_SIZE = 0x6000;

pub const Evm = struct {
    stack: *Stack,
    memory: *Memory,
    code: []const u8,
    calldata: []const u8,
    pc: std.math.IntFittingRange(0, MAX_CODE_SIZE),

    pub fn new(stack: *Stack, memory: *Memory, code: []const u8, calldata: []const u8) Evm {
        return Evm{
            .stack = stack,
            .memory = memory,
            .code = code,
            .calldata = calldata,
            .pc = 0,
        };
    }

    pub fn codeliteral(allocator: *std.mem.Allocator, literal: []const u8) ![]u8 {
        if (literal.len % 2 != 0) {
            return error.InvalidCode;
        }

        const zero: u8 = '0';
        const nine: u8 = '9';
        const lower_a = 'a';
        const lower_f = 'f';
        const upper_a = 'A';
        const upper_b = 'B';

        var ret = try allocator.alloc(u8, literal.len / 2);

        var idx: usize = 0;
        var curr_half_byte: u8 = 0;
        while (idx < literal.len) : (idx += 1) {
            const byte = literal[idx];
            const actual_half_byte = blk: {
                switch (byte) {
                    zero...nine => {
                        break :blk byte - zero;
                    },
                    lower_a...lower_f => {
                        break :blk byte - lower_a + 10;
                    },
                    upper_a...upper_b => {
                        break :blk byte - upper_a + 10;
                    },
                    else => {
                        return error.InvalidCode;
                    },
                }
            };
            if (idx % 2 == 1) {
                const actual_byte = curr_half_byte << 4 | actual_half_byte;
                const actual_idx = idx / 2;
                ret[actual_idx] = actual_byte;
            } else {
                curr_half_byte = actual_half_byte;
            }
        }
        return ret;
    }

    pub fn execute(self: *Evm) !void {
        while (self.pc < self.code.len) blk: {
            const op = @as(OpCodes, @enumFromInt(self.code[self.pc]));
            self.pc += 1;
            switch (op) {
                .STOP => {
                    break :blk;
                },
                .ADD => {
                    // TODO: wrapping add
                    const a = self.stack.pop();
                    const b = self.stack.pop();
                    self.stack.push(a + b);
                },
                .MUL => {
                    const a = self.stack.pop();
                    const b = self.stack.pop();
                    self.stack.push(a * b);
                },
                .SUB => {
                    // TODO: wrapping sub
                    const a = self.stack.pop();
                    const b = self.stack.pop();
                    self.stack.push(a - b);
                },
                .DIV => {
                    const a = self.stack.pop();
                    const b = self.stack.pop();
                    self.stack.push(if (b == 0) 0 else a / b);
                },
                .SDIV => {
                    // TODO
                    unreachable;
                },
                .MOD => {
                    const a = self.stack.pop();
                    const b = self.stack.pop();
                    self.stack.push(if (b == 0) 0 else a % b);
                },
                .SMOD => {
                    // TODO
                    unreachable;
                },
                .ADDMOD => {
                    const a = self.stack.pop();
                    const b = self.stack.pop();
                    const c = self.stack.pop();
                    self.stack.push(if (c == 0) 0 else (a + b) % c);
                },
                .MULMOD => {
                    const a = self.stack.pop();
                    const b = self.stack.pop();
                    const c = self.stack.pop();
                    self.stack.push(if (c == 0) 0 else (a * b) % c);
                },
                .EXP, .SIGNEXTEND => {
                    // TODO
                    unreachable;
                },
                // zig fmt: off
                .PUSH1, .PUSH2, .PUSH3, .PUSH4, .PUSH5, 
                .PUSH6, .PUSH7, .PUSH8, .PUSH9, .PUSH10, 
                .PUSH11, .PUSH12, .PUSH13, .PUSH14, .PUSH15, 
                .PUSH16, .PUSH17, .PUSH18, .PUSH19, .PUSH20, 
                .PUSH21, .PUSH22, .PUSH23, .PUSH24, .PUSH25, 
                .PUSH26, .PUSH27, .PUSH28, .PUSH29, .PUSH30, 
                .PUSH31, .PUSH32 => {
                // zig fmt: on
                    const push1_op_code = @intFromEnum(OpCodes.PUSH1);
                    const current_push_opcode = @intFromEnum(op);
                    const n = current_push_opcode - push1_op_code + 1;
                    if (n > 32) {
                        return error.InvalidPushN;
                    }
                    try self.do_push(@intCast(n));
                },
                // zig fmt: off
                .SWAP1, .SWAP2, .SWAP3, .SWAP4, .SWAP5,
                .SWAP6, .SWAP7, .SWAP8, .SWAP9, .SWAP10,
                .SWAP11, .SWAP12, .SWAP13, .SWAP14, .SWAP15,
                .SWAP16 => {
                // zig fmt: on
                    const swap1_op_code = @intFromEnum(OpCodes.SWAP1);
                    const current_swap_opcode = @intFromEnum(op);
                    const n = current_swap_opcode - swap1_op_code + 1;
                    if (n > 16) {
                        return error.InvalidSwapN;
                    }
                    try self.do_swap(@intCast(n));
                },
                // zig fmt: off
                .DUP1, .DUP2, .DUP3, .DUP4, .DUP5, .DUP6,
                .DUP7, .DUP8, .DUP9, .DUP10, .DUP11, .DUP12,
                .DUP13, .DUP14, .DUP15, .DUP16 => {
                // zig fmt: on
                    const dup1_op_code = @intFromEnum(OpCodes.DUP1);
                    const current_dup_opcode = @intFromEnum(op);
                    const n = current_dup_opcode - dup1_op_code + 1;
                    if (n > 16) {
                        return error.InvalidDupN;
                    }
                    try self.do_dup(@intCast(n));
                },
                else => {
                    unreachable;
                },
            }
            self.stack.debug_stack();
        }
    }

    fn do_push(self: *Evm, n: std.math.IntFittingRange(1, 32)) !void {
        const num = self.code[self.pc .. self.pc + n];
        self.stack.push(try Evm.get_num(num));
        self.pc += n;
    }

    fn do_swap(self: *Evm, n: std.math.IntFittingRange(1, 16)) !void {
        try self.stack.swap(n);
    }

    fn do_dup(self: *Evm, n: std.math.IntFittingRange(1, 16)) !void {
        try self.stack.dup(n);
    }

    fn get_num(bytes: []const u8) !usize {
        const nbytes = bytes.len;
        if (nbytes > 32) {
            return error.TooBig;
        }
        var result: usize = 0;
        for (bytes, 0..) |byte, idx| {
            const shift: u6 = @intCast((nbytes - idx - 1) * 8);
            const num = @as(usize, byte) << shift;
            result |= num;
        }
        return result;
    }
};
