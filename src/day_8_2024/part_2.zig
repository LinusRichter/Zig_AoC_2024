const std = @import("std");
const util = @import("../utils/utils.zig");

const Pos = struct {
    x: isize,
    y: isize,

    pub fn hash(self: Pos) isize {
        return self.x * 31 + self.y * 10_000_000;
    }
};

const Pair = struct {
    x_1: usize,
    y_1: usize,
    x_2: usize,
    y_2: usize,

    pub fn normalize(self: Pair) Pair {
        if (self.x_1 < self.x_2 or (self.x_1 == self.x_2 and self.y_1 <= self.y_2)) {
            return self;
        } else {
            return Pair{
                .x_1 = self.x_2,
                .y_1 = self.y_2,
                .x_2 = self.x_1,
                .y_2 = self.y_1,
            };
        }
    }

    pub fn eq(a: Pair, b: Pair) bool {
        return a.x_1 == b.x_1 and a.y_1 == b.y_1 and a.x_2 == b.x_2 and a.y_2 == b.y_2;
    }

    pub fn hash(self: Pair) usize {
        return self.x_1 * 31 + self.y_1 * 1_000 + self.x_2 * 1_000_000 + self.y_2 * 10_000_000;
    }

    pub fn vector(self: Pair) Pos {
        const i_x_2: isize = @intCast(self.x_2);
        const i_x_1: isize = @intCast(self.x_1);

        const i_y_2: isize = @intCast(self.y_2);
        const i_y_1: isize = @intCast(self.y_1);

        return Pos{
            .x = i_x_2 - i_x_1,
            .y = i_y_2 - i_y_1,
        };
    }
};

pub fn do() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    var lines = try util.readLinesFromFile("./src/input/day_08_2024.txt", allocator);
    const field = try lines.toOwnedSlice();

    var pairs = std.AutoHashMap(usize, Pair).init(allocator);
    var unique_positions = std.AutoHashMap(isize, Pos).init(allocator);
    
    for (0..field.len) |y| {
        for (0..field[y].len) |x| {
            //------inner--------------------
            if(!(field[y][x] == '.')){
                for (0..field.len) |i_y| {
                    for (0..field[i_y].len) |i_x| {
                        if(!(field[i_y][i_x] == '.' or y == i_y and x == i_x)){
                            if(field[y][x] == field[i_y][i_x]){
                                var new_pair = Pair{ 
                                    .x_1 = x, 
                                    .y_1 = y, 
                                    .x_2 = i_x, 
                                    .y_2 = i_y 
                                };
                                new_pair = new_pair.normalize();
                                try pairs.put(new_pair.hash(), new_pair);
                            }
                        }
                    } 
                }
            }
            //------inner--------------------
        } 
    }

    var iterator = pairs.iterator();

    while (iterator.next()) |entry| {
        const pair: Pair = entry.value_ptr.*;
        const delta: Pos = pair.vector();

        const x_1: isize = @intCast(pair.x_1);
        const y_1: isize = @intCast(pair.y_1);

        const x_2: isize = @intCast(pair.x_2);
        const y_2: isize = @intCast(pair.y_2);

        var first_extension: Pos = .{
            .x = x_1 ,
            .y = y_1 ,
        };

        var second_extension: Pos = .{
            .x = x_2,
            .y = y_2,
        };

        try unique_positions.put(first_extension.hash(), first_extension);
        try unique_positions.put(second_extension.hash(), second_extension);

        for(0..100) |_| {
            var new_first_extension: Pos = .{
                .x = first_extension.x - delta.x,
                .y = first_extension.y - delta.y
            };
            var new_second_extension: Pos = .{
                .x = second_extension.x + delta.x,
                .y = second_extension.y + delta.y
            };

            try unique_positions.put(new_first_extension.hash(), new_first_extension);
            try unique_positions.put(new_second_extension.hash(), new_second_extension);

            first_extension = new_first_extension;
            second_extension = new_second_extension;
        }

    }

    var sum: usize = 0;
    var unique_pos_it = unique_positions.iterator();

    while (unique_pos_it.next())|entry| {
        const pos: Pos = entry.value_ptr.*;
        if((pos.y >= 0 and pos.y < field.len) and (pos.x >= 0 and pos.x < field[0].len)){
            sum += 1;
        }
    }

    std.debug.print("Sum: {}", .{sum});
}