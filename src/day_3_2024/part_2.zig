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

    var line = lines.items[0];
    
    var first_dont_op = util.findFirstIndexOfString("don't()", line);
    var first_do_op = util.findFirstIndexOfString("do()", line);
    var check_from: usize = 0;

    while (first_dont_op) |dont_index| {
        check_from = dont_index;
        var line_buffer: std.ArrayList(u8) = std.ArrayList(u8).init(allocator);
        const up_to_dont = line[0..dont_index];
        if(first_do_op) |do_index|{

            if(do_index < dont_index) {
                const to = line[0..do_index];
                const from = line[(do_index + 4)..];
                try line_buffer.appendSlice(to);
                try line_buffer.appendSlice(from);
                line = try line_buffer.toOwnedSlice();
                first_dont_op = util.findFirstIndexOfString("don't()", line);
                first_do_op = util.findFirstIndexOfString("do()", line);
                continue;
            }
            const from_do = line[(do_index + 4)..];
            try line_buffer.appendSlice(up_to_dont);
            try line_buffer.appendSlice(from_do);
            line = try line_buffer.toOwnedSlice();
            first_dont_op = util.findFirstIndexOfStringAfterIndex("don't()", line, check_from);
            first_do_op = util.findFirstIndexOfStringAfterIndex("do()", line, check_from);
        }
    }

    var sum: u32 = 0;

    const mul_parts = try util.split(line, "mul(", allocator);
    for (mul_parts.items) |mul_slice| {
        const res_op = try expand(mul_slice, allocator);
        if(res_op)|val|{
            sum += val.items[0] * val.items[1];
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
