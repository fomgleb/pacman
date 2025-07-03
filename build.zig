const std = @import("std");
const Build = std.Build;
const Step = Build.Step;
const Module = Build.Module;
const Import = Module.Import;
const ResolvedTarget = Build.ResolvedTarget;
const OptimizeMode = std.builtin.OptimizeMode;

pub fn build(b: *Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const main_module = b.createModule(.{ .root_source_file = b.path("src/main.zig"), .target = target, .optimize = optimize });
    const sdl_dep = b.dependency("sdl", .{ .target = target, .optimize = optimize });
    const sdl_image = createSdlImageLibrary(b, target, optimize, sdl_dep.artifact("SDL3"));
    main_module.linkLibrary(sdl_dep.artifact("SDL3"));
    main_module.linkLibrary(sdl_image.artifact);
    const main_exe = createMainExecutable(b, main_module);
    addCheckStep(b, main_module);
    addRunStep(b, main_exe);

    const test_module = b.createModule(.{ .root_source_file = b.path("src/test.zig"), .target = target, .optimize = optimize });
    const test_exe = addTestExeStep(b, test_module);
    addTestStep(b, test_exe);
}

fn createMainExecutable(b: *Build, main_module: *Module) *Step.Compile {
    const exe = b.addExecutable(.{
        .name = "pacman",
        .root_module = main_module,
    });
    b.installArtifact(exe);
    return exe;
}

fn addCheckStep(b: *Build, main_module: *Module) void {
    const check_command = b.addExecutable(.{
        .name = "check",
        .root_module = main_module,
    });
    b.step("check", "Check if project compiles").dependOn(&check_command.step);
}

fn addRunStep(b: *Build, exe: *Build.Step.Compile) void {
    const run_command = b.addRunArtifact(exe);
    run_command.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_command.addArgs(args);
    b.step("run", "Run the app").dependOn(&run_command.step);
}

fn addTestExeStep(b: *Build, test_module: *Module) *Step.Compile {
    const test_exe = b.addTest(.{
        .name = "test_exe",
        .root_module = test_module,
    });
    const install_test_exe = b.addInstallArtifact(test_exe, .{});
    b.step("test_exe", "Compile `text_exe` for debugging tests").dependOn(&install_test_exe.step);
    return test_exe;
}

fn addTestStep(b: *Build, test_exe: *Build.Step.Compile) void {
    const run_all_tests = b.addRunArtifact(test_exe);
    b.step("test", "Run unit tests").dependOn(&run_all_tests.step);
}

fn createSdlImageLibrary(b: *Build, target: ResolvedTarget, optimize: OptimizeMode, sdl: *Step.Compile) *Step.InstallArtifact {
    const c_sdl_image_dep = b.dependency("sdl_image", .{});

    const lib = b.addLibrary(.{
        .name = "sdl_image",
        .version = .{ .major = 3, .minor = 2, .patch = 4 },
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    lib.linkLibrary(sdl);

    // Use stb_image for loading JPEG and PNG files. Native alternatives such as
    // Windows Imaging Component and Apple's Image I/O framework are not yet
    // supported by this build script.
    lib.root_module.addCMacro("USE_STBIMAGE", "");

    // The following are options for supported file formats. AVIF, JXL, TIFF,
    // and WebP are not yet supported by this build script, as they require
    // additional dependencies.
    if (b.option(bool, "enable-bmp", "Support loading BMP images") orelse true)
        lib.root_module.addCMacro("LOAD_BMP", "");
    if (b.option(bool, "enable-gif", "Support loading GIF images") orelse true)
        lib.root_module.addCMacro("LOAD_GIF", "");
    if (b.option(bool, "enable-jpg", "Support loading JPEG images") orelse true)
        lib.root_module.addCMacro("LOAD_JPG", "");
    if (b.option(bool, "enable-lbm", "Support loading LBM images") orelse true)
        lib.root_module.addCMacro("LOAD_LBM", "");
    if (b.option(bool, "enable-pcx", "Support loading PCX images") orelse true)
        lib.root_module.addCMacro("LOAD_PCX", "");
    if (b.option(bool, "enable-png", "Support loading PNG images") orelse true)
        lib.root_module.addCMacro("LOAD_PNG", "");
    if (b.option(bool, "enable-pnm", "Support loading PNM images") orelse true)
        lib.root_module.addCMacro("LOAD_PNM", "");
    if (b.option(bool, "enable-qoi", "Support loading QOI images") orelse true)
        lib.root_module.addCMacro("LOAD_QOI", "");
    if (b.option(bool, "enable-svg", "Support loading SVG images") orelse true)
        lib.root_module.addCMacro("LOAD_SVG", "");
    if (b.option(bool, "enable-tga", "Support loading TGA images") orelse true)
        lib.root_module.addCMacro("LOAD_TGA", "");
    if (b.option(bool, "enable-xcf", "Support loading XCF images") orelse true)
        lib.root_module.addCMacro("LOAD_XCF", "");
    if (b.option(bool, "enable-xpm", "Support loading XPM images") orelse true)
        lib.root_module.addCMacro("LOAD_XPM", "");
    if (b.option(bool, "enable-xv", "Support loading XV images") orelse true)
        lib.root_module.addCMacro("LOAD_XV", "");

    lib.addIncludePath(c_sdl_image_dep.path("include"));
    lib.addIncludePath(c_sdl_image_dep.path("src"));

    lib.addCSourceFiles(.{
        .root = c_sdl_image_dep.path("src"),
        .files = &.{
            "IMG.c",
            "IMG_WIC.c",
            "IMG_avif.c",
            "IMG_bmp.c",
            "IMG_gif.c",
            "IMG_jpg.c",
            "IMG_jxl.c",
            "IMG_lbm.c",
            "IMG_pcx.c",
            "IMG_png.c",
            "IMG_pnm.c",
            "IMG_qoi.c",
            "IMG_stb.c",
            "IMG_svg.c",
            "IMG_tga.c",
            "IMG_tif.c",
            "IMG_webp.c",
            "IMG_xcf.c",
            "IMG_xpm.c",
            "IMG_xv.c",
        },
    });

    if (target.result.os.tag == .macos) {
        lib.addCSourceFile(.{
            .file = c_sdl_image_dep.path("src/IMG_ImageIO.m"),
        });
        lib.linkFramework("Foundation");
        lib.linkFramework("ApplicationServices");
    }

    lib.installHeadersDirectory(c_sdl_image_dep.path("include"), "", .{});

    return b.addInstallArtifact(lib, .{});
}
