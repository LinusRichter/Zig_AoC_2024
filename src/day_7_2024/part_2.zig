const std = @import("std");
const util = @import("../utils/utils.zig");

pub fn do() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    const lines = try util.readLinesFromFile("./src/input/day_07_2024.txt", allocator);
    defer lines.deinit();

    var sum: u64 = 0;

    for (lines.items) |line| { 
        const parts = try util.split(line, ": ", allocator);
        
        const test_result = try std.fmt.parseInt(u64,  parts.items[0], 10);
        const eq_parts_strings = try util.split(parts.items[1], " ", allocator);
        var eq_parts = std.ArrayList(u64).init(allocator);
        for (eq_parts_strings.items) |eq_string| { try eq_parts.append(try std.fmt.parseInt(u64, eq_string, 10)); } 

        var pos_results = std.ArrayList(u64).init(allocator);
        try pos_results.append(eq_parts.items[0]);

        for (1..eq_parts.items.len) |eq_part_index| {
            var new_pos_results = std.ArrayList(u64).init(allocator);
            for (pos_results.items) |value| {
                try new_pos_results.append(value * eq_parts.items[eq_part_index]);
                try new_pos_results.append(value + eq_parts.items[eq_part_index]);
                try new_pos_results.append(concat(value, eq_parts.items[eq_part_index]));
            }
            pos_results = new_pos_results;
        }

        for (pos_results.items) |value| {
            if(value == test_result){
                sum += test_result;
                break;
            }
        }
    }

    std.debug.print("Sum: {}", .{sum});
}

//copied from zig-discord message from https://github.com/aw1875
fn concat(a: u64, b: u64) u64 {
    const digits = if (b == 0) 1 else @floor(@log10(@as(f64, @floatFromInt(b)))) + 1;
    return a * std.math.pow(usize, 10, @intFromFloat(digits)) + b;
}