const std = @import("std");
const deps = @import("deps.zig");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const test_step = b.step("test", "Run all the tests");
    test_step.dependOn(b.getInstallStep());

    const tests = b.addTest("tests/tests.zig");
    deps.pkgs.addAllTo(tests);
    tests.addPackage(.{
        .name = "lsp",
        .path = .{ .path = "lsp.zig" },
        .dependencies = &[_]std.build.Pkg{deps.pkgs.tres},
    });
    tests.setTarget(target);
    tests.setBuildMode(mode);
    test_step.dependOn(&tests.step);
}
