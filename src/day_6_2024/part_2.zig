const std = @import("std");
const util = @import("../utils/utils.zig");

const Pos = struct {
    y: i32,
    x: i32
};

const Pos_w_dir = struct {
    y: i32,
    x: i32,
    y_dir: i32,
    x_dir: i32
};

pub fn do() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    var lines = try util.readLinesFromFile("./src/input/day_06_2024.txt", allocator);

    var field: [][]u8 = allocator.alloc([]u8, lines.items.len) catch |err| return err;
    for (0..lines.items.len) |index| {
        field[index] = try allocator.alloc(u8, lines.items[index].len);
        std.mem.copyForwards(u8, field[index], lines.items[index]);
    }
    //var field = try lines.toOwnedSlice();

    var pos: Pos = undefined;
    var visited: std.ArrayList(Pos_w_dir) = std.ArrayList(Pos_w_dir).init(allocator);
    var dir: Pos = .{.x = 0, .y = -1};

    var sum: u32 = 0;

    for (0..field.len) |i_y| {
        std.debug.print("at y = {}\n", .{i_y});
        for (0..field[i_y].len) |i_x| {
            for (0..field.len) |y| {
                for (0..field[y].len) |x| {
                    if(field[y][x] == '^'){
                        pos = .{.y = @intCast(y), .x = @intCast(x)};
                    }
                }
            }
            if(field[i_y][i_x] == '.' and !(i_y == pos.y + 1 and i_x == pos.x)){
                field[i_y][i_x] = '#';
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
                        const pos_w_dir: Pos_w_dir = .{ .x = pos.x, .y = pos.y, .y_dir = dir.y, .x_dir = dir.x}; 
                        if(try add(&visited, pos_w_dir)){
                            sum += 1;
                            break;
                        }
                    }
                }

                lines = try util.readLinesFromFile("./src/input/day_06_2024.txt", allocator);
                for (0..lines.items.len) |index| {
                    field[index] = try allocator.alloc(u8, lines.items[index].len);
                    std.mem.copyForwards(u8, field[index], lines.items[index]);
                }

                pos = undefined;
                visited = std.ArrayList(Pos_w_dir).init(allocator);
                dir = .{.x = 0, .y = -1};
            }
        }
    }

    std.debug.print("Sum: {}", .{sum});
}

fn add(visited: *std.ArrayList(Pos_w_dir), pos: Pos_w_dir) !bool {
    for (visited.items) |v_pos| { 
        if(v_pos.x == pos.x and v_pos.y == pos.y and v_pos.x_dir == pos.x_dir and v_pos.y_dir == pos.y_dir) {
            return true;
        }
    }
    try visited.append(pos);
    return false;
}

