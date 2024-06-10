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

    const lib = b.addStaticLibrary(.{
        .name = "ui-server",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
    });

    lib.addIncludePath(b.path("./include/"));
    lib.installHeadersDirectory(b.path("./include/"), "", .{});
    lib.addCSourceFiles(.{
        .files = &.{
            "src/server.c",
        },
        .flags = &.{},
    });

    const yutil = b.dependency("libyutil", .{});
    lib.linkLibrary(yutil.artifact("yutil"));

    const libui = b.dependency("libui", .{});
    lib.linkLibrary(libui.artifact("ui"));

    const libcss = b.dependency("libcss", .{});
    lib.linkLibrary(libcss.artifact("css"));
    lib.addIncludePath(libcss.path("include/"));

    const libplatform = b.dependency("libplatform", .{});
    lib.linkLibrary(libplatform.artifact("platform"));

    const libpandagl = b.dependency("libpandagl", .{});
    lib.linkLibrary(libpandagl.artifact("pandagl"));

    const libuicusor = b.dependency("libuicusor", .{});
    lib.linkLibrary(libuicusor.artifact("ui-cursor"));

    // lib.addIncludePath(.{ .cwd_relative = "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.39.33519/include" });
    // inline for (.{
    //     yutil,
    //     libcss,
    //     libpandagl,
    //     libplatform,
    //     libui,
    //     libuicusor,
    // }) |l| {
    //     lib.addLibraryPath(l.path("zig-out/lib/"));
    // }
    lib.linkLibC();

    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    b.installArtifact(lib);
}
