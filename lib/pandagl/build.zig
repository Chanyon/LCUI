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
        .name = "pandagl",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
    });

    lib.addIncludePath(b.path("include/"));
    lib.addIncludePath(b.path("src/font/"));
    lib.addIncludePath(b.path("src/image/"));

    lib.addCSourceFiles(.{
        .files = fontc,
        .flags = &.{},
    });
    lib.addCSourceFiles(.{
        .files = imagec,
        .flags = &.{},
    });
    lib.addCSourceFiles(.{
        .files = textc,
        .flags = &.{},
    });
    lib.addCSourceFiles(.{
        .files = &.{
            "src/background.c",
            "src/border.c",
            "src/boxshadow.c",
            "src/canvas.c",
            "src/context.c",
            "src/file_reader.c",
            "src/flip.c",
            "src/line.c",
            "src/pixel.c",
            "src/rect.c",
            "src/tile.c",
            "src/zoom.c",
        },
        .flags = &.{},
    });

    const libjpeg = b.dependency("libjpeg", .{});

    lib.addCSourceFiles(.{
        .root = libjpeg.path(""),
        .files = &.{
            "cdjpeg.c",
            "cjpeg.c",
            "djpeg.c",
            "jaricom.c",
            "jcapimin.c",
            "jcapistd.c",
            "jcarith.c",
            "jccoefct.c",
            // "jccolext.c",
            "jccolor.c",
            "jcdctmgr.c",
            "jcdiffct.c",
            "jchuff.c",
            "jcicc.c",
            "jcinit.c",
            "jclhuff.c",
            "jclossls.c",
            "jcmainct.c",
            "jcmarker.c",
            "jcmaster.c",
            "jcomapi.c",
            "jcparam.c",
            "jcphuff.c",
            "jcprepct.c",
            // "jcsample.c",
            "jctrans.c",
            "jdicc.c",
            "jdapimin.c",
            "jdapistd.c",
            "jdarith.c",
            "jdatadst-tj.c",
            "jdatadst.c",
            "jdatasrc-tj.c",
            "jdatasrc.c",
            // "jdcol565.c",
            // "jdcolext.c",
            "jdcolor.c",
            "jddctmgr.c",
            "jddiffct.c",
            "jdhuff.c",
            "jdicc.c",
            "jdinput.c",
            "jdlhuff.c",
            "jdlossls.c",
            "jdmainct.c",
            "jdmarker.c",
            "jdmaster.c",
            "jdmerge.c",
            // "jdmrg565.c",
            // "jdmrgext.c",
            "jdphuff.c",
            "jdpostct.c",
            // "jdsample.c",
            "jdtrans.c",
            "jerror.c",
            "jfdctflt.c",
            "jfdctfst.c",
            "jfdctint.c",
            "jidctflt.c",
            "jidctfst.c",
            "jidctint.c",
            "jidctred.c",
            "jmemmgr.c",
            "jmemnobs.c",
            "jpeg_nbits.c",
            "jpegtran.c",
            "jquant1.c",
            "jquant2.c",
            // "jstdhuff.c",
            "jutils.c",
            "rdbmp.c",
            "rdcolmap.c",
            "rdgif.c",
            "rdjpgcom.c",
            "rdppm.c",
            "rdswitch.c",
            "rdtarga.c",
            "strtest.c",
            "tjbench.c",
            // "tjexample.c",
            // "tjunittest.c",
            "tjutil.c",
            // "turbojpeg-jni.c",
            // "turbojpeg-mp.c",
            "turbojpeg.c",
            "wrbmp.c",
            "wrgif.c",
            "wrjpgcom.c",
            "wrppm.c",
            "wrtarga.c",
        },
    });

    lib.addIncludePath(b.path("jpeg/include/"));

    const libyutil = b.dependency("libyutil", .{});
    lib.linkLibrary(libyutil.artifact("yutil"));

    const libpng = b.dependency("libpng", .{ .target = target, .optimize = optimize });
    lib.linkLibrary(libpng.artifact("png"));

    //jpeg

    lib.installHeadersDirectory(b.path("include/"), "", .{});
    lib.installHeadersDirectory(libjpeg.path(""), "jpeg", .{ .include_extensions = &.{".h"} });
    lib.installHeadersDirectory(b.path("src/font/"), "font/", .{});
    lib.installHeadersDirectory(b.path("src/image/"), "image/", .{});
    // lib.installHeadersDirectory(b.path("jpeg/include/"), "jpeg/", .{});
    lib.linkLibC();

    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    b.installArtifact(lib);
}

const fontc = &.{
    //
    "src/font/bitmap.c",
    "src/font/freetype.c",
    "src/font/inconsolata.c",
    "src/font/incore.c",
    "src/font/library.c",
};

const imagec = &.{
    //
    "src/image/bmp.c",
    "src/image/jpeg.c",
    "src/image//png.c",
    "src/image/reader.c",
};

const textc = &.{
    //
    "src/text/style.c",
    "src/text/style_tag.c",
    "src/text/text.c",
};
