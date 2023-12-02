const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardOptimizeOption(.{});

    const utils_module = b.createModule(.{ .source_file = .{ .path = "src/utils.zig" } });

    const install_all = b.step("install_all", "Install all days");
    const run_all = b.step("run_all", "Run all days");

    // Set up an exe for each day
    var day: u32 = 1;
    // TODO: update this to the correct number of days
    const max_day: u32 = 2;
    while (day <= max_day) : (day += 1) {
        const dayString = b.fmt("day{:0>2}", .{day});
        const zigFile = b.fmt("src/{s}/{s}.zig", .{ dayString, dayString });

        const exe = b.addExecutable(.{
            .name = dayString,
            .root_source_file = .{ .path = zigFile },
            .target = target,
            .optimize = mode,
        });
        exe.addModule("utils", utils_module);

        const install_cmd = b.addInstallArtifact(exe, .{});

        const build_test = b.addTest(.{
            .root_source_file = .{ .path = zigFile },
            .target = target,
            .optimize = mode,
        });
        build_test.addModule("utils", utils_module);

        const run_test = b.addRunArtifact(build_test);

        {
            const step_key = b.fmt("install_{s}", .{dayString});
            const step_desc = b.fmt("Install {s}.exe", .{dayString});
            const install_step = b.step(step_key, step_desc);
            install_step.dependOn(&install_cmd.step);
            install_all.dependOn(&install_cmd.step);
        }

        {
            const step_key = b.fmt("test_{s}", .{dayString});
            const step_desc = b.fmt("Run tests in {s}", .{zigFile});
            const step = b.step(step_key, step_desc);
            step.dependOn(&run_test.step);
        }

        const run_cmd = b.addRunArtifact(exe);
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_desc = b.fmt("Run {s}", .{dayString});
        const run_step = b.step(dayString, run_desc);
        run_step.dependOn(&run_cmd.step);
        run_all.dependOn(&run_cmd.step);
    }
}
