const std = @import("std");
const utils = @import("utils");
const expect = std.testing.expect;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const Interval = struct {
    const Self = @This();

    /// Interval start inclusive
    min: i64,
    /// Interval end exclusive
    max: i64,

    pub fn init(min: i64, max: i64) Self {
        return Interval{
            .min = min,
            .max = max,
        };
    }
    // [2, 5) - [5, 7) -> null
    // [2, 5) - [4, 9] -> [4, 5)
    pub fn intersect(self: Self, other: Interval) ?Interval {
        const min = @max(self.min, other.min);
        const max = @min(self.max, other.max);
        if (max <= min) {
            return null;
        }
        return Self.init(min, max);
    }
};

const IntersectionResult = [3]?Interval;

fn intersect_intervals(interval_a: Interval, interval_b: Interval) IntersectionResult {
    if (interval_b.min > interval_a.max or interval_a.min > interval_b.max) {
        return IntersectionResult{ null, null, null };
    }
    const min = @max(interval_a.min, interval_b.min);
    const max = @min(interval_a.max, interval_b.max);
    const inside: ?Interval = Interval.init(min, max);
    var before: ?Interval = null;
    if (interval_a.min < min) {
        before = Interval.init(interval_a.min, min);
    }
    var after: ?Interval = null;
    if (interval_a.max > max) {
        after = Interval.init(max, interval_a.max);
    }
    return IntersectionResult{ before, inside, after };
}

fn processTwo(input: []const u8) !i64 {
    const trimmed = std.mem.trim(u8, input, "\n");
    var split = std.mem.splitSequence(u8, trimmed, "\n\n");
    var mapped_intervals = std.ArrayList(Interval).init(allocator);
    defer mapped_intervals.deinit();
    var split_seeds = std.mem.splitSequence(u8, split.next().?, ": ");
    _ = split_seeds.next();
    var seed_nums = std.mem.splitSequence(u8, split_seeds.next().?, " ");
    while (seed_nums.next()) |seed_num| {
        const seed = try std.fmt.parseInt(i64, seed_num, 10);
        const count = try std.fmt.parseInt(i64, seed_nums.next().?, 10);
        const interval = Interval.init(seed, seed + count);
        try mapped_intervals.append(interval);
    }
    var source_intervals = try std.ArrayList(Interval).initCapacity(allocator, mapped_intervals.items.len);
    defer source_intervals.deinit();
    var scratch_intervals = try std.ArrayList(Interval).initCapacity(allocator, mapped_intervals.items.len);
    defer scratch_intervals.deinit();
    while (split.next()) |mapping| {
        var mapping_split = std.mem.splitSequence(u8, mapping, "\n");
        if (std.mem.endsWith(u8, mapping_split.next().?, "map:")) {
            while (source_intervals.popOrNull()) |interval| {
                try mapped_intervals.append(interval);
            }
            std.mem.swap(std.ArrayList(Interval), &source_intervals, &mapped_intervals);
        }
        while (mapping_split.next()) |range| {
            var range_split = std.mem.splitSequence(u8, range, " ");
            const dst = try std.fmt.parseInt(i64, range_split.next().?, 10);
            const src = try std.fmt.parseInt(i64, range_split.next().?, 10);
            const delta = try std.fmt.parseInt(i64, range_split.next().?, 10);
            const dst_diff = dst - src;
            const check_interval = Interval.init(src, src + delta);
            while (source_intervals.popOrNull()) |interval| {
                const intersection = intersect_intervals(interval, check_interval);
                const before = intersection[0];
                const inside = intersection[1];
                const after = intersection[2];
                if (inside != null) {
                    const to_push = Interval.init(inside.?.min + dst_diff, inside.?.max + dst_diff);
                    try mapped_intervals.append(to_push);
                    if (before != null) {
                        try scratch_intervals.append(before.?);
                    }
                    if (after != null) {
                        try scratch_intervals.append(after.?);
                    }
                } else {
                    try scratch_intervals.append(interval);
                }
            }
            std.mem.swap(std.ArrayList(Interval), &scratch_intervals, &source_intervals);
        }
    }
    var min: i64 = std.math.maxInt(i64);
    for (mapped_intervals.items) |interval| {
        if (interval.min < min) {
            min = interval.min;
        }
    }
    return min;
}

fn processOne(input: []const u8) !i64 {
    const trimmed = std.mem.trim(u8, input, "\n");
    var split = std.mem.splitSequence(u8, trimmed, "\n\n");
    // Get seeds arraylist
    var seeds = std.ArrayList(i64).init(allocator);
    defer seeds.deinit();
    var split_seeds = std.mem.splitSequence(u8, split.next().?, ": ");
    _ = split_seeds.next();
    var seed_nums = std.mem.splitSequence(u8, split_seeds.next().?, " ");
    while (seed_nums.next()) |seed_num| {
        const seed = try std.fmt.parseInt(i64, seed_num, 10);
        try seeds.append(seed);
    }

    // Go through the mappings and change the array
    while (split.next()) |mapping| {
        var mapping_split = std.mem.splitSequence(u8, mapping, "\n");
        // Discard the text
        _ = mapping_split.next();
        var modified = try allocator.alloc(bool, seeds.items.len);
        while (mapping_split.next()) |range| {
            var range_split = std.mem.splitSequence(u8, range, " ");
            const dst = try std.fmt.parseInt(i64, range_split.next().?, 10);
            const src = try std.fmt.parseInt(i64, range_split.next().?, 10);
            const delta = try std.fmt.parseInt(i64, range_split.next().?, 10);
            for (0..seeds.items.len) |i| {
                const seed = &seeds.items[i];
                if (!modified[i] and seed.* >= src and seed.* < src + delta) {
                    seed.* += (dst - src);
                    modified[i] = true;
                }
            }
        }
    }
    return std.mem.min(i64, seeds.items);
}

pub fn main() !void {
    const input = @embedFile("input.txt");
    std.debug.print("==== DAY 3 ====\n", .{});
    const part_1 = try processOne(input);
    std.debug.print("Part 1: {d}\n", .{part_1});
    const part_2 = try processTwo(input);
    std.debug.print("Part 2: {d}\n", .{part_2});
}

const test_input =
    \\seeds: 79 14 55 13
    \\
    \\seed-to-soil map:
    \\50 98 2
    \\52 50 48
    \\
    \\soil-to-fertilizer map:
    \\0 15 37
    \\37 52 2
    \\39 0 15
    \\
    \\fertilizer-to-water map:
    \\49 53 8
    \\0 11 42
    \\42 0 7
    \\57 7 4
    \\
    \\water-to-light map:
    \\88 18 7
    \\18 25 70
    \\
    \\light-to-temperature map:
    \\45 77 23
    \\81 45 19
    \\68 64 13
    \\
    \\temperature-to-humidity map:
    \\0 69 1
    \\1 0 69
    \\
    \\humidity-to-location map:
    \\60 56 37
    \\56 93 4
    \\
;

test "part 1" {
    const result = try processOne(test_input);
    try expect(result == 35);
}

test "part 2" {
    const result = try processTwo(test_input);
    try expect(result == 46);
}
