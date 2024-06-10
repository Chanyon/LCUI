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

    const libyutil = b.dependency("libyutil", .{});

    const lib = b.addStaticLibrary(.{
        .name = "css",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
    });

    lib.linkLibrary(libyutil.artifact("yutil"));

    lib.addIncludePath(b.path("include/"));
    lib.addIncludePath(b.path("src/"));

    lib.addCSourceFiles(.{
        .files = &.{
            //
            "src/properties/align_content.c",
            "src/properties/align_items.c",
            "src/properties/background.c",
            "src/properties/border.c",
            "src/properties/bottom.c",
            "src/properties/box_shadow.c",
            "src/properties/box_sizing.c",
            "src/properties/color.c",
            "src/properties/content.c",
            "src/properties/display.c",
            "src/properties/flex.c",
            "src/properties/font_family.c",
            "src/properties/font_size.c",
            "src/properties/font_style.c",
            "src/properties/font_weight.c",
            "src/properties/height.c",
            "src/properties/helpers.c",
            "src/properties/justify_content.c",
            "src/properties/left.c",
            "src/properties/line_height.c",
            "src/properties/margin.c",
            "src/properties/max_height.c",
            "src/properties/max_width.c",
            "src/properties/min_height.c",
            "src/properties/min_width.c",
            "src/properties/opacity.c",
            "src/properties/padding.c",
            "src/properties/pointer_events.c",
            "src/properties/position.c",
            "src/properties/right.c",
            "src/properties/text_align.c",
            "src/properties/top.c",
            "src/properties/vertical_align.c",
            "src/properties/visibility.c",
            "src/properties/white_space.c",
            "src/properties/width.c",
            "src/properties/word_break.c",
            "src/properties/z_index.c",
        },
        .flags = &.{},
    });

    lib.addCSourceFiles(.{
        .files = &.{
            "src/main.c",
            "src/style_decl.c",
            "src/style_parser.c",
            "src/style_value.c",
            "src/dump.c",
            "src/computed.c",
            "src/data_types.c",
            "src/font_face_parser.c",
            "src/keywords.c",
            "src/library.c",
            "src/parser.c",
            "src/properties.c",
            "src/selector.c",
            "src/utils.c",
            "src/value.c",
        },
        .flags = &.{},
    });

    lib.linkLibC();
    lib.installHeadersDirectory(b.path("include/"), "", .{});
    lib.installHeader(b.path("src/debug.h"), "debug.h");
    lib.installHeader(b.path("src/parser.h"), "parser.h");
    lib.installHeader(b.path("src/properties.h"), "properties.h");
    lib.installHeader(b.path("src/dump.h"), "dump.h");

    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    b.installArtifact(lib);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    // const lib_unit_tests = b.addExecutable(.{
    //     .name = "css_test",
    //     .root_source_file = null,
    //     .target = target,
    //     .optimize = optimize,
    // });

    // lib_unit_tests.addIncludePath(b.path("tests/test.h"));
    // lib_unit_tests.addIncludePath(b.path("include/css/"));
    // lib_unit_tests.addIncludePath(b.path("include/"));
    // lib_unit_tests.addIncludePath(b.path("src/"));

    // lib_unit_tests.addCSourceFiles(.{
    //     //
    //     .files = &.{
    //         "tests/test.c",
    //         "tests/test_css_keywords.c",
    //         "tests/test_css_computed.c",
    //         "tests/test_css_value.c",
    //     },
    //     .flags = &.{},
    // });
    // lib_unit_tests.linkLibrary(lib);

    // const libctest = b.dependency("libctest", .{});
    // lib_unit_tests.linkLibrary(libctest.artifact("ctest"));
    // lib_unit_tests.linkLibrary(libyutil.artifact("yutil"));
    // lib_unit_tests.linkLibC();

    // b.installArtifact(lib_unit_tests);

    // const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    // run_lib_unit_tests.step.dependOn(b.getInstallStep());
    // if (b.args) |args| {
    //     run_lib_unit_tests.addArgs(args);
    // }
    // // Similar to creating the run step earlier, this exposes a `test` step to
    // // the `zig build --help` menu, providing a way for the user to request
    // // running the unit tests.
    // const test_step = b.step("test", "Run unit tests");
    // test_step.dependOn(&run_lib_unit_tests.step);
}
