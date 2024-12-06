const std = @import("std");
const util = @import("../utils/utils.zig");

pub fn do() !void {

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    const lines = try util.readLinesFromFile("./src/input/day_01_2024.txt", allocator);
    defer {
        for (lines.items) |item| allocator.free(item);
        lines.deinit();
    }

    var left_side = std.ArrayList(u32).init(allocator);
    defer left_side.deinit();

    var right_side = std.ArrayList(u32).init(allocator);
    defer right_side.deinit();

    for (lines.items) |value| {
        const parts = try util.split(value, "   ", allocator);
        defer parts.deinit();

        try left_side.append(try std.fmt.parseInt(u32, parts.items[0], 10));
        try right_side.append(try std.fmt.parseInt(u32, parts.items[1], 10));
    }

    std.mem.sort(u32, left_side.items, {}, std.sort.asc(u32));
    std.mem.sort(u32, right_side.items, {}, std.sort.asc(u32));

    var sum: u32 = 0;

    for (0..left_side.items.len) |index| {
        const left = left_side.items[index];
        const right = right_side.items[index];

        if (left > right) {
            sum += left - right;
        } else {
            sum += right - left;
        }
    }

    std.debug.print("Sum: {}", .{sum});
}
