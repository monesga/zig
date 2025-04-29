//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

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
    try std.testing.expectEqual(@as(u8, 3), b);
}

test "slice" {
    const a1 = [4]u8{ 1, 2, 3, 4 };
    const b = a1[1..3];
    try std.testing.expectEqual(@as(u8, 2), b[0]);
    try std.testing.expectEqual(@as(u8, 3), b[1]);
    try std.testing.expectEqual(@as(u32, 2), b.len);
    const c = a1[1..];
    try std.testing.expectEqual(@as(u8, 2), c[0]);
    try std.testing.expectEqual(@as(u8, 3), c[1]);
    try std.testing.expectEqual(@as(u8, 4), c[2]);
    try std.testing.expectEqual(@as(u32, 3), c.len);
}

test "array concat" {
    const a1 = [4]u8{ 1, 2, 3, 4 };
    const a2 = [4]u8{ 5, 6, 7, 8 };
    const b = a1 ++ a2;
    try std.testing.expectEqual(@as(u8, 1), b[0]);
    try std.testing.expectEqual(@as(u8, 2), b[1]);
    try std.testing.expectEqual(@as(u8, 3), b[2]);
    try std.testing.expectEqual(@as(u8, 4), b[3]);
    try std.testing.expectEqual(@as(u8, 5), b[4]);
    try std.testing.expectEqual(@as(u8, 6), b[5]);
    try std.testing.expectEqual(@as(u8, 7), b[6]);
    try std.testing.expectEqual(@as(u8, 8), b[7]);
    try std.testing.expectEqual(@as(u32, 8), b.len);
}

test "array replicate" {
    const a = [_]u8{ 1, 2 };
    const b = a ** 2;
    try std.testing.expectEqual(@as(u8, 1), b[0]);
    try std.testing.expectEqual(@as(u8, 2), b[1]);
    try std.testing.expectEqual(@as(u8, 1), b[2]);
    try std.testing.expectEqual(@as(u8, 2), b[3]);
    try std.testing.expectEqual(@as(u32, 4), b.len);
}

const std = @import("std");
