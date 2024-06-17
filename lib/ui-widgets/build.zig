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
        .name = "ui-widgets",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
    });

    lib.addIncludePath(b.path("./include/"));
    lib.addIncludePath(b.path("./src/"));

    lib.installHeadersDirectory(b.path("include/"), "", .{});

    lib.addCSourceFiles(.{
        .files = &.{
            "src/anchor.c",
            "src/button.c",
            "src/canvas.c",
            "src/scrollbar.c",
            "src/text.c",
            "src/textcaret.c",
            "src/textinput.c",
            "src/textstyle.c",
        },
        .flags = &.{},
    });

    const libyutil = b.dependency("libyutil", .{});
    lib.linkLibrary(libyutil.artifact("yutil"));

    const libplatform = b.dependency("libplatform", .{});
    lib.linkLibrary(libplatform.artifact("platform"));

    const libpandagl = b.dependency("libpandagl", .{});
    lib.linkLibrary(libpandagl.artifact("pandagl"));

    const libcss = b.dependency("libcss", .{});
    lib.linkLibrary(libcss.artifact("css"));

    const libthread = b.dependency("libthread", .{});
    lib.linkLibrary(libthread.artifact("thread"));

    const libworker = b.dependency("libworker", .{});
    lib.linkLibrary(libworker.artifact("worker"));

    const libuixml = b.dependency("libuixml", .{});
    lib.linkLibrary(libuixml.artifact("ui-xml"));

    const libui = b.dependency("libui", .{});
    lib.linkLibrary(libui.artifact("ui"));

    const libtimer = b.dependency("libtimer", .{});
    lib.linkLibrary(libtimer.artifact("timer"));

    const config_h = b.addConfigHeader(.{
        .style = .blank,
        .include_path = "config.h",
    }, .{
        .LIBUI_WIDGETS_VERSION = "3.0",
        .LIBUI_WIDGETS_VERSION_MAJOR = 1,
        .LIBUI_WIDGETS_VERSION_MINOR = 0,
        .LIBUI_WIDGETS_VERSION_ALTER = 1,
        .LIBUI_WIDGETS_STATIC_BUILD = {},
    });

    lib.addConfigHeader(config_h);

    lib.linkLibC();
    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    b.installArtifact(lib);
}
