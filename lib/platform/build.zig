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
        .name = "platform",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
    });

    lib.addIncludePath(b.path("include/"));
    lib.addIncludePath(b.path("src/"));
    lib.installHeadersDirectory(b.path("./include/"), "", .{});
    lib.installHeadersDirectory(b.path("./src/"), "", .{ .include_extensions = &.{"h"} });
    lib.installHeadersDirectory(b.path("./src/windows/"), "", .{ .include_extensions = &.{"h"} });

    lib.addCSourceFiles(.{
        .files = &.{
            "src/app.c",
            "src/clipboard.c",
            "src/events.c",
            "src/ime.c",
            "src/steptimer.c",
        },
        .flags = &.{},
    });

    _ = switch (target.result.os.tag) {
        .linux => {
            lib.addCSourceFiles(.{
                .files = &.{
                    "src/linux/fb_app.c",
                    "src/linux/linux_app.c",
                    "src/linux/linux_ime.c",
                    "src/linux/linux_keyboard.c",
                    "src/linux/linux_mouse.c",
                    "src/linux/linux_x11clipboard.c",
                },
                .flags = &.{},
            });

            lib.linkSystemLibrary("pthread");
            lib.linkSystemLibrary("dl");
        },
        .windows => {
            lib.addCSourceFiles(.{
                .files = &.{
                    "src/windows/uri.c",
                    "src/windows/win32_app.c",
                    "src/windows/win32_ime.c",
                },
                .flags = &.{},
            });

            lib.linkSystemLibrary("Shell32");
            // lib.linkSystemLibrary("setupapi");
            // lib.linkSystemLibrary("winmm");
            lib.linkSystemLibrary("Gdi32");
            // lib.linkSystemLibrary("imm32");
            // lib.linkSystemLibrary("version");
            // lib.linkSystemLibrary("oleaut32");
            // lib.linkSystemLibrary("ole32");
            lib.linkSystemLibrary("User32");
        },
        else => {},
    };

    const libpandagl = b.dependency("libpandagl", .{});
    lib.linkLibrary(libpandagl.artifact("pandagl"));

    const libyutil = b.dependency("libyutil", .{});
    lib.linkLibrary(libyutil.artifact("yutil"));

    const config_h = b.addConfigHeader(.{
        .style = .blank,
        .include_path = "config.h",
    }, .{
        .LIBUI_XML_VERSION = "3.0",
        .LIBUI_XML_VERSION_MAJOR = 1,
        .LIBUI_XML_VERSION_MINOR = 0,
        .LIBUI_XML_VERSION_ALTER = 1,
        .LIBCSS_STATIC_BUILD = {},
        .LIBPLAT_HAS_X11 = {},
    });

    lib.addConfigHeader(config_h);

    lib.linkLibC();

    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    b.installArtifact(lib);
}
