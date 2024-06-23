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
        .name = "lcui",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
    });

    const libyutil = b.dependency("libyutil", .{});
    lib.linkLibrary(libyutil.artifact("yutil"));

    const libthread = b.dependency("libthread", .{});
    lib.linkLibrary(libthread.artifact("thread"));

    const libpandagl = b.dependency("libpandagl", .{});
    lib.linkLibrary(libpandagl.artifact("pandagl"));

    const libplatform = b.dependency("libplatform", .{});
    lib.linkLibrary(libplatform.artifact("platform"));

    const libworker = b.dependency("libworker", .{});
    lib.linkLibrary(libworker.artifact("worker"));

    const libtimer = b.dependency("libtimer", .{});
    lib.linkLibrary(libtimer.artifact("timer"));

    const libcss = b.dependency("libcss", .{});
    lib.linkLibrary(libcss.artifact("css"));

    // lib.addIncludePath(b.path("lib/i18n/include/"));
    // lib.addLibraryPath(b.path("lib/i18n/zig-out/lib/"));
    // lib.linkSystemLibrary("libi18n");

    const libui = b.dependency("libui", .{});
    lib.linkLibrary(libui.artifact("ui"));

    const libuicursor = b.dependency("libuicursor", .{});
    lib.linkLibrary(libuicursor.artifact("ui-cursor"));

    //server
    const libuiserver = b.dependency("libuiserver", .{});
    lib.linkLibrary(libuiserver.artifact("ui-server"));

    const libuixml = b.dependency("libuixml", .{});
    lib.linkLibrary(libuixml.artifact("ui-xml"));

    //widgets
    const libuiwidgets = b.dependency("libuiwidgets", .{});
    lib.linkLibrary(libuiwidgets.artifact("ui-widgets"));

    //router
    const libuirouter = b.dependency("libuirouter", .{});
    lib.linkLibrary(libuirouter.artifact("ui-router"));

    const config_h = b.addConfigHeader(.{
        .style = .blank,
        .include_path = "config.h",
    }, .{
        .PACKAGE_VERSION = "3.0.0",
        .LCUI_STATIC_BUILD = {},
    });

    lib.addConfigHeader(config_h);

    lib.addIncludePath(b.path("./include/"));
    lib.installHeadersDirectory(b.path("./include/"), "", .{});

    lib.addCSourceFiles(.{
        .files = &.{
            "src/lcui.c",
            "src/lcui_settings.c",
            "src/lcui_ui.c",
        },
        .flags = &.{},
    });

    lib.linkLibC();
    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    b.installArtifact(lib);
}
