#import "Basic";
#import "String";
#import "File";

parse_input :: (content: string) -> []string {
    result: [..]string;
    found: bool;
    left: string;
    right := content;
    while right.count > 0 {
        found, left, right = split_from_left(right, #char "\n");
        array_add(*result, left);
    }
    return result;
}

is_out_of_bounds :: (grid: []string, x: int, y: int) -> bool {
    return !(0 <= y && y < grid.count && 0 <= x && x < grid[0].count);
}

viewing_distance_in_that_direction :: (grid: []string, x: int, y: int, dx: int, dy: int) -> int {
    value := grid[y][x];
    count := 0;
    x += dx;
    y += dy;
    while !is_out_of_bounds(grid, x, y) {
        count += 1;
        if grid[y][x] >= value return count;
        x += dx;
        y += dy;
    }
    return count;
}

all_smaller_in_that_direction :: (grid: []string, x: int, y: int, dx: int, dy: int) -> bool {
    value := grid[y][x];
    x += dx;
    y += dy;
    while !is_out_of_bounds(grid, x, y) {
        if grid[y][x] >= value return false;
        x += dx;
        y += dy;
    }
    return true;
}

directions : [][2]int = .[
    .[-1, 0],
    .[1, 0],
    .[0, 1],
    .[0, -1],
];

is_visible :: (grid: []string, x: int, y: int) -> bool {
    for d: directions {
        if all_smaller_in_that_direction(grid, x, y, d[0], d[1]) return true;
    }
    return false;
}

part1 :: (file_path: string) {
    content, ok := read_entire_file(file_path);
    assert(ok);
    grid := parse_input(content);
    count := 0;
    for y: 1..grid.count-2 {
        for x: 1..grid[0].count-2 {
            if is_visible(grid, x, y) {
                count += 1;
            }
        }
    }
    print("Part 1: %: %\n", file_path, count + grid.count*2 + (grid[0].count-2)*2);
}

scenic_score :: (grid: []string, x: int, y: int) -> int {
    score := 1;
    for d: directions {
        score *= viewing_distance_in_that_direction(grid, x, y, d[0], d[1]);
    }
    return score;
}

part2 :: (file_path: string) {
    content, ok := read_entire_file(file_path);
    assert(ok);
    grid := parse_input(content);
    best_score := 0;
    for y: 0..grid.count-1 {
        for x: 0..grid[0].count-1 {
            score := scenic_score(grid, x, y);
            best_score = max(best_score, score);
        }
    }
    print("Part 2: %: %\n", file_path, best_score);
}

main :: () {
    part1("sample.txt");
    part1("input.txt");
    part2("sample.txt");
    part2("input.txt");
}
