const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    std.debug.print("Building for target: {}\n", .{builtin.os.tag});
    const exe = b.addExecutable(.{
        .name = "main",
        .root_source_file = b.path("main.zig"),
        .target = b.graph.host,
        .optimize = .Debug, // .ReleaseSafe,
    });
    b.installArtifact(exe);
    const run_arti = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the executable");
    run_step.dependOn(&run_arti.step);
}
