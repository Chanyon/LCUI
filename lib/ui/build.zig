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
        .name = "ui",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
    });

    lib.addIncludePath(b.path("include/"));
    lib.addIncludePath(b.path("src/"));

    lib.addCSourceFiles(.{
        .files = &.{
            "src/ui.c",
            "src/ui_block_layout.c",
            "src/ui_css.c",
            "src/ui_debug.c",
            "src/ui_diff.c",
            "src/ui_events.c",
            "src/ui_flexbox_layout.c",
            "src/ui_image.c",
            "src/ui_logger.c",
            "src/ui_metrics.c",
            "src/ui_mutation_observer.c",
            "src/ui_rect.c",
            "src/ui_renderer.c",
            "src/ui_root.c",
            "src/ui_text_style.c",
            "src/ui_tree.c",
            "src/ui_updater.c",
            "src/ui_widget.c",
            "src/ui_widget_attributes.c",
            "src/ui_widget_background.c",
            "src/ui_widget_border.c",
            "src/ui_widget_box.c",
            "src/ui_widget_box_shadow.c",
            "src/ui_widget_classes.c",
            "src/ui_widget_hash.c",
            "src/ui_widget_helper.c",
            "src/ui_widget_id.c",
            "src/ui_widget_layout.c",
            "src/ui_widget_observer.c",
            "src/ui_widget_prototype.c",
            "src/ui_widget_status.c",
            "src/ui_text_style.c",
        },
        .flags = &.{},
    });

    const libyutil = b.dependency("libyutil", .{});
    lib.linkLibrary(libyutil.artifact("yutil"));

    const libcss = b.dependency("libcss", .{});
    lib.linkLibrary(libcss.artifact("css"));

    const libth = b.dependency("libthread", .{});
    lib.linkLibrary(libth.artifact("thread"));

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
        .LIBCSS_STATIC_BUILD = {},
    });

    lib.addConfigHeader(config_h);

    lib.linkLibC();

    lib.installHeadersDirectory(b.path("include/"), "", .{});
    lib.installHeadersDirectory(b.path("src/"), "", .{ .include_extensions = &.{"h"} });
    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    b.installArtifact(lib);
}
