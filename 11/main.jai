#import "Basic";
#import "File";
#import "String";
#import "Sort";

Operation :: struct {
    kind: enum { ADD; MUL; SQR; };
    argument: int;
}

Monkey :: struct {
    items: [..]int;
    operation: Operation;
    test: int;
    if_true: int;
    if_false: int;
    inspected: int;
}

strip_prefix :: (s: string, prefix: string) -> string {
    return slice(s, prefix.count, s.count - prefix.count);
}

check_and_strip_prefix :: (s: string, prefix: string) -> string {
    assert(starts_with(s, prefix));
    return strip_prefix(s, prefix);
}

parse_monkey :: (lines: []string) -> Monkey {
    starting_items := check_and_strip_prefix(lines[0], "  Starting items: ");
    operation := check_and_strip_prefix(lines[1], "  Operation: new = old ");
    test := check_and_strip_prefix(lines[2], "  Test: divisible by ");
    if_true := check_and_strip_prefix(lines[3], "    If true: throw to monkey ");
    if_false := check_and_strip_prefix(lines[4], "    If false: throw to monkey ");

    monkey: Monkey;
    for split(starting_items, ", ") {
        array_add(*monkey.items, string_to_int(it));
    }
    if operation[0] == {
        case #char "+"; {
            operation = check_and_strip_prefix(operation, "+ ");
            monkey.operation = .{
                kind = .ADD,
                argument = string_to_int(operation),
            };
        }
        case #char "*"; {
            operation = check_and_strip_prefix(operation, "* ");
            if operation == "old" {
                monkey.operation = .{
                    kind = .SQR,
                };
            } else {
                monkey.operation = .{
                    kind = .MUL,
                    argument = string_to_int(operation),
                };
            }
        }
    }
    monkey.test = string_to_int(test);
    monkey.if_true = string_to_int(if_true);
    monkey.if_false = string_to_int(if_false);
    return monkey;
}

parse_input :: (content: string) -> []Monkey {
    lines := split(content, "\n");
    monkeys : [..]Monkey;
    while lines.count > 0 {
        monkey_lines : []string = ---;
        monkey_lines.data = lines.data + 1;
        monkey_lines.count = 5;
        array_add(*monkeys, parse_monkey(monkey_lines));

        lines.data += 7;
        lines.count -= 7;
    }
    return monkeys;
}

operation_apply :: (using operation: Operation, value: int) -> int {
    if kind == {
        case .ADD; return value + argument;
        case .MUL; return value * argument;
        case .SQR; return value * value;
    }
    assert(false, "unreachable");
    return 0;
}

monkey_turn_part1 :: (using monkey: *Monkey, monkeys: []Monkey) {
    for items {
        new_worry := operation_apply(operation, it)/3;
        if new_worry%test == 0 {
            array_add(*monkeys[if_true].items, new_worry);
        } else {
            array_add(*monkeys[if_false].items, new_worry);
        }
        inspected += 1;
    }
    items.count = 0;
}

part1 :: (file_path: string) {
    content, ok := read_entire_file(file_path);
    monkeys := parse_input(content);
    for 1..20 {
        for *monkeys {
            monkey_turn_part1(it, monkeys);
        }
    }
    quick_sort(monkeys, (a: Monkey, b: Monkey) -> int {
        return b.inspected - a.inspected;
    });
    print("Part 1: %: %\n", file_path, monkeys[0].inspected*monkeys[1].inspected);
}

monkey_turn_part2 :: (using monkey: *Monkey, monkeys: []Monkey, limit: int) {
    for items {
        new_worry := operation_apply(operation, it)%limit;
        if new_worry%test == 0 {
            array_add(*monkeys[if_true].items, new_worry);
        } else {
            array_add(*monkeys[if_false].items, new_worry);
        }
        inspected += 1;
    }
    items.count = 0;
}

part2 :: (file_path: string) {
    content, ok := read_entire_file(file_path);
    monkeys := parse_input(content);
    limit := 1;
    for *monkeys limit *= it.test;
    for 1..10_000 {
        for *monkeys {
            monkey_turn_part2(it, monkeys, limit);
        }
    }
    quick_sort(monkeys, (a: Monkey, b: Monkey) -> int {
        return b.inspected - a.inspected;
    });
    print("Part 2: %: %\n", file_path, monkeys[0].inspected*monkeys[1].inspected);
}

main :: () {
    part1("sample.txt");
    part1("input.txt");
    part2("sample.txt");
    part2("input.txt");
}
