const std = @import("std");
const Part = @import("utils").Part;
const expect = std.testing.expect;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

fn processPart2(input: []const u8) !u64 {
    var lines = std.mem.splitSequence(u8, input, "\n");
    const cols = lines.peek().?.len;
    // discard \n and divide by cols to get rows
    const rows = (input.len - cols) / cols;
    // buffer will contain (rows + 2, cols + 2) to accomodate padding
    const shape = [2]usize{ rows + 2, cols + 2 };
    var grid = try std.ArrayList(u8).initCapacity(allocator, shape[0] * shape[1]);
    defer grid.deinit();
    grid.appendNTimesAssumeCapacity('.', shape[1]);
    while (lines.next()) |line| {
        if (!std.mem.eql(u8, line, "")) {
            grid.appendAssumeCapacity('.');
            grid.appendSliceAssumeCapacity(line);
            grid.appendAssumeCapacity('.');
        }
    }
    grid.appendNTimesAssumeCapacity('.', shape[1]);

    // Map to register the coordinate where we found a number close to *
    var ast_map = std.AutoHashMap(usize, u64).init(allocator);

    // Index starts at row 1, col 1 and should stop at shape[0] - 2, shape[1] - 2
    var i: usize = 1 * shape[0] + 1;
    const stop = (shape[0] - 2) * shape[0] + (shape[1] - 2);
    var result: u64 = 0;
    while (i <= stop) : (i += 1) {
        if (!std.ascii.isDigit(grid.items[i])) {
            continue;
        }
        // find the whole number
        var j = i + 1;
        while (j < stop) : (j += 1) {
            if (!std.ascii.isDigit(grid.items[j])) {
                break;
            }
        }

        var found = false;
        // check up
        if (!found) {
            for (grid.items[i - shape[0] - 1 .. j - shape[0] + 1], i - shape[0] - 1..) |char, k| {
                if (char == '*') {
                    try putInMapOrGetGearRatio(&ast_map, k, grid.items[i..j], &result);
                    found = true;
                    break;
                }
            }
        }
        // check left
        if (!found) {
            const char = grid.items[i - 1];
            if (char == '*') {
                try putInMapOrGetGearRatio(&ast_map, i - 1, grid.items[i..j], &result);
                found = true;
            }
        }
        // check right
        if (!found) {
            const char = grid.items[j];
            if (char == '*') {
                try putInMapOrGetGearRatio(&ast_map, j, grid.items[i..j], &result);
                found = true;
            }
        }
        // check down
        if (!found) {
            for (grid.items[i + shape[0] - 1 .. j + shape[0] + 1], i + shape[0] - 1..) |char, k| {
                if (char == '*') {
                    try putInMapOrGetGearRatio(&ast_map, k, grid.items[i..j], &result);
                    found = true;
                    break;
                }
            }
        }
        i = j;
    }
    return result;
}

fn putInMapOrGetGearRatio(ast_map: *std.AutoHashMap(usize, u64), key: usize, num: []const u8, result: *u64) !void {
    const n = try std.fmt.parseInt(u64, num, 10);
    const at_key = ast_map.get(key);
    if (at_key != null) {
        const gear_ratio = at_key.? * n;
        result.* += gear_ratio;
    } else {
        try ast_map.put(key, n);
    }
}

fn processPart1(input: []const u8) !u64 {
    var lines = std.mem.splitSequence(u8, input, "\n");
    const cols = lines.peek().?.len;
    // discard \n and divide by cols to get rows
    const rows = (input.len - cols) / cols;
    // buffer will contain (rows + 2, cols + 2) to accomodate padding
    const shape = [2]usize{ rows + 2, cols + 2 };
    var grid = try std.ArrayList(u8).initCapacity(allocator, shape[0] * shape[1]);
    defer grid.deinit();
    grid.appendNTimesAssumeCapacity('.', shape[1]);
    while (lines.next()) |line| {
        if (!std.mem.eql(u8, line, "")) {
            grid.appendAssumeCapacity('.');
            grid.appendSliceAssumeCapacity(line);
            grid.appendAssumeCapacity('.');
        }
    }
    grid.appendNTimesAssumeCapacity('.', shape[1]);

    // Index starts at row 1, col 1 and should stop at shape[0] - 2, shape[1] - 2
    var i: usize = 1 * shape[0] + 1;
    const stop = (shape[0] - 2) * shape[0] + (shape[1] - 2);
    var result: u64 = 0;
    while (i <= stop) : (i += 1) {
        if (!std.ascii.isDigit(grid.items[i])) {
            continue;
        }
        // find the whole number
        var j = i + 1;
        while (j < stop) : (j += 1) {
            if (!std.ascii.isDigit(grid.items[j])) {
                break;
            }
        }

        var found = false;
        // check up
        if (!found) {
            for (grid.items[i - shape[0] - 1 .. j - shape[0] + 1]) |char| {
                if (char == '.' or std.ascii.isAlphanumeric(char)) {
                    continue;
                }
                found = true;
                break;
            }
        }
        // check left
        if (!found) {
            const char = grid.items[i - 1];
            if (char != '.' and !std.ascii.isAlphanumeric(char)) {
                found = true;
            }
        }
        // check right
        if (!found) {
            const char = grid.items[j];
            if (char != '.' and !std.ascii.isAlphanumeric(char)) {
                found = true;
            }
        }
        // check down
        if (!found) {
            for (grid.items[i + shape[0] - 1 .. j + shape[0] + 1]) |char| {
                if (char == '.' or std.ascii.isAlphanumeric(char)) {
                    continue;
                }
                found = true;
                break;
            }
        }
        if (found) {
            const num = try std.fmt.parseInt(u64, grid.items[i..j], 10);
            result += num;
        }
        i = j;
    }
    return result;
}

pub fn main() !void {
    const input = @embedFile("input.txt");
    std.debug.print("==== DAY 3 ====\n", .{});
    const part_1 = try processPart1(input);
    std.debug.print("Part 1: {d}\n", .{part_1});
    const part_2 = try processPart2(input);
    std.debug.print("Part 2: {d}\n", .{part_2});
}

const test_input =
    \\467..114..
    \\...*......
    \\..35..633.
    \\......#...
    \\617*......
    \\.....+.58.
    \\..592.....
    \\......755.
    \\...$.*....
    \\.664.598..
    \\
;

test "part 1" {
    const result = try processPart1(test_input);
    try expect(result == 4361);
}

test "part 2" {
    const result = try processPart2(test_input);
    try expect(result == 467835);
}
