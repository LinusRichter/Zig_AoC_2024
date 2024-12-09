const std = @import("std");
const util = @import("../utils/utils.zig");

pub fn do() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    var lines = try util.readLinesFromFile("./src/input/day_09_2024.txt", allocator);

    const line = (try lines.toOwnedSlice())[0];
    var mut_line = try allocator.alloc(u32, line.len * 10);

    var is_disc_block = true;
    var file_id: u32 = 0;
    var mut_line_index: usize = 0;

    for (line) |char| {
        const cur_value: usize = @intCast(char - 48);
        
        if (is_disc_block) {
            for (0..cur_value) |_| {
                mut_line[mut_line_index] = file_id + 48;
                mut_line_index += 1;
            }
            is_disc_block = false;
            file_id = file_id + 1;
        } else {
            for (0..cur_value) |_| {
                mut_line[mut_line_index] = '.';
                mut_line_index += 1;
            }
            is_disc_block = true;
        }
    }

    mut_line = mut_line[0..mut_line_index];

    var free_space_index: usize = 0;
    var insert_char_index: usize = mut_line_index - 1;

    while (true) {
        while (mut_line[free_space_index] != '.' and free_space_index < mut_line.len) {
            free_space_index += 1;
        }
        while (mut_line[insert_char_index] == '.' and insert_char_index >= 0) {
            insert_char_index -=1;
        }
        if(free_space_index >= insert_char_index) break;
        mut_line[free_space_index] = mut_line[insert_char_index];
        mut_line[insert_char_index] = '.';
    }

    mut_line = mut_line[0..free_space_index];
    var sum: usize = 0;
    
    for (0..mut_line.len) |index| {
        const num_val: usize = @intCast(mut_line[index] - 48);
        sum += index * num_val;
    }

    std.debug.print("Sum: {}", .{sum});
}



