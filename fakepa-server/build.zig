const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});

    if (target.result.os.tag != .linux) {
        std.debug.print("OS not supported", .{});
        return;
    }

    // const arguments: [1]([]const u8) = .{"serve"};
    // const arguments: [1]?[]const u8 = .{"serve"};
    // std.os.linux.execve("ollama", arguments, null);
    const ollama_init_args: [2][]const u8 = .{ "ollama", "serve" };
    var ollama = std.process.Child.init(&ollama_init_args, std.heap.page_allocator);
    try ollama.spawn();
    // defer _ = ollama.kill();

    const optimize = b.standardOptimizeOption(.{});

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const pg = b.dependency("pg", .{
        .target = target,
        .optimize = optimize,
    });

    const zap = b.dependency("zap", .{
        .target = target,
        .optimize = optimize,
        .openssl = false, // set to true to enable TLS support
    });

    // const lib_mod = b.createModule(.{
    //     .root_source_file = b.path("src/root.zig"),
    //     .target = target,
    //     .optimize = optimize,
    // });

    // exe_mod.addImport("zap", zap);

    const exe = b.addExecutable(.{
        .name = "fakepa_server",
        .root_module = exe_mod,
    });

    exe.root_module.addImport("zap", zap.module("zap"));

    // the executable from your call to b.addExecutable(...)
    exe.root_module.addImport("pg", pg.module("pg"));

    // exe.root_module.addImport("routes", lib_mod);
    //
    // const lib = b.addLibrary(.{
    //     .linkage = .static,
    //     .name = "routes",
    //     .root_module = lib_mod,
    // });
    //
    // lib.root_module.addImport("zap", zap.module("zap"));

    // b.installArtifact(lib);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
