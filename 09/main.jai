#import "Basic";
#import "File";
#import "String";
#import "Math";
#import "Sort";

Motion :: struct {
    direction : enum { LEFT :: 0; RIGHT :: 1; UP :: 2; DOWN :: 3; };
    length : int;
}

directions : [4]Vec2 : .[.{-1, 0}, .{1, 0}, .{0, -1}, .{0, 1}];

Vec2 :: struct {
    x, y: int;
}

operator == :: (a: Vec2, b: Vec2) -> bool {
    return a.x == b.x && a.y == b.y;
}

operator + :: (a: Vec2, b: Vec2) -> Vec2 {
    return .{
        a.x + b.x,
        a.y + b.y,
    };
}

parse_input :: (content : string) -> []Motion {
    result : [..]Motion;
    left: string;
    found: bool;
    right := content;
    while right.count > 0 {
        found, left, right = split_from_left(right, #char "\n");
        motion : Motion;
        if left[0] == {
            case #char "L"; motion.direction = .LEFT;
            case #char "R"; motion.direction = .RIGHT;
            case #char "U"; motion.direction = .UP;
            case #char "D"; motion.direction = .DOWN;
            case; assert(false, "unreachable");
        }
        motion.length = string_to_int(slice(left, 2, left.count - 2));
        array_add(*result, motion);
    }
    return result;
}

sign :: (x: int) -> int {
    return cast(int)(x > 0) - cast(int)(x < 0);
}

adjust_tail :: (head: Vec2, tail: *Vec2) {
    dx := head.x - tail.x;
    dy := head.y - tail.y;
    if abs(dy) > 1 || abs(dx) > 1 {
        if abs(dy) > abs(dx) {
            tail.x = head.x;
            tail.y = head.y - sign(dy);
        } else if abs(dy) < abs(dx) {
            tail.y = head.y;
            tail.x = head.x - sign(dx);
        } else {
            tail.x = head.x - sign(dx);
            tail.y = head.y - sign(dy);
        }
    }
}

count_unique_positions :: (trace: []Vec2) -> int {
    quick_sort(trace, (a: Vec2, b: Vec2) -> int {
        if a.x != b.x return a.x - b.x;
        return a.y - b.y;
    });
    count := 1;
    start := 0;
    for 0..trace.count-1 {
        if trace[start] != trace[it] {
            count += 1;
            start = it;
        }
    }
    return count;
}

solve :: ($N: int, part: int, file_path: string) {
    content, ok := read_entire_file(file_path);
    assert(ok);
    motions := parse_input(content);
    rope : [N]Vec2;
    trace : [..]Vec2;
    array_add(*trace, rope[N-1]);
    for motion: motions {
        for 0..motion.length-1 {
            rope[0] += directions[motion.direction];
            for 0..N-2 adjust_tail(rope[it], *rope[it+1]);
            array_add(*trace, rope[N-1]);
        }
    }
    print("Part %: %: %\n", part, file_path, count_unique_positions(trace));
}

main :: () {
    lengths :: int.[2, 10];
    solve(2, 1, "sample.txt");
    solve(2, 1, "sample2.txt");
    solve(2, 1, "input.txt");
    solve(10, 2, "sample.txt");
    solve(10, 2, "sample2.txt");
    solve(10, 2, "input.txt");
}
