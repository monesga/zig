const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const option = b.option(bool, "os", "show build os") orelse false;
    if (option) {
        std.debug.print("Building for target: {}\n", .{builtin.os.tag});
    }
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

    const test_exe = b.addTest(.{
        .name = "unit_tests",
        .root_source_file = b.path("main.zig"),
        .target = b.graph.host,
        .optimize = .Debug, // .ReleaseSafe,
    });
    b.installArtifact(test_exe);
    const test_arti = b.addRunArtifact(test_exe);
    const test_step = b.step("test", "Run the tests");
    test_step.dependOn(&test_arti.step);
}
