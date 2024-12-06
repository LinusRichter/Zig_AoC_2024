const std = @import("std");
const util = @import("../utils/utils.zig");

pub fn do() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    const lines = try util.readLinesFromFile("./src/input/day_05_2024.txt", allocator);
    defer lines.deinit();

    const orders = lines.items[0..1176];
    const updates = lines.items[1177..];

    var sum: u32 = 0;

    for (0..updates.len) |u_index| {
        var update_parts = try util.split(updates[u_index], ",", allocator);
        var edit = true;

        while (edit) {
            edit = false;
            for (0..update_parts.items.len - 1)  |i| {
                const i_left = update_parts.items[i];
                const i_right = update_parts.items[i + 1];

                for (orders) |order| {
                    const o_parts = try util.split(order, "|", allocator);
                    if(std.mem.eql(u8, i_left, o_parts.items[1]) and std.mem.eql(u8, i_right, o_parts.items[0])){
                        edit = true;
                        try swapStrings(&update_parts, i_left, i_right);
                    }
                }
            }
        }

        const ref_update_parts = try util.split(updates[u_index], ",", allocator);
        for (0..ref_update_parts.items.len) |ref_i| {
            if(!std.mem.eql(u8, ref_update_parts.items[ref_i], update_parts.items[ref_i])){
                const middle = update_parts.items[update_parts.items.len / 2];
                sum += try std.fmt.parseInt(u32, middle, 10);
                break;
            }
        }
    }

    std.debug.print("Sum: {}", .{sum});
}

fn swapStrings(list: *std.ArrayList([]const u8), str1: []const u8, str2: []const u8) !void {
    const index1 = findIndex(list, str1) orelse return;
    const index2 = findIndex(list, str2) orelse return;

    const temp = list.items[index1];
    list.items[index1] = list.items[index2];
    list.items[index2] = temp;
}

fn findIndex(list: *std.ArrayList([]const u8), target: []const u8) ?usize {
    for (0..list.items.len) |i| { 
        if (std.mem.eql(u8, list.items[i], target)) {
            return i; 
        }
    }
    return null; 
}