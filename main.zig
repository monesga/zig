//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.

const std = @import("std");
const builtin = @import("builtin");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("stderr: initialized\n", .{});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();
    try stdout.print("stdout: initialized.\n", .{});
    try bw.flush(); // Don't forget to flush!

    // try test_stdin();

    // const server = HttpServer{};
    // try server.start();
}

test "var const" {
    var a: i32 = 1;
    const b: i32 = 2;
    a = b;
    // b = 30; // This will fail to compile, because `b` is a constant.
}

test "undefined" {
    var a: i32 = undefined;
    a = 1;
}

test "underscore" {
    const a: i32 = 1_000_000;
    _ = a;
}

test "var mutate" {
    var a: i32 = 1;
    a = 9; // if this line is removed we get a compile error
    const b = a;
    _ = b;
}

test "array declaration" {
    const a1 = [4]u8{ 1, 2, 3, 4 };
    const a2 = [_]u8{ 1, 2, 3, 4 };
    _ = a1;
    _ = a2;
}

test "array indexing" {
    const a1 = [4]u8{ 1, 2, 3, 4 };
    const b = a1[2];
    try expectEqual(@as(u8, 3), b);
}

test "slice" {
    const a1 = [4]u8{ 1, 2, 3, 4 };
    const b = a1[1..3];
    try expectEqual(@as(u8, 2), b[0]);
    try expectEqual(@as(u8, 3), b[1]);
    try expectEqual(@as(u32, 2), b.len);
    const c = a1[1..];
    try expectEqual(@as(u8, 2), c[0]);
    try expectEqual(@as(u8, 3), c[1]);
    try expectEqual(@as(u8, 4), c[2]);
    try expectEqual(@as(u32, 3), c.len);
}

test "array concat" {
    const a1 = [4]u8{ 1, 2, 3, 4 };
    const a2 = [4]u8{ 5, 6, 7, 8 };
    const b = a1 ++ a2;
    try expectEqual(@as(u8, 1), b[0]);
    try expectEqual(@as(u8, 2), b[1]);
    try expectEqual(@as(u8, 3), b[2]);
    try expectEqual(@as(u8, 4), b[3]);
    try expectEqual(@as(u8, 5), b[4]);
    try expectEqual(@as(u8, 6), b[5]);
    try expectEqual(@as(u8, 7), b[6]);
    try expectEqual(@as(u8, 8), b[7]);
    try expectEqual(@as(u32, 8), b.len);
}

test "array replicate" {
    const a = [_]u8{ 1, 2 };
    const b = a ** 2;
    try expectEqual(@as(u8, 1), b[0]);
    try expectEqual(@as(u8, 2), b[1]);
    try expectEqual(@as(u8, 1), b[2]);
    try expectEqual(@as(u8, 2), b[3]);
    try expectEqual(@as(u32, 4), b.len);
}

test "dynamic slice" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var n: usize = 0;

    if (builtin.target.os.tag == .windows) {
        n = 10;
    } else if (builtin.target.os.tag == .linux) {
        n = 20;
    } else {
        n = 30;
    }
    const buffer = try allocator.alloc(u8, n);
    defer allocator.free(buffer);
    const slice = buffer[0..];
    try expectEqual(@as(usize, n), slice.len);
}

test "blocks" {
    var y: i32 = 123;
    const x = add_one: {
        y += 1;
        break :add_one y;
    };
    try expectEqual(@as(i32, 124), x);
    try expectEqual(@as(i32, 124), y);
}

test "basic strings" {
    const stdout = std.io.getStdErr().writer();
    const str: []const u8 = "Hello, world!";
    try expectEqual(@as(u32, 13), str.len);
    try expectEqual(@as(u8, 'H'), str[0]);
    try expectEqual(@as(u8, 'o'), str[4]);
    try expectEqual(@as(u8, '!'), str[12]);
    try stdout.print(
        "<<string: {s} ",
        .{str},
    );
    try stdout.print(
        "slice[0..5]: {s}>> ",
        .{str[0..5]},
    );
}

test "string hex loop" {
    const stdout = std.io.getStdErr().writer();
    const str: []const u8 = "ABC";
    try stdout.print("<<str: {s} hex: ", .{str});
    for (str) |c| {
        try stdout.print("{X} ", .{c});
    }
    try stdout.print(">>", .{});
}

test "string length" {
    const str = "0123456789012345678901234567890123";
    const len = str.len;
    try expectEqual(@as(u32, 34), len);
}

test "@TypeOf" {
    const arr = [_]u8{ 1, 2, 3, 4 };
    try expectEqual(@TypeOf(arr), [4]u8);

    const str = "ABC";
    try expectEqual(@TypeOf(str), *const [3:0]u8);

    const pa = &arr;
    try expectEqual(@TypeOf(pa), *const [4]u8);

    const stdout = std.io.getStdErr().writer();
    try stdout.print("<<arr:{}, str:{}, pa:{}>>", .{ @TypeOf(arr), @TypeOf(str), @TypeOf(pa) });
}

test "UTF-8 raw codepoint" {
    const str = "Ⱥ";
    const c0 = str[0];
    const c1 = str[1];
    try expectEqual(@as(u8, 0xC8), c0);
    try expectEqual(@as(u8, 0xBA), c1);
    try expectEqual(@as(usize, 2), str.len);
}

test "UTF-8 view" {
    var utf8 = (try std.unicode.Utf8View.init("Ⱥ")).iterator();

    const codepoint = utf8.nextCodepoint();
    try expectEqual(@as(u21, 570), codepoint);
}

test "string equality " {
    const name: []const u8 = "Mohsen";
    try expectEqual(
        true,
        std.mem.eql(u8, name, "Mohsen"),
    );
}

test "string concat" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const concat = try std.mem.concat(allocator, u8, &[_][]const u8{
        "Hello, ",
        "world!",
    });
    defer allocator.free(concat);
    try expectEqual(
        true,
        std.mem.eql(u8, concat, "Hello, world!"),
    );
}

test "string startsWith" {
    const str = "Hello, world!";
    try expectEqual(
        true,
        std.mem.startsWith(u8, str, "Hello"),
    );
    try expectEqual(
        false,
        std.mem.startsWith(u8, str, "world"),
    );
}

test "string replace" {
    const str = "Hello";
    var buffer: [5]u8 = undefined;
    const nrep = std.mem.replace(u8, str, "el", "37", buffer[0..]);
    try expectEqual(
        true,
        std.mem.eql(u8, &buffer, "H37lo"),
    );
    try expectEqual(
        @as(u32, 1),
        nrep,
    );
}

test "if statement" {
    var a: i32 = undefined;
    const t = true;

    if (t) {
        a = 1;
    } else {
        a = 2;
    }
    try expectEqual(@as(i32, 1), a);
}

test "switch statement" {
    const Kind = enum { Mammal, Bird, Fish };
    var desc: []const u8 = undefined;
    const kind = Kind.Mammal;

    switch (kind) {
        Kind.Mammal => {
            desc = "Mammal";
        },
        Kind.Bird => {
            desc = "Bird";
        },
        Kind.Fish => {
            desc = "Fish";
        },
    }

    try expectEqual(@as(u32, 6), desc.len);
    try expectEqual(true, std.mem.eql(u8, desc, "Mammal"));
}

test "switch else" {
    const n: i32 = 7;
    var y: i32 = undefined;

    switch (n) {
        1, 2, 3 => y = 1,
        4, 5, 6 => y = 2,
        else => y = 3,
    }
    try expectEqual(@as(i32, 3), y);
}

test "switch value" {
    const n: i32 = 7;
    const desc = switch (n) {
        1, 2, 3 => "one",
        4, 5, 6 => "two",
        else => "three",
    };
    try expectEqual(std.mem.eql(u8, desc, "three"), true);
}

test "switch ranges" {
    const n: i32 = 65;
    const desc = switch (n) {
        1...10 => "one",
        11...20 => "two",
        21...30 => "three",
        31...40 => "four",
        41...50 => "five",
        51...60 => "six",
        else => "seven",
    };
    try expectEqual(std.mem.eql(u8, desc, "seven"), true);
}

test "labeled switch" {
    const v: i32 = 1;
    var val: i32 = undefined;
    cont: switch (v) {
        1 => continue :cont 2,
        2 => continue :cont 3,
        3 => val = 4,
        else => val = 5,
    }
    try expectEqual(@as(u8, 4), val);
}

test "defer" {
    var a: i32 = 0;

    if (true) {
        defer a += 1;
        defer a *= 3; // Last in first out
        a += 1;
    }
    try expectEqual(@as(i32, 4), a);
}

test "for loop" {
    const arr = [_]u8{ 1, 2, 3, 4 };
    var sum: i32 = 0;
    for (arr) |i| {
        sum += i;
    }
    try expectEqual(@as(i32, 10), sum);
}

test "for index and value" {
    const arr = [_]u8{ 1, 2, 3, 4 };
    var sum: usize = 0;
    for (arr, 0..) |i, j| {
        sum += i + j;
    }
    try expectEqual(@as(usize, 16), sum);
}

test "while loop" {
    var i: i32 = 0;
    while (i < 10) {
        i += 1;
    }
    try expectEqual(@as(i32, 10), i);
}

test "while loop with increment expression" {
    var i: i32 = 0;
    var j: i32 = 0;
    while (i < 10) : (i += 1) {
        j += 1;
    }
    try expectEqual(@as(i32, 10), i);
    try expectEqual(@as(i32, 10), j);
}

test "break" {
    var i: i32 = 0;
    while (true) {
        i += 1;
        if (i == 10) {
            break;
        }
    }
    try expectEqual(@as(i32, 10), i);
}

test "continue" {
    var i: i32 = 0;
    var j: i32 = 0;
    while (i < 10) : (i += 1) {
        if (@mod(i, 2) == 0) {
            continue;
        }
        j += i;
    }
    try expectEqual(@as(i32, 1 + 3 + 5 + 7 + 9), j);
}

fn add2(x: *i32) void {
    x.* += 2;
}

test "reference and dereference" {
    var a: i32 = 1;
    add2(&a);
    try expectEqual(@as(i32, 3), a);
}

const Point = struct {
    x: i32,
    y: i32,

    pub fn init(x: i32, y: i32) Point {
        return Point{ .x = x, .y = y };
    }
};
test "struct basics" {
    const p1 = Point{ .x = 1, .y = 2 };
    try expectEqual(@as(i32, 1), p1.x);
    try expectEqual(@as(i32, 2), p1.y);
    const p2 = Point.init(3, 4);
    try expectEqual(@as(i32, 3), p2.x);
    try expectEqual(@as(i32, 4), p2.y);
}

const Vec3 = struct {
    x: f64,
    y: f64,
    z: f64,

    fn d2(a: f64, b: f64) f64 {
        const m = std.math;
        return m.pow(f64, a - b, 2);
    }

    pub fn distance(self: Vec3, other: Vec3) f64 {
        const m = std.math;
        return m.sqrt(
            d2(self.x, other.x) +
                d2(self.y, other.y) +
                d2(self.z, other.z),
        );
    }

    pub fn double(self: *Vec3) void {
        self.x *= 2;
        self.y *= 2;
        self.z *= 2;
    }
};

test "self" {
    const p1 = Vec3{ .x = 1, .y = 2, .z = 3 };
    const p2 = Vec3{ .x = 4, .y = 5, .z = 6 };
    const d = p1.distance(p2);
    try expectEqual(@as(f64, 5.196152422706632), d);
    var p3 = Vec3{ .x = 1, .y = 2, .z = 3 };
    p3.double();
    try expectEqual(@as(f64, 2), p3.x);
    try expectEqual(@as(f64, 4), p3.y);
    try expectEqual(@as(f64, 6), p3.z);
}

test "type inference with dot" {
    const Fruit = enum { Apple, Orange, Banana };
    const fruit: Fruit = .Apple;
    try expectEqual(.Apple, fruit);
}

test "type casting with as" {
    const a: usize = 65535;
    const b: u32 = @as(u32, a);
    try expectEqual(@as(u32, 65535), b);
    try expectEqual(@TypeOf(b), u32);
}

test "specialized type casting" {
    const a: usize = 422;
    const b: f32 = @floatFromInt(a);
    try expectEqual(@as(f32, 422), b);
    try expectEqual(@TypeOf(b), f32);
}

test "ptrCast" {
    const bytes align(@alignOf(u32)) = [_]u8{ 1, 2, 3, 4 };
    const u32_ptr: *const u32 = @ptrCast(&bytes);
    try expectEqual(@TypeOf(u32_ptr), *const u32);
}

test "allocPrint" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const str = try std.fmt.allocPrint(allocator, "Hello {s}", .{"World"});
    defer allocator.free(str);
    try expectEqual(std.mem.eql(u8, str, "Hello World"), true);
}

test "GeneralPurposeAllocator create, destroy" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const num = try allocator.create(u8);
    defer allocator.destroy(num);
    num.* = 10;
    try expectEqual(@as(u32, 10), num.*);
}

test "BufferAllocator" {
    var buffer: [10]u8 = undefined;
    for (0..buffer.len) |i| {
        buffer[i] = 0;
    }
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();
    const num = try allocator.alloc(u8, 5);
    defer allocator.free(num);
    for (0..5) |i| {
        num[i] = @intCast(i);
    }
    try expectEqual(@as(u8, 0), num[0]);
    try expectEqual(@as(u8, 1), num[1]);
    try expectEqual(@as(u8, 2), num[2]);
    try expectEqual(@as(u8, 3), num[3]);
    try expectEqual(@as(u8, 4), num[4]);
}

test "ArenaAllocator" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var aa = std.heap.ArenaAllocator.init(gpa.allocator());
    defer aa.deinit(); // this will free all allocations in the arena
    const allocator = aa.allocator();
    const in1 = allocator.alloc(u8, 5);
    const in2 = allocator.alloc(u8, 10);
    const in3 = allocator.alloc(u8, 15);
    _ = try in1;
    _ = try in2;
    _ = try in3;
}

test "alloc free" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const num = try allocator.alloc(u8, 5);
    defer allocator.free(num);
    for (0..5) |i| {
        num[i] = @intCast(i);
    }
    try expectEqual(@as(u8, 0), num[0]);
    try expectEqual(@as(u8, 1), num[1]);
    try expectEqual(@as(u8, 2), num[2]);
    try expectEqual(@as(u8, 3), num[3]);
    try expectEqual(@as(u8, 4), num[4]);
}

fn test_stdin() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    const buffer_opt = try stdin.readUntilDelimiterOrEofAlloc(allocator, '\n', 100);
    if (buffer_opt) |buffer| {
        defer allocator.free(buffer);
        try stdout.print("<<stdin: {s}>>\n", .{buffer});
    } else {
        try stdout.print("<<stdin: EOF>>\n", .{});
    }
}

test "struct create destroy" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const User = struct {
        name: []const u8,
        age: u32,
    };
    const user = try allocator.create(User);
    defer allocator.destroy(user);
    user.* = User{ .name = "Mohsen", .age = 30 };
    try expectEqual(std.mem.eql(u8, user.name, "Mohsen"), true);
    try expectEqual(@as(u32, 30), user.age);
}

const Base64 = struct {
    _table: *const [64]u8,

    pub fn init() Base64 {
        const upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        const lower = "abcdefghijklmnopqrstuvwxyz";
        const digits = "0123456789+/";
        return Base64{ ._table = upper ++ lower ++ digits };
    }

    pub fn _char_at(self: Base64, index: u8) u8 {
        return self._table[index];
    }

    fn _calc_encode_length(input: []const u8) !usize {
        if (input.len < 3) {
            return 4;
        }

        return try std.math.divCeil(usize, input.len, 3) * 4;
    }

    fn _calc_decode_length(input: []const u8) !usize {
        if (input.len < 4) {
            return 3;
        }
        return try std.math.divFloor(usize, input.len, 4) * 3;
    }

    pub fn encode(self: Base64, allocator: std.mem.Allocator, input: []const u8) ![]u8 {
        if (input.len == 0) {
            return allocator.alloc(u8, 0);
        }

        const n_out = try _calc_encode_length(input);
        var out = try allocator.alloc(u8, n_out);
        var buf = [3]u8{ 0, 0, 0 };
        var count: u8 = 0;
        var iout: u64 = 0;

        for (input, 0..) |_, i| {
            buf[count] = input[i];
            count += 1;
            if (count == 3) {
                out[iout] = self._char_at(buf[0] >> 2);
                out[iout + 1] = self._char_at(((buf[0] & 0x03) << 4) | (buf[1] >> 4));
                out[iout + 2] = self._char_at(((buf[1] & 0x0F) << 2) | (buf[2] >> 6));
                out[iout + 3] = self._char_at(buf[2] & 0x3F);
                iout += 4;
                count = 0;
            }
        }

        if (count == 1) {
            out[iout] = self._char_at(buf[0] >> 2);
            out[iout + 1] = self._char_at((buf[0] & 0x03) << 4);
            out[iout + 2] = '=';
            out[iout + 3] = '=';
        } else if (count == 2) {
            out[iout] = self._char_at(buf[0] >> 2);
            out[iout + 1] = self._char_at(((buf[0] & 0x03) << 4) | (buf[1] >> 4));
            out[iout + 2] = self._char_at((buf[1] & 0x0F) << 2);
            out[iout + 3] = '=';
        }

        return out;
    }

    fn _char_index(c: u8) u8 {
        if (c >= 'A' and c <= 'Z') {
            return c - 'A';
        } else if (c >= 'a' and c <= 'z') {
            return c - 'a' + 26;
        } else if (c >= '0' and c <= '9') {
            return c - '0' + 52;
        } else if (c == '+') {
            return 62;
        } else if (c == '/') {
            return 63;
        }
        return 64; // Invalid character
    }

    pub fn decode(self: Base64, allocator: std.mem.Allocator, input: []const u8) ![]u8 {
        _ = self;
        if (input.len == 0) {
            return allocator.alloc(u8, 0);
        }

        const n_out = try _calc_decode_length(input);
        var out = try allocator.alloc(u8, n_out);
        var buf = [4]u8{ 0, 0, 0, 0 };
        var count: u8 = 0;
        var iout: u64 = 0;

        for (0..input.len) |i| {
            buf[count] = _char_index(input[i]);
            count += 1;
            if (count == 4) {
                out[iout] = (buf[0] << 2) | (buf[1] >> 4);
                if (buf[2] != 64) {
                    out[iout + 1] = ((buf[1] & 0x0F) << 4) | (buf[2] >> 2);
                } else {
                    out[iout + 1] = 0;
                }
                if (buf[3] != 64) {
                    out[iout + 2] = ((buf[2] & 0x03) << 6) | buf[3];
                } else {
                    out[iout + 2] = 0;
                }
                iout += 3;
                count = 0;
            }
        }

        return out;
    }
};

test "Base64 init" {
    const base64 = Base64.init();
    try expectEqual(@as(u8, 'c'), base64._char_at(28));
}

test "Base64 encode" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const base64 = Base64.init();
    const inp1 = "Hello, world!";
    const enc1 = try base64.encode(allocator, inp1);
    defer allocator.free(enc1);
    try expectEqual(std.mem.eql(u8, enc1, "SGVsbG8sIHdvcmxkIQ=="), true);
    const inp2 = "Hi";
    const enc2 = try base64.encode(allocator, inp2);
    defer allocator.free(enc2);
    try expectEqual(std.mem.eql(u8, enc2, "SGk="), true);
    const inp3 = "A";
    const enc3 = try base64.encode(allocator, inp3);
    defer allocator.free(enc3);
    try expectEqual(std.mem.eql(u8, enc3, "QQ=="), true);
    const inp4 = "";
    const enc4 = try base64.encode(allocator, inp4);
    defer allocator.free(enc4);
    try expectEqual(std.mem.eql(u8, enc4, ""), true);
}

test "Base64 decode" {
    var mem: [1000]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&mem);
    const allocator = fba.allocator();
    const base64 = Base64.init();

    const inp4 = "";
    const dec4 = try base64.decode(allocator, inp4);
    try expectEqual(std.mem.eql(u8, dec4, ""), true);

    const inp3 = "QQ==";
    const dec3 = try base64.decode(allocator, inp3);
    try expectEqual(std.mem.eql(u8, dec3, &.{ 'A', 0, 0 }), true);

    const inp2 = "SGk=";
    const dec2 = try base64.decode(allocator, inp2);
    try expectEqual(std.mem.eql(u8, dec2, &.{ 'H', 'i', 0 }), true);

    const inp1 = "SGVsbG8sIHdvcmxkIQ==";
    const dec1 = try base64.decode(allocator, inp1);
    try expectEqual(std.mem.eql(u8, dec1, &.{ 'H', 'e', 'l', 'l', 'o', ',', ' ', 'w', 'o', 'r', 'l', 'd', '!', 0, 0 }), true);
}

test "pointer" {
    const a: i32 = 1;
    const b = &a;
    try expectEqual(@as(i32, 1), b.*);
    try expectEqual(@TypeOf(b), *const i32);
}

test "pointer dereference chaining" {
    const User = struct {
        name: []const u8,
        age: u32,
    };

    const u = User{ .name = "Mohsen", .age = 30 };
    const p = &u;
    try expectEqual(30, p.*.age);
}

test "const pointer to var" {
    var a: i32 = 1;
    const b = &a;
    b.* = 2; // This is allowed because `b` is a pointer to a variable.
    try expectEqual(@as(i32, 2), a);
}

test "var pointer to different const" {
    const a: i32 = 1;
    const b: i32 = 2;
    var p = &a;
    try expectEqual(@as(i32, 1), p.*);
    p = &b;
    try expectEqual(@as(i32, 2), p.*);
}

test "pointer arithmetic" {
    var arr = [_]u8{ 1, 2, 3, 4 };
    var p: [*]const u8 = &arr;
    const el1 = p[0];
    p = p + 1;
    const el2 = p[0];
    p = p + 1;
    const el3 = p[0];
    p = p + 1;
    const el4 = p[0];
    try expectEqual(@as(u8, 1), el1);
    try expectEqual(@as(u8, 2), el2);
    try expectEqual(@as(u8, 3), el3);
    try expectEqual(@as(u8, 4), el4);
}

test "optional" {
    var a: ?i32 = 0;
    a = null;
}

test "optional pointer" {
    var a: i32 = 1;
    var p: ?*i32 = &a;
    p = null;
}

test "unwrap optional with if" {
    const a: ?i32 = 1;
    if (a) |v| {
        try expectEqual(@as(i32, 1), v);
    } else {
        unreachable;
    }
}

test "orelse" {
    const a: ?i32 = null;
    const b: i32 = (a orelse 3) * 2;
    try expectEqual(@as(i32, 6), b);
}

const HttpServer = struct {
    const Socket = struct {
        _address: std.net.Address,
        _stream: std.net.Stream,

        pub fn init() !Socket {
            const host = [4]u8{ 127, 0, 0, 1 };
            const port = 8080;
            const addr = std.net.Address.initIp4(host, port);
            const sock_fd: i32 = try std.posix.socket(addr.any.family, std.posix.SOCK.STREAM, std.posix.IPPROTO.TCP);
            const stream = std.net.Stream{ .handle = sock_fd };
            return Socket{ ._address = addr, ._stream = stream };
        }
    };

    const Connection = std.net.Server.Connection;
    pub fn read_request(conn: Connection, buffer: []u8) !void {
        const reader = conn.stream.reader();
        _ = try reader.read(buffer);
    }

    const Method = enum {
        GET,

        pub fn init(text: []const u8) !Method {
            return MethodMap.get(text).?;
        }

        pub fn is_supported(m: []const u8) bool {
            return MethodMap.contains(m);
        }
    };

    const Map = std.static_string_map.StaticStringMap;
    const MethodMap = Map(Method).initComptime(.{.{ "GET", .GET }});
    const Request = struct {
        method: Method,
        version: []const u8,
        uri: []const u8,
        pub fn init(method: Method, uri: []const u8, version: []const u8) Request {
            return Request{ .method = method, .uri = uri, .version = version };
        }
    };
    fn parse_request(text: []u8) !Request {
        const line_index = std.mem.indexOfScalar(u8, text, '\n') orelse text.len;
        var iterator = std.mem.splitScalar(u8, text[0..line_index], ' ');
        const method_str = iterator.next();
        const method = try Method.init(method_str.?);
        const uri = iterator.next().?;
        const version = iterator.next().?;
        const request = Request.init(method, uri, version);
        return request;
    }
    fn send_200(conn: Connection) !void {
        const response = ("HTTP/1.1 200 OK\nContent-Length: 48" ++ "\nContent-Type: text/html\n" ++ "Connection: Closed\n\n" ++ "<html><body><h1>Hello, World!</h1></body></html>");
        _ = try conn.stream.write(response);
    }

    fn send_404(conn: Connection) !void {
        const response = ("HTTP/1.1 404 Not Found\nContent-Length: 50" ++ "\nContent-Type: text/html\n" ++ "Connection: Closed\n\n");
        _ = try conn.stream.write(response);
    }
    pub fn start(self: HttpServer) !void {
        _ = self;
        const socket = try Socket.init();
        std.debug.print("Socket initialized {any}.\n", .{socket._address});
        var server = try socket._address.listen(.{});
        const connection = try server.accept();
        var buffer: [1024]u8 = undefined;
        for (0..buffer.len) |i| {
            buffer[i] = 0;
        }
        _ = try read_request(connection, buffer[0..buffer.len]);
        const request = try parse_request(buffer[0..]);
        if (request.method == .GET) {
            if (std.mem.eql(u8, request.uri, "/")) {
                try send_200(connection);
            } else {
                try send_404(connection);
            }
        }
    }
};

fn alloc_100(allocator: std.mem.Allocator) ![]u8 {
    const buffer = try allocator.alloc(u8, 100);
    defer allocator.free(buffer);
    for (0..buffer.len) |i| {
        buffer[i] = @intCast(i);
    }
    return buffer;
}

test "expectError" {
    var buffer: [10]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();
    try std.testing.expectError(error.OutOfMemory, alloc_100(allocator));
}

test "expectEqualSlices" {
    const a = [_]u8{ 1, 2, 3, 4 };
    const b = [_]u8{ 1, 2, 3, 4 };
    try std.testing.expectEqualSlices(u8, &a, &b);
}

test "expectEqualStrings" {
    const a = "Hello, world!";
    const b = "Hello, world!";
    try std.testing.expectEqualStrings(a, b);
}

test "basic error checking" {
    const dir = std.fs.cwd();
    // _ = dir.openFile("main.zig", .{}); // this will not compile
    _ = try dir.openFile("main.zig", .{}); // this will compile
}

const TestError = error{
    Unexcpected,
    OutOfMemory,
};

fn test_error() TestError!void {
    return TestError.Unexcpected;
}

test "error enum" {
    const err = test_error();
    try std.testing.expectEqual(err, TestError.Unexcpected);
}

const TestSubError = error{
    OutOfMemory,
};

fn test_sub_error() TestSubError!void {
    return TestSubError.OutOfMemory;
}

test "casting suberrors" {
    const err = test_sub_error();
    try std.testing.expectEqual(err, TestError.OutOfMemory);
}

fn conditional_error(a: i32) TestError!i32 {
    if (a == 0) {
        return TestError.Unexcpected;
    }
    return 27;
}
test "catch error" {
    const e = conditional_error(0) catch 20;
    try expectEqual(@as(i32, 20), e);
}

test "catch to default error values" {
    // parse a string into an integer
    const n1 = std.fmt.parseInt(i32, "1234", 10) catch 0;
    try expectEqual(@as(i32, 1234), n1);
    const n2 = std.fmt.parseInt(i32, "abc", 10) catch -1;
    try expectEqual(@as(i32, -1), n2);
}

test "using if to catch errors" {
    if (std.fmt.parseInt(i32, "422", 10)) |n| {
        try expectEqual(@as(i32, 422), n);
    } else |err| {
        switch (err) {
            error.Overflow => unreachable,
            error.InvalidCharacter => unreachable,
        }
    }
}
