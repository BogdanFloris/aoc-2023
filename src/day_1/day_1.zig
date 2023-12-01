const std = @import("std");
const parseInt = std.fmt.parseInt;
const Part = @import("utils").Part;
const expect = std.testing.expect;

fn getCalibrationWithLetters(line: []const u8) !u64 {
    _ = line;
    return 0;
}

fn getCalibration(line: []const u8) !u64 {
    var first: ?u8 = null;
    var last: u8 = undefined;
    for (line) |char| {
        if (char >= '0' and char <= '9') {
            if (first == null) {
                first = char;
            }
            last = char;
        }
    }
    const calibration = [_]u8{ first.?, last };
    return try parseInt(u64, &calibration, 10);
}

fn process(input: []const u8, part: Part) u64 {
    const trimmed = std.mem.trim(u8, input, "\n");
    var lines = std.mem.splitSequence(u8, trimmed, "\n");
    var result: u64 = 0;
    while (lines.next()) |line| {
        if (part == Part.one) {
            result += getCalibration(line) catch 0;
        } else {
            result += getCalibrationWithLetters(line) catch 0;
        }
    }
    return result;
}

pub fn solve() !void {
    const input = @embedFile("input.txt");
    std.debug.print("==== DAY 1 ====\n", .{});
    const part_1 = process(input, Part.one);
    std.debug.print("Part 1: {d}\n", .{part_1});
    const part_2 = process(input, Part.two);
    std.debug.print("Part 2: {d}\n", .{part_2});
}

////// TESTS //////
const test_input_1 = "1abc2\npqr3stu8vwx\na1b2c3d4e5f\ntreb7uchet\n";

test "part 1" {
    const result = process(test_input_1, Part.one);
    try expect(result == 142);
}
