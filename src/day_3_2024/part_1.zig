const std = @import("std");
const util = @import("../utils/utils.zig");

pub fn do() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    const lines = try util.readLinesFromFile("./src/input/day_03_2024.txt", allocator);
    defer {
        for (lines.items) |item| allocator.free(item);
        lines.deinit();
    }

    var sum: u32 = 0;

    for (lines.items) |line| {
        const mul_parts = try util.split(line, "mul(", allocator);
        for (mul_parts.items) |mul_slice| {
            const res_op = try expand(mul_slice, allocator);
            if(res_op)|val|{
                sum += val.items[0] * val.items[1];
            }
        }
    }
    
    std.debug.print("Sum: {}", .{sum});
}


fn expand(slice: []const u8,  allocator: std.mem.Allocator) !?std.ArrayList(u32) {
    if (util.findFirstIndexOfString(")", slice)) |end_index|{
        const cut_slice = slice[0..end_index];
        const parts = try util.split(cut_slice, ",", allocator);
        if(parts.items.len == 2){
            var left_side: std.ArrayList(u8) = std.ArrayList(u8).init(allocator);
            for (parts.items[0]) |l_item| {
                if(!std.ascii.isDigit(l_item)) return null;
                try left_side.append(l_item);
            }
            var rigth_side: std.ArrayList(u8) = std.ArrayList(u8).init(allocator);
            for (parts.items[1]) |r_item| {
                if(!std.ascii.isDigit(r_item)) return null;
                try rigth_side.append(r_item);
            }
            var result: std.ArrayList(u32) = std.ArrayList(u32).init(allocator);
            try result.append(try std.fmt.parseInt(u32, @as([]const u8, left_side.items), 10));
            try result.append(try std.fmt.parseInt(u32, @as([]const u8, rigth_side.items), 10));
            return result;
        }
    }
    return null;
} 
