const std = @import("std");
const Build = std.Build;
const Step = Build.Step;
const Module = Build.Module;
const Import = Module.Import;
const ResolvedTarget = Build.ResolvedTarget;
const OptimizeMode = std.builtin.OptimizeMode;

pub fn build(b: *Build) void {
    const t = b.standardTargetOptions(.{});
    const o = b.standardOptimizeOption(.{});

    const imports = &[_]Import{
        .{ .name = "entt", .module = b.dependency("entt", .{ .target = t, .optimize = o }).module("zig-ecs") },
    };

    const sdl_dep = b.dependency("sdl", .{ .target = t, .optimize = o });
    const sdl_image_dep = b.dependency("sdl_image", .{ .target = t, .optimize = o });
    const main_module = b.createModule(.{ .root_source_file = b.path("src/main.zig"), .target = t, .optimize = o, .imports = imports });
    main_module.linkLibrary(sdl_dep.artifact("SDL3"));
    main_module.linkLibrary(sdl_image_dep.artifact("SDL3_image"));
    const main_exe = createMainExecutable(b, main_module);
    addCheckStep(b, main_module);
    addRunStep(b, main_exe);

    const test_module = b.createModule(.{ .root_source_file = b.path("src/test.zig"), .target = t, .optimize = o, .imports = imports });
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
