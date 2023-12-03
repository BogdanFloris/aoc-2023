const std = @import("std");
const parseInt = std.fmt.parseInt;
const expect = std.testing.expect;
const Part = @import("utils").Part;

const max_red: u32 = 12;
const max_green: u32 = 13;
const max_blue: u32 = 14;

fn isDrawPossible(draw: []const u8) !bool {
    const trimmed_draw = std.mem.trim(u8, draw, " ");
    var cubes = std.mem.splitSequence(u8, trimmed_draw, ", ");
    while (cubes.next()) |cube| {
        var cube_split = std.mem.splitSequence(u8, cube, " ");
        const cube_number = try parseInt(u32, cube_split.next() orelse unreachable, 10);
        const cube_color = cube_split.next() orelse unreachable;
        if (std.mem.eql(u8, cube_color, "red") and cube_number > max_red) {
            return false;
        }
        if (std.mem.eql(u8, cube_color, "green") and cube_number > max_green) {
            return false;
        }
        if (std.mem.eql(u8, cube_color, "blue") and cube_number > max_blue) {
            return false;
        }
    }
    return true;
}

fn isGamePossible(game: []const u8) !bool {
    const trimmed_game = std.mem.trim(u8, game, " ");
    var draws = std.mem.splitSequence(u8, trimmed_game, ";");
    while (draws.next()) |draw| {
        if (!try isDrawPossible(draw)) {
            return false;
        }
    }
    return true;
}

fn getMaxColorPowerSet(game: []const u8) !u64 {
    const trimmed_game = std.mem.trim(u8, game, " ");
    var cubes = std.mem.splitAny(u8, trimmed_game, ";,");
    var max_r: u64 = 0;
    var max_g: u64 = 0;
    var max_b: u64 = 0;
    while (cubes.next()) |cube| {
        const trimmed_cube = std.mem.trim(u8, cube, " ");
        var cube_split = std.mem.splitSequence(u8, trimmed_cube, " ");
        const cube_number = try parseInt(u32, cube_split.next() orelse unreachable, 10);
        const cube_color = cube_split.next() orelse unreachable;
        if (std.mem.eql(u8, cube_color, "red") and cube_number > max_r) {
            max_r = cube_number;
        }
        if (std.mem.eql(u8, cube_color, "green") and cube_number > max_g) {
            max_g = cube_number;
        }
        if (std.mem.eql(u8, cube_color, "blue") and cube_number > max_b) {
            max_b = cube_number;
        }
    }
    return max_r * max_g * max_b;
}

fn process(input: []const u8, part: Part) !u64 {
    const trimmed = std.mem.trim(u8, input, "\n");
    var lines = std.mem.splitSequence(u8, trimmed, "\n");
    var result: u64 = 0;
    while (lines.next()) |line| {
        var split = std.mem.splitSequence(u8, line, ":");
        const game_id = split.next() orelse unreachable;
        // Get the game ID
        var game_id_split = std.mem.splitSequence(u8, game_id, " ");
        _ = game_id_split.next() orelse unreachable;
        const game_id_num = try parseInt(u64, game_id_split.next() orelse unreachable, 10);

        const game = split.next() orelse unreachable;
        if (part == Part.one and try isGamePossible(game)) {
            result += game_id_num;
        }
        if (part == Part.two) {
            const power_set = try getMaxColorPowerSet(game);
            result += power_set;
        }
    }
    return result;
}

pub fn main() !void {
    const input = @embedFile("input.txt");
    std.debug.print("==== DAY 2 ====\n", .{});
    const part_1 = try process(input, Part.one);
    std.debug.print("Part 1: {d}\n", .{part_1});
    const part_2 = try process(input, Part.two);
    std.debug.print("Part 2: {d}\n", .{part_2});
}

////// TESTS //////
const test_input =
    \\Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
    \\Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
    \\Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
    \\Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
    \\Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
;

test "part 1" {
    const result = try process(test_input, Part.one);
    try expect(result == 8);
}

test "part 2" {
    const result = try process(test_input, Part.two);
    try expect(result == 2286);
}
