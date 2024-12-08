const std = @import("std");

pub fn readLinesFromFile(file_path: []const u8, allocator: std.mem.Allocator) !std.ArrayList([]const u8) {
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    var lines: std.ArrayList([]const u8) = std.ArrayList([]const u8).init(allocator);

    var reader = file.reader();

    while (try reader.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)) |line| {
        const trimmed_line = std.mem.trim(u8, line, " \t\r\n");
        try lines.append(trimmed_line);
        //allocator.free(line);
        //try lines.append(line);
    }

    return lines;
}

pub fn findFirstIndexOfString(query_string: []const u8, container_string: []const u8) ?usize {
    if (query_string.len > container_string.len) return null;
    if (query_string.len == container_string.len) {
        if (std.mem.eql(u8, query_string, container_string)) return 0;
        return null;
    }

    for (0..(container_string.len - (query_string.len - 1))) |container_string_index| {
        var found = true;
        for (0..query_string.len) |query_string_index| {
            if (query_string[query_string_index] != container_string[container_string_index + query_string_index]) {
                found = false;
                break;
            }
        }
        if (found) return container_string_index;
    }
    return null;
}


pub fn findFirstIndexOfStringAfterIndex(query_string: []const u8, container_string: []const u8, after: usize) ?usize {
    if (query_string.len > container_string.len) return null;
    if (query_string.len == container_string.len) {
        if (std.mem.eql(u8, query_string, container_string)) return 0;
        return null;
    }

    for (after..(container_string.len - (query_string.len - 1))) |container_string_index| {
        var found = true;
        for (0..query_string.len) |query_string_index| {
            if (query_string[query_string_index] != container_string[container_string_index + query_string_index]) {
                found = false;
                break;
            }
        }
        if (found) return container_string_index;
    }
    return null;
}

pub fn findLastIndexOfString(query_string: []const u8, container_string: []const u8) ?usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const query_buffer: []u8 = allocator.alloc(u8, query_string.len) catch return null;
    defer allocator.free(query_buffer);
    const reversed_query = reverse(query_buffer, query_string);

    const container_buffer: []u8 = allocator.alloc(u8, container_string.len) catch return null;
    defer allocator.free(container_buffer);
    const reversed_container = reverse(container_buffer, container_string);

    if (findFirstIndexOfString(reversed_query, reversed_container)) |reversed_index| {
        return container_string.len - reversed_index - query_string.len;
    } else {
        return null;
    }
}

pub fn reverse(buffer: []u8, s: []const u8) []u8 {
    for (s, 0..) |c, i| {
        buffer[s.len - 1 - i] = c;
    }
    return buffer;
}

pub fn split(string: []const u8, delimiter: []const u8, allocator: std.mem.Allocator) !std.ArrayList([]const u8) {
    var it = std.mem.splitSequence(u8, string, delimiter);
    var chunk_list: std.ArrayList([]const u8) = std.ArrayList([]const u8).init(allocator);
    while (it.next()) |chunk| try chunk_list.append(chunk);
    return chunk_list;
}

pub fn getAdjacent(comptime T: type, grid: [][]const T, x: usize, y: usize, allocator: std.mem.Allocator) []T {
    var adjacentCells = std.ArrayList(T).init(allocator);

    const max_x = grid[0].len - 1;
    const max_y = grid.len - 1;

    const offsets = [_][2]i32{
        .{ -1, -1 }, .{ -1, 0 }, .{ -1, 1 },
        .{ 0, -1 },  .{ 0, 1 },  .{ 1, -1 },
        .{ 1, 0 },   .{ 1, 1 },
    };

    for (offsets) |offset| {
        const ix: i32 = @intCast(x);
        const iy: i32 = @intCast(y);

        const nx: i32 = @intCast(ix + offset[1]);
        const ny: i32 = @intCast(iy + offset[0]);

        if (nx < 0 or nx > max_x) continue;
        if (ny < 0 or ny > max_y) continue;

        if (nx == ix and ny == iy) continue;

        _ = adjacentCells.append(grid[@intCast(ny)][@intCast(nx)]) catch @panic("Failed to append to adjacentCells");
    }

    return adjacentCells.items;
}

pub fn getAdjacentOptionals(comptime T: type, grid: [][]const T, x: usize, y: usize, allocator: std.mem.Allocator) []?T {
    var adjacentCells = std.ArrayList(?T).init(allocator);

    const max_x = grid[0].len - 1;
    const max_y = grid.len - 1;

    const offsets = [_][2]i32{
        .{ -1, -1 }, .{ -1, 0 }, .{ -1, 1 },
        .{ 0, -1 },  .{ 0, 1 },  .{ 1, -1 },
        .{ 1, 0 },   .{ 1, 1 },
    };

    for (offsets) |offset| {
        const ix: i32 = @intCast(x);
        const iy: i32 = @intCast(y);

        const nx: i32 = @intCast(ix + offset[1]);
        const ny: i32 = @intCast(iy + offset[0]);

        if (nx < 0 or nx > max_x or ny < 0 or ny > max_y) {
            _ = adjacentCells.append(null) catch @panic("Failed to append to adjacentCells");
        } else {
            _ = adjacentCells.append(grid[@intCast(ny)][@intCast(nx)]) catch @panic("Failed to append to adjacentCells");
        }
    }

    return adjacentCells.items;
}
