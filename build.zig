const std = @import("std");
const Build = std.Build;
const Step = Build.Step;
const Module = Build.Module;
const Import = Module.Import;
const ResolvedTarget = Build.ResolvedTarget;
const OptimizeMode = std.builtin.OptimizeMode;
const game_kit = @import("game_kit");

pub fn build(b: *Build) void {
    const t = b.standardTargetOptions(.{});
    const o = b.standardOptimizeOption(.{});

    const embed_resources = b.option(bool, "embed-resources", "Embed contents of `resources` folder into the executable?");
    const use_llvm = b.option(bool, "use-llvm", "Default is false");

    const game_kit_dep = b.dependency("game_kit", .{ .target = t, .optimize = o, .@"embed-resources" = embed_resources });
    const game_kit_module = game_kit_dep.module("game_kit");

    const imports = &[_]Import{
        .{ .name = "entt", .module = b.dependency("entt", .{ .target = t, .optimize = o }).module("zig-ecs") },
        .{ .name = "game_kit", .module = game_kit_module },
    };

    const main_module = b.createModule(.{ .root_source_file = b.path("src/main.zig"), .target = t, .optimize = o, .imports = imports });

    // TODO: All these manual addAnonymousImport can be done with iterating over "resources" folder
    // TODO: Rename "resources" -> "assets"
    game_kit.addAsset(b, game_kit_module, "resources/fonts/yoster.ttf");
    game_kit.addAsset(b, game_kit_module, "resources/ghosts/fast_stupid_ghost-move.png");
    game_kit.addAsset(b, game_kit_module, "resources/ghosts/kinda_smart_ghost-move.png");
    game_kit.addAsset(b, game_kit_module, "resources/ghosts/fat_genious_ghost-move.png");
    game_kit.addAsset(b, game_kit_module, "resources/grass/grass.png");
    game_kit.addAsset(b, game_kit_module, "resources/pacman/pacman-move.png");
    game_kit.addAsset(b, game_kit_module, "resources/wall/wall.png");
    game_kit.addAsset(b, game_kit_module, "resources/level.txt");
    game_kit.addAsset(b, game_kit_module, "resources/pellet.png");
    game_kit.addAsset(b, game_kit_module, "resources/smile-face.png");

    const main_exe = b.addExecutable(.{ .name = "pacman", .root_module = main_module, .use_llvm = use_llvm });
    b.installArtifact(main_exe);

    const check_command = b.addExecutable(.{ .name = "check", .root_module = main_module });
    b.step("check", "Check if project compiles").dependOn(&check_command.step);

    const run_command = b.addRunArtifact(main_exe);
    run_command.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_command.addArgs(args);
    b.step("run", "Run the app").dependOn(&run_command.step);

    const test_module = b.createModule(.{ .root_source_file = b.path("src/test.zig"), .target = t, .optimize = o, .imports = imports });
    const test_exe = addTestExeStep(b, test_module);
    addTestStep(b, test_exe);
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
