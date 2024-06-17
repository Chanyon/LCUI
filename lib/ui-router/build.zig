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
        .name = "ui-router",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
    });

    lib.addIncludePath(b.path("./include/"));
    lib.addIncludePath(b.path("./src/"));

    lib.addCSourceFiles(.{
        .files = &.{
            "src/config.c",
            "src/history.c",
            "src/link.c",
            "src/location.c",
            "src/matcher.c",
            "src/route.c",
            "src/route_record.c",
            "src/strmap.c",
            "src/utils.c",
            "src/view.c",
        },
        .flags = &.{},
    });

    const yutil = b.dependency("libyutil", .{});
    lib.linkLibrary(yutil.artifact("yutil"));

    const ui = b.dependency("libui", .{});
    lib.linkLibrary(ui.artifact("ui"));
    const libcss = b.dependency("libcss", .{});
    // lib.linkLibrary(libcss.artifact("css"));

    lib.addIncludePath(libcss.path("include/"));

    const libpandagl = b.dependency("libpandagl", .{});
    lib.linkLibrary(libpandagl.artifact("pandagl"));

    const libuiwidgets = b.dependency("libuiwidgets", .{});
    lib.linkLibrary(libuiwidgets.artifact("ui-widgets"));

    const config_h = b.addConfigHeader(.{
        .style = .blank,
        .include_path = "config.h",
    }, .{
        .LIBUI_ROUTER_VERSION = "3.0",
        .LIBUI_ROUTER_VERSION_MAJOR = 1,
        .LIBUI_ROUTER_VERSION_MINOR = 0,
        .LIBUI_ROUTER_VERSION_ALTER = 1,
        .LIBUI_ROUTER_STATIC_BUILD = {},
    });

    lib.addConfigHeader(config_h);

    lib.linkLibC();

    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    b.installArtifact(lib);
}
