const std = @import("std");
const util = @import("../utils/utils.zig");

pub fn do() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    const lines = try util.readLinesFromFile("./src/input/day_02_2024.txt", allocator);
    defer {
        for (lines.items) |item| allocator.free(item);
        lines.deinit();
    }

    var count: u32 = 0;

    for (lines.items) |value| {
        var number_row = std.ArrayList(u32).init(allocator);
        const char_row = try util.split(value, " ", allocator);
        
        for(char_row.items) |number_string| {try number_row.append(try std.fmt.parseInt(u32, number_string, 10));}

        const inc = number_row.items[0] < number_row.items[1];
        var valid = true;

        for (0..number_row.items.len - 1) |index| {
            const left: i32 = @intCast(number_row.items[index]);
            const right: i32 = @intCast(number_row.items[index + 1]);

            const dif: u32 = @abs(left - right);

            if(inc){
                if(left >= right or dif < 1 or dif > 3) valid = false;
            }else{
                if(left <= right or dif < 1 or dif > 3) valid = false;
            }
        }

        if(valid) count += 1;
    }
    
    std.debug.print("Count: {}\n", .{count});
}
