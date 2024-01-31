const std = @import("std");
const utils = @import("utils");
const expect = std.testing.expect;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

fn process(input: []const u8, _: utils.Part) !u64 {
    const trimmed = std.mem.trim(u8, input, "\n");
    var lines = std.mem.splitSequence(u8, trimmed, "\n");
    var time = std.mem.tokenizeSequence(u8, lines.next().?, " ");
    std.debug.print("t: {s}\n", .{time.next().?});
    std.debug.print("t: {s}\n", .{time.next().?});
    // _ = time.next();
    const time_trimmed = std.mem.trim(u8, time.next().?, " ");
    std.debug.print("time: {s}\n", .{time_trimmed});
    var dist = std.mem.splitSequence(u8, lines.next().?, " ");
    _ = dist.next();
    const dist_trimmed = std.mem.trim(u8, dist.next().?, " ");
    std.debug.print("dist: {s}\n", .{dist_trimmed});
    const times = std.ArrayList(u64).init(allocator);
    _ = times;
    const distances = std.ArrayList(u64).init(allocator);
    _ = distances;
    return 0;
}

const Roots = [2]u64;

fn quadratic(a: u64, b: u64, c: u64) void {
    const a_f: f64 = @floatFromInt(a);
    const b_f: f64 = @floatFromInt(b);
    const c_f: f64 = @floatFromInt(c);
    const sq_b = std.math.pow(f64, b_f, 2);
    const disc: f64 = std.math.sqrt(sq_b - 4.0 * a_f * c_f);
    const den: f64 = 2.0 * a_f;
    const r1: f64 = (-b_f) / den - disc / den;
    const r2: f64 = (-b_f) / den + disc / den;
    if (r1 > r2) {
        std.mem.swap(f64, &r1, &r2);
    }
    return [2]u64{ std.math.ceil(r1), std.math.floor(r2) };
}

pub fn main() !void {
    const input = @embedFile("input.txt");
    std.debug.print("==== DAY 6 ====\n", .{});
    const part_1 = try process(input, utils.Part.one);
    std.debug.print("Part 1: {d}\n", .{part_1});
}

const test_input =
    \\Time:      7  15   30
    \\Distance:  9  40  200
    \\
;

test "part 1" {
    const result = try process(test_input, utils.Part.one);
    try expect(result == 288);
}
