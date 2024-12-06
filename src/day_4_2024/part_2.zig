const std = @import("std");
const util = @import("../utils/utils.zig");

pub fn do() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    const lines = try util.readLinesFromFile("./src/input/day_04_2024.txt", allocator);
    defer lines.deinit();

    const y_len: usize = lines.items.len;
    const x_len: usize = lines.items[0].len;

    var sum: u32 = 0;

    for (1..y_len - 1) |y| {
        for (1..x_len - 1) |x| {
            if(lines.items[y][x] == 'A') {
                const adj_ops = util.getAdjacentOptionals(u8, lines.items, x, y, allocator);
                
                const tl = adj_ops[0].?;
                const tr = adj_ops[2].?;

                const bl = adj_ops[5].?;
                const br = adj_ops[7].?;

                if(tl == 'M' and tr == 'M' and bl == 'S' and br == 'S') sum +=1;
                if(tl == 'S' and tr == 'S' and bl == 'M' and br == 'M') sum +=1;
                if(tl == 'M' and bl == 'M' and tr == 'S' and br == 'S') sum +=1;
                if(tl == 'S' and bl == 'S' and tr == 'M' and br == 'M') sum +=1;
            }
        }
    }

    std.debug.print("Sum: {}", .{sum});
}