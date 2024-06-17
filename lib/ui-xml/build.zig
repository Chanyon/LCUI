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
        .name = "ui-xml",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
    });

    lib.addIncludePath(b.path("include/"));
    lib.addCSourceFiles(.{
        .files = &.{
            //
            "src/ui_xml.c",
        },
        .flags = &.{},
    });

    const libxml2 = b.dependency("libxml2", .{ .target = target, .optimize = optimize });
    lib.linkLibrary(libxml2.artifact("libxml2"));

    const libyutil = b.dependency("libyutil", .{});
    lib.linkLibrary(libyutil.artifact("yutil"));

    const libcss = b.dependency("libcss", .{});
    lib.linkLibrary(libcss.artifact("css"));

    const libui = b.dependency("libui", .{});
    lib.linkLibrary(libui.artifact("ui"));

    const libpandagl = b.dependency("libpandagl", .{});
    lib.linkLibrary(libpandagl.artifact("pandagl"));

    const config_h = b.addConfigHeader(.{
        .style = .blank,
        .include_path = "config.h",
    }, .{
        .LIBUI_XML_VERSION = "3.0",
        .LIBUI_XML_VERSION_MAJOR = 1,
        .LIBUI_XML_VERSION_MINOR = 0,
        .LIBUI_XML_VERSION_ALTER = 1,
        .LIBUI_XML_STATIC_BUILD = {},
        .LIBUI_XML_HAS_LIBXML2 = {},
    });

    lib.addConfigHeader(config_h);

    lib.linkLibC();
    lib.installHeadersDirectory(b.path("include/"), "", .{});
    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    b.installArtifact(lib);
}
