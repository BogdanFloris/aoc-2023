const std = @import("std");
const utils = @import("utils");
const expect = std.testing.expect;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

fn getMatches(numbers: []const u8) !u64 {
    const trimmed = std.mem.trim(u8, numbers, " ");
    var split = std.mem.splitBackwardsSequence(u8, trimmed, "|");
    // lookup set
    var set = std.AutoHashMap(u32, void).init(allocator);
    defer set.deinit();
    var winning_numbers = std.mem.splitSequence(u8, std.mem.trim(u8, split.next().?, " "), " ");
    while (winning_numbers.next()) |num| {
        if (!std.mem.eql(u8, num, "")) {
            const n = try std.fmt.parseInt(u32, num, 10);
            try set.put(n, {});
        }
    }
    var matches: u64 = 0;
    var nums = std.mem.splitSequence(u8, std.mem.trim(u8, split.next().?, " "), " ");
    while (nums.next()) |num| {
        if (!std.mem.eql(u8, num, "")) {
            const n = try std.fmt.parseInt(u32, num, 10);
            if (set.contains(n)) {
                matches += 1;
            }
        }
    }
    return matches;
}

fn process(input: []const u8, part: utils.Part) !u64 {
    const trimmed = std.mem.trim(u8, input, "\n");
    var lines = std.mem.splitSequence(u8, trimmed, "\n");
    var game_counter = std.AutoHashMap(usize, u64).init(allocator);
    defer game_counter.deinit();
    var result: u64 = 0;
    var game: usize = 1;
    while (lines.next()) |line| {
        // discard game number
        var split = std.mem.splitSequence(u8, line, ":");
        _ = split.next();
        const numbers = split.next().?;
        const matches = try getMatches(numbers);
        if (part == utils.Part.one and matches != 0) {
            result += std.math.pow(u64, 2, matches - 1);
        }
        if (part == utils.Part.two) {
            _ = try game_counter.getOrPutValue(game, 1);
            for (game + 1..game + 1 + matches) |g| {
                // HACK: we lookup the game again here because if creating g_count allocates new memory,
                // the `game_count` pointer is pointing to some other memory, and so we get a seg fault.
                // The map should invalidate the pointer.
                // Another solution would be to ensure the capacity of the map, but we cannot know how many games
                // there are in the input, so it would be wasteful to do that.
                const game_count = try game_counter.getOrPutValue(game, 1);
                const g_count = try game_counter.getOrPutValue(g, 1);
                g_count.value_ptr.* += game_count.value_ptr.*;
            }
        }
        game += 1;
    }
    if (part == utils.Part.two) {
        var game_counter_iter = game_counter.iterator();
        while (game_counter_iter.next()) |value| {
            if (value.key_ptr.* < game) {
                result += value.value_ptr.*;
            }
        }
    }
    return result;
}

pub fn main() !void {
    const input = @embedFile("input.txt");
    std.debug.print("==== DAY 4 ====\n", .{});
    const part_1 = try process(input, utils.Part.one);
    std.debug.print("Part 1: {d}\n", .{part_1});
    const part_2 = try process(input, utils.Part.two);
    std.debug.print("Part 2: {d}\n", .{part_2});
}

const test_input =
    \\Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    \\Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
    \\Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
    \\Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
    \\Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
    \\Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    \\
;

test "part 1" {
    const result = try process(test_input, utils.Part.one);
    try expect(result == 13);
}

test "part 2" {
    const result = try process(test_input, utils.Part.two);
    try expect(result == 30);
}
