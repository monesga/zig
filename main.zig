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
