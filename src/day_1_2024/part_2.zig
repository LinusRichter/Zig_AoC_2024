const std = @import("std");
const util = @import("../utils/utils.zig");

pub fn do() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    const lines = try util.readLinesFromFile("./src/input/day_01_2024.txt", allocator);
    defer lines.deinit();

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

    var sum: u32 = 0;

    for (left_side.items) |l_item| {
        var sim_count: u32 = 0;
        for (right_side.items) |r_item| {
            if (l_item == r_item) sim_count += 1;
        }
        sum += l_item * sim_count;
    }

    std.debug.print("Sum: {}", .{sum});
}
