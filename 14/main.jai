#import "Basic";
#import "File";
#import "String";
#import "Hash_Table";
Hash :: #import "Hash";

Vec2 :: struct {
    x, y: int;
}

BlockedTable :: Table (
    Vec2, bool,
    given_compare_function = (a: Vec2, b: Vec2) -> bool {
        return a == b;
    },
    given_hash_function = (a: Vec2) -> u32 {
        return Hash.get_hash(cast(u32)a.x*32768 + cast(u32)a.y);
    },
);

operator + :: (a: Vec2, b: Vec2) -> Vec2 {
    return .{a.x + b.x, a.y + b.y};
}

operator == :: (a: Vec2, b: Vec2) -> bool {
    return a.x == b.x && a.y == b.y;
}

parse_input :: (content: string) -> (blocked: BlockedTable, lowest_y: int) {
    blocked: BlockedTable;
    lowest_y := 0;
    for split(content, "\n") {
        if it.count == 0 continue;
        path: [..]Vec2;
        for split(it, " -> ") {
            parts := split(it, ",");
            assert(parts.count == 2);
            cell := Vec2.{
                x = string_to_int(parts[0]),
                y = string_to_int(parts[1]),
            };
            array_add(*path, cell);
            lowest_y = max(lowest_y, cell.y);
        }
        for 0..path.count-2 {
            a := path[it];
            b := path[it+1];
            if a.x == b.x {
                x := a.x;
                y1 := a.y;
                y2 := b.y;
                if y1 > y2 then Swap(*y1, *y2);
                for y: y1..y2 table_add(*blocked, .{x, y}, true);
            } else if a.y == b.y {
                y := a.y;
                x1 := a.x;
                x2 := b.x;
                if x1 > x2 then Swap(*x1, *x2);
                for x: x1..x2 table_add(*blocked, .{x, y}, true);
            } else {
                assert(false, "unreachable");
            }
        }
    }
    return blocked, lowest_y;
}

part1 :: (file_path: string) {
    content, ok := read_entire_file(file_path);
    sand_source :: Vec2.{500,0};

    blocked, lowest_y := parse_input(content);

    count := 0;
    while true {
        sand := sand_source;
        while sand.y <= lowest_y {
            next_sand := sand + .{0, 1};
            if table_find_pointer(*blocked, next_sand) == null {
                sand = next_sand;
                continue;
            }
            next_sand = sand + .{-1, 1};
            if table_find_pointer(*blocked, next_sand) == null {
                sand = next_sand;
                continue;
            }
            next_sand = sand + .{1, 1};
            if table_find_pointer(*blocked, next_sand) == null {
                sand = next_sand;
                continue;
            }
            count += 1;
            table_add(*blocked, sand, true);
            break;
        }
        if sand.y > lowest_y break;
    }
    print("Part 1: %: %\n", file_path, count);
}

part2 :: (file_path: string) {
    content, ok := read_entire_file(file_path);
    sand_source :: Vec2.{500,0};

    blocked, lowest_y := parse_input(content);

    count := 0;
    while table_find_pointer(*blocked, sand_source) == null {
        sand := sand_source;
        while true {
            next_sand := sand + .{0, 1};
            if table_find_pointer(*blocked, next_sand) == null && next_sand.y < lowest_y + 2 {
                sand = next_sand;
                continue;
            }
            next_sand = sand + .{-1, 1};
            if table_find_pointer(*blocked, next_sand) == null && next_sand.y < lowest_y + 2 {
                sand = next_sand;
                continue;
            }
            next_sand = sand + .{1, 1};
            if table_find_pointer(*blocked, next_sand) == null && next_sand.y < lowest_y + 2 {
                sand = next_sand;
                continue;
            }
            count += 1;
            table_add(*blocked, sand, true);
            break;
        }
    }
    print("Part 2: %: %\n", file_path, count);
}

main :: () {
    part1("sample.txt");
    part1("input.txt");
    part2("sample.txt");
    part2("input.txt");
}
