#import "Basic";
#import "File";
#import "String";
#import "Math";

Inst :: struct {
    type : enum { NOOP; ADDX; };
    value : int;
}

parse_input :: (content: string) -> []Inst {
    result : [..]Inst;
    found: bool;
    left: string;
    right := content;
    while right.count > 0 {
        found, left, right = split_from_left(right, #char "\n");
        inst : Inst;
        if starts_with(left, "noop") {
            inst.type = .NOOP;
        } else if starts_with(left, "addx") {
            inst.type = .ADDX;
            inst.value = string_to_int(slice(left, 5, left.count - 5));
        } else {
            assert(false, "Unreachable. Unknown instruction. %", left);
        }
        array_add(*result, inst);
    }
    return result;
}

signal_strength :: (cycle: int, x: int) -> int {
    if cycle > 20 {
        if (cycle - 20)%40 == 0 {
            print("%: % %\n", cycle, x, cycle*x);
            return cycle*x;
        } else {
            return 0;
        }
    } else if (cycle == 20)  {
        print("%: % %\n", cycle, x, cycle*x);
        return cycle*x;
    }

    return 0;
}

part1 :: (file_path: string) {
    content, ok := read_entire_file(file_path);
    assert(ok);
    program := parse_input(content);
    x := 1;
    cycle := 1;
    ans := 0;
    for program {
        if it.type == {
            case .NOOP; {
                ans += signal_strength(cycle, x);
                cycle += 1;
            }
            case .ADDX; {
                ans += signal_strength(cycle, x);
                cycle += 1;
                ans += signal_strength(cycle, x);
                cycle += 1;
                x += it.value;
            }
        }
    }
    print("Part 1: %: %\n", file_path, ans);
}

ROWS :: 6;
COLUMNS :: 40;

render_pixel :: (screen: *[ROWS][COLUMNS]u8, cycle: int, x: int) {
    sy := (cycle-1)/COLUMNS;
    sx := (cycle-1)%COLUMNS;
    if abs(x - sx) < 2 {
        (<<screen)[sy][sx] = #char "#";
    } else {
        (<<screen)[sy][sx] = #char ".";
    }
}

part2 :: (file_path: string) {
    content, ok := read_entire_file(file_path);
    assert(ok);
    program := parse_input(content);
    x := 1;
    cycle := 1;
    ans := 0;
    screen : [ROWS][COLUMNS]u8;
    for program {
        if it.type == {
            case .NOOP; {
                render_pixel(*screen, cycle, x);
                cycle += 1;
            }
            case .ADDX; {
                render_pixel(*screen, cycle, x);
                cycle += 1;
                render_pixel(*screen, cycle, x);
                cycle += 1;
                x += it.value;
            }
        }
    }
    print("Part 2: %:\n", file_path);
    for row : 0..ROWS-1 {
        print("%\n", to_string(screen[row]));
    }
}

main :: () {
    part1("sample2.txt");
    part1("input.txt");
    part2("sample2.txt");
    part2("input.txt");
}
