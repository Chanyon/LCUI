const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "hello",
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
    });

    exe.addCSourceFiles(.{
        .files = &.{
            "src/main.c",
        },
        .flags = &.{"-Wno-error=expansion-to-defined"},
    });
    exe.addIncludePath(b.path("include/"));
    const liblcui = b.dependency("liblcui", .{});
    exe.linkLibrary(liblcui.artifact("lcui"));

    const config_h = b.addConfigHeader(.{
        .style = .blank,
        .include_path = "config.h",
    }, .{
        .PACKAGE_VERSION = "3.0.0",
        .LCUI_STATIC_BUILD = {},
    });

    exe.addConfigHeader(config_h);
    exe.linkLibC();
    b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
