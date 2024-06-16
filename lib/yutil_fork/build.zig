const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const static = b.option(bool, "static", "-Dstatic=true") orelse true;

    const lib = blk: {
        if (static) {
            break :blk b.addStaticLibrary(.{
                .name = "yutil",
                // In this case the main source file is merely a path, however, in more
                // complicated build scripts, this could be a generated file.
                .root_source_file = null,
                .target = target,
                .optimize = optimize,
            });
        } else {
            break :blk b.addSharedLibrary(.{
                .name = "yutil",
                // In this case the main source file is merely a path, however, in more
                // complicated build scripts, this could be a generated file.
                .root_source_file = null,
                .target = target,
                .optimize = optimize,
            });
        }
    };

    lib.addIncludePath(b.path("include/"));

    lib.addCSourceFiles(.{
        .files = &.{
            "src/charset.c",
            "src/dict.c",
            "src/list.c",
            "src/logger.c",
            "src/rbtree.c",
            "src/siphash.c",
            "src/string.c",
            "src/strlist.c",
            "src/strpool.c",
            "src/timer.c",
        },
        .flags = &.{ "-std=c99", "-Wno-error=deprecated-declarations", "-fno-strict-aliasing", "-Wno-error=expansion-to-defined" },
    });

    _ = switch (target.result.os.tag) {
        .linux => {
            lib.addCSourceFiles(.{
                .files = &.{
                    "src/dirent_linux.c",
                    "src/time_linux.c",
                },
                .flags = &.{},
            });
            lib.defineCMacro("_GNU_SOURCE=1", null);
        },
        .windows => {
            lib.addCSourceFiles(.{
                .files = &.{
                    "src/dirent_win32.c",
                    "src/time_win32.c",
                },
                .flags = &.{},
            });
            lib.defineCMacro("_CRT_SECURE_NO_WARNINGS", null);
        },
        else => {
            lib.defineCMacro("_GNU_SOURCE=1", null);
        },
    };

    lib.defineCMacro("_UNICODE", null);
    lib.defineCMacro("YUTIL_EXPORTS", null);

    lib.linkLibC();
    lib.installHeadersDirectory(b.path("include/"), "", .{});

    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    b.installArtifact(lib);

    const yutil_test = b.addExecutable(.{
        .name = "yutil_test",
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
    });

    yutil_test.addCSourceFiles(.{
        .flags = &.{},
        .files = &.{
            "test/test.c",
            "test/libtest.c",
            "test/test_charset.c",
            "test/test_dirent.c",
            "test/test_dict.c",
            "test/test_list.c",
            "test/test_logger.c",
            "test/test_rbtree.c",
            "test/test_string.c",
            "test/test_strpool.c",
            "test/test_timer.c",
            "test/test_time.c",
            "test/test_math.c",
            "test/test_list_entry.c",
        },
    });

    yutil_test.addIncludePath(b.path("test/"));
    yutil_test.linkLibrary(lib);
    yutil_test.linkLibC();

    b.installArtifact(yutil_test);

    const run_cmd = b.addRunArtifact(yutil_test);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_cmd.step);
}
