const std = @import("std");
const parseInt = std.fmt.parseInt;
const Part = @import("utils").Part;
const expect = std.testing.expect;

const RepMap = struct {
    letters: []const u8,
    digit: u8,
    len: usize,
};
const one = RepMap{ .letters = "one", .digit = '1', .len = 3 };
const two = RepMap{ .letters = "two", .digit = '2', .len = 3 };
const three = RepMap{ .letters = "three", .digit = '3', .len = 5 };
const four = RepMap{ .letters = "four", .digit = '4', .len = 4 };
const five = RepMap{ .letters = "five", .digit = '5', .len = 4 };
const six = RepMap{ .letters = "six", .digit = '6', .len = 3 };
const seven = RepMap{ .letters = "seven", .digit = '7', .len = 5 };
const eight = RepMap{ .letters = "eight", .digit = '8', .len = 5 };
const nine = RepMap{ .letters = "nine", .digit = '9', .len = 4 };
const numbers = [_]RepMap{ one, two, three, four, five, six, seven, eight, nine };

fn getCalibrationWithLetters(line: []const u8) !u64 {
    var first: ?u8 = null;
    var last: u8 = undefined;
    for (line, 0..) |char, i| {
        for (numbers) |number| {
            if (i + number.len <= line.len and std.mem.eql(u8, number.letters, line[i .. i + number.len])) {
                if (first == null) {
                    first = number.digit;
                }
                last = number.digit;
            }
        }
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

pub fn main() !void {
    const input = @embedFile("input.txt");
    std.debug.print("==== DAY 1 ====\n", .{});
    const part_1 = process(input, Part.one);
    std.debug.print("Part 1: {d}\n", .{part_1});
    const part_2 = process(input, Part.two);
    std.debug.print("Part 2: {d}\n", .{part_2});
}

////// TESTS //////
const test_input_1 =
    \\1abc2
    \\pqr3stu8vwx
    \\a1b2c3d4e5f
    \\treb7uchet
;
const test_input_2 =
    \\two1nine
    \\eightwothree
    \\abcone2threexyz
    \\xtwone3four
    \\4nineeightseven2
    \\zoneight234
    \\7pqrstsixteen
;

test "part 1" {
    const result = process(test_input_1, Part.one);
    try expect(result == 142);
}

test "part 2" {
    const result = process(test_input_2, Part.two);
    try expect(result == 281);
}
