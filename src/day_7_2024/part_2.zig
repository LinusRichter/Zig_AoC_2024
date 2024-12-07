const std = @import("std");
const util = @import("../utils/utils.zig");

pub fn do() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    const lines = try util.readLinesFromFile("./src/input/day_07_2024.txt", allocator);
    defer lines.deinit();

    var sum: u64 = 0;
    var l: u32 = 0;

    for (lines.items) |line| { 
        std.debug.print("{}\n", .{l});
        l += 1;

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
                try push_if_not_exists(&new_pos_results, value * eq_parts.items[eq_part_index]);
                try push_if_not_exists(&new_pos_results, value + eq_parts.items[eq_part_index]);
                try push_if_not_exists(&new_pos_results, try combine(value, eq_parts.items[eq_part_index], allocator));
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

fn push_if_not_exists(list: *std.ArrayList(u64), item: u64) !void {
    for (list.items) |value| { 
        if(value == item) { 
            return;            
        }
    }
    try list.append(item);
}

fn combine(left: u64, right: u64, allocator: std.mem.Allocator) !u64 {
    const combined_string = try std.fmt.allocPrint(allocator, "{}{}", .{left, right});
    const result = try std.fmt.parseInt(u64, combined_string, 10);
    allocator.free(combined_string);
    return result;
}
