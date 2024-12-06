const std = @import("std");
const util = @import("../utils/utils.zig");

const Pos = struct {
    y: i32,
    x: i32
};

pub fn do() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    var lines = try util.readLinesFromFile("./src/input/day_06_2024.txt", allocator);

    const field = try lines.toOwnedSlice();

    var pos: Pos = undefined;
    var dir: Pos = .{.x = 0, .y = -1}; 

    var visited: std.ArrayList(Pos) = std.ArrayList(Pos).init(allocator);

    for (0..field.len) |y| {
        for (0..field[y].len) |x| {
            if(field[y][x] == '^'){
                pos = .{.y = @intCast(y), .x = @intCast(x)};
            }
        }
    }

    while(true){
        const new_pos: Pos = .{ .x = pos.x + dir.x, .y = pos.y + dir.y };
        if(new_pos.x >= field[0].len or new_pos.x < 0 or new_pos.y >= field.len or new_pos.y < 0) {
            break;
        }else if(field[@intCast(new_pos.y)][@intCast(new_pos.x)] == '#') {
            if(dir.y == -1){ 
                dir = .{ .x = 1, .y = 0 };
            }else if(dir.x == 1){
                dir = .{ .x = 0, .y = 1};
            }else if(dir.y == 1){
                dir = .{ .x = -1, .y = 0};
            }else if(dir.x == -1){
                dir = .{ .x = 0, .y = -1};
            }
        }else {
            pos = new_pos;
            try add(&visited, pos);
        }
    }

    std.debug.print("Count: {}", .{visited.items.len + 1});
}

fn add(visited: *std.ArrayList(Pos), pos: Pos) !void {
    for (visited.items) |v_pos| { if(v_pos.x == pos.x and v_pos.y == pos.y) return;}
    try visited.append(pos);
}
