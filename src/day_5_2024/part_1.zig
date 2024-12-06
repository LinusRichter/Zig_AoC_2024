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

        var valid = true;

        for (0..orders.len) |o_index| {
            const parts = try util.split(orders[o_index], "|", allocator);
            
            const left = parts.items[0];
            const right = parts.items[1];

            const first_op = util.findFirstIndexOfString(left, updates[u_index]);
            const second_op  = util.findFirstIndexOfString(right, updates[u_index]);

            if(first_op)|first_index|  {
                if(second_op) |second_index|{
                    if(!(first_index < second_index)) valid = false;
                }
            }
        }

        if(valid){
            const parts = try util.split(updates[u_index], ",", allocator);
            const middle = parts.items[parts.items.len / 2];
            sum += try std.fmt.parseInt(u32, middle, 10);
        }

    }

    std.debug.print("Sum: {}", .{sum});
}