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
    var dirs: std.ArrayList([]const u8) = std.ArrayList([]const u8).init(allocator);

    for (0..y_len) |y| {
        for (0..x_len) |x| {
            if(lines.items[y][x] == 'X') {
                const line = lines.items[y];
                if(x <= x_len - 4) { //rechts
                    try dirs.append(line[x..(x + 4)]);
                    if(y <= y_len - 4){ //rechts-unten
                        var new_line: []u8 = try allocator.alloc(u8, 4);
                        for(0..4)|index|{new_line[index] = lines.items[y + index][x + index]; }
                        try dirs.append(new_line); 
                    }
                    if(y >= 3){//rechts-oben
                        var new_line: []u8 = try allocator.alloc(u8, 4);
                        for(0..4)|index|{new_line[index] = lines.items[y - index][x + index];}
                        try dirs.append(new_line);
                    }
                }
                if(x >= 3){ //links
                    const slice = line[(x - 3)..(x + 1)];
                    var reversed: []u8 = try allocator.alloc(u8, 4); 
                    for (0..slice.len) |i| {
                        reversed[i] = slice[slice.len - 1 - i];
                    }
                    try dirs.append(reversed);
                    
                    if(y <= y_len - 4){ //links-unten
                        var new_line: []u8 = try allocator.alloc(u8, 4);
                        for(0..4)|index|{new_line[index] = lines.items[y + index][x - index]; }
                        try dirs.append(new_line); 
                    }
                    if(y >= 3){//links-oben
                        var new_line: []u8 = try allocator.alloc(u8, 4);
                        for(0..4)|index|{new_line[index] = lines.items[y - index][x - index];}
                        try dirs.append(new_line); 
                    }
                }
                if(y >= 3){ //oben
                    var new_line: []u8 = try allocator.alloc(u8, 4);
                    for(0..4)|index|{new_line[index] = lines.items[y - index][x]; }
                    try dirs.append(new_line);
                }
                if(y <= y_len - 4){ //unten
                    var new_line: []u8 = try allocator.alloc(u8, 4);
                    for(0..4)|index|{new_line[index] = lines.items[y + index][x]; }
                    try dirs.append(new_line); 
                }
            }
        }
    }

    for (dirs.items) |value| {
        if(std.mem.eql(u8, value, "XMAS")) sum += 1;
    }
    std.debug.print("Sum: {}", .{sum});
}