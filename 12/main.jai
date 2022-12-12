#import "Basic";
#import "File";
#import "String";

Vec2 :: struct {
    x, y: int;
}

operator + :: (a: Vec2, b: Vec2) -> Vec2 {
    return .{a.x + b.x, a.y + b.y};
}

operator == :: (a: Vec2, b: Vec2) -> bool {
    return a.x == b.x && a.y == b.y;
}

parse_input :: (content: string) -> (grid: []u8, size: Vec2, start: Vec2, end: Vec2) {
    lines := split(content, "\n");
    if lines.count <= 0 then return .[], .{}, .{}, .{};
    if lines[lines.count-1] == "" {
        lines.count -= 1;
    }
    height := lines.count;
    width := lines[0].count;
    grid : [..]u8;
    start, end : Vec2;
    for line, y: lines {
        assert(line.count == width);
        for x: 0..line.count-1 {
            if line[x] == {
                case #char "S"; start = .{x, y};
                case #char "E"; end = .{x, y};
            }
            array_add(*grid, line[x]);
        }
    }
    return grid, .{width, height}, start, end;
}

inbounds :: (using cell: Vec2, size: Vec2) -> bool {
    return 0 <= x && x < size.x && 0 <= y && y < size.y;
}

neighbors :: (cell: Vec2, size: Vec2) -> []Vec2 {
    result : [..]Vec2;
    directions :: Vec2.[
        .{-1, 0},
        .{1, 0},
        .{0, 1},
        .{0, -1},
    ];
    for directions {
        neighbor := cell + it;
        if inbounds(neighbor, size) {
            array_add(*result, neighbor);
        }
    }
    return result;
}

index :: (cell: Vec2, size: Vec2) -> int {
    return cell.y*size.x + cell.x;
}

print_visited :: (visited: []int, size: Vec2) {
    for y: 0..size.y-1 {
        for x: 0..size.x-1 {
            print("% ", visited[index(.{x, y}, size)]);
        }
        print("\n");
    }
}

elevation :: (x: u8) -> int {
    if x == {
        case #char "S"; return 0;
        case #char "E"; return #char "z" - #char "a";
        case; return x - #char "a";
    }
}

shortest_path ::(grid: []u8, size: Vec2, start: Vec2, end: Vec2) -> int, bool {
    visited := NewArray(size.x*size.y, int);
    for *visited {
        (<<it) = -1;
    }
    wave : [..]Vec2;
    array_add(*wave, start);
    visited[index(start, size)] = 0;
    while wave.count > 0 {
        new_wave : [..]Vec2;
        for cell: wave {
            for neighbor: neighbors(cell, size) {
                elevation_diff := elevation(grid[index(neighbor, size)]) - elevation(grid[index(cell, size)]);
                if visited[index(neighbor, size)] < 0 && elevation_diff <= 1 {
                    if neighbor == end {
                        return visited[index(cell, size)] + 1, true;
                    }
                    visited[index(neighbor, size)] = visited[index(cell, size)] + 1;
                    array_add(*new_wave, neighbor);
                }
            }
        }
        wave = new_wave;
    }
    return 0, false;
}

part1 :: (file_path: string) {
    content, ok := read_entire_file(file_path);
    grid, size, start, end := parse_input(content);
    ans, found := shortest_path(grid, size, start, end);
    assert(found);
    print("Part 1: %: %\n", file_path, ans);
}

part2 :: (file_path: string) {
    content, ok := read_entire_file(file_path);
    grid, size, start, end := parse_input(content);
    ans := 10_000_000;
    for y: 0..size.y-1 {
        for x: 0..size.x-1 {
            if grid[index(.{x, y}, size)] == #char "a" {
                new_ans, found := shortest_path(grid, size, .{x, y}, end);
                if found then ans = min(new_ans, ans);
            }
        }
    }
    print("Part 2: %: %\n", file_path, ans);
}

main :: () {
    part1("sample.txt");
    part1("input.txt");
    part2("sample.txt");
    part2("input.txt");
}
