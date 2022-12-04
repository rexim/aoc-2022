#import "Basic";
#import "File";
#import "String";

Range :: struct {
    low, high: int;
}

parse_range :: (content: string) -> Range {
    found, left, right := split_from_left(content, #char "-");
    return .{
        low = string_to_int(left),
        high = string_to_int(right),
    };
}

parse_range_pair :: (content: string) -> [2]Range {
    found, left, right := split_from_left(content, #char ",");
    result : [2]Range;
    result[0] = parse_range(left);
    result[1] = parse_range(right);
    return result;
}

parse_input :: (content: string) -> [][2]Range {
    input : [..][2]Range;
    found: bool;
    left: string;
    right := content;
    while right.count {
        found, left, right = split_from_left(right, #char "\n");
        array_add(*input, parse_range_pair(left));
    }
    return input;
}

range_contains_another :: (range1: Range, range2: Range) -> bool {
    return range1.low <= range2.low && range2.high <= range1.high;
}

part_1 :: (file_path: string) {
    content, ok := read_entire_file(file_path);
    assert(ok);
    input := parse_input(content);
    count := 0;
    for parse_input(content) {
        if range_contains_another(it[0], it[1]) || range_contains_another(it[1], it[0]) {
            count += 1;
        }
    }
    print("Part 1: %: %\n", file_path, count);
}

range_overlaps_another :: (range1: Range, range2: Range) -> bool {
    return range1.low <= range2.low && range2.low <= range1.high;
}

part_2 :: (file_path: string) {
    content, ok := read_entire_file(file_path);
    assert(ok);
    input := parse_input(content);
    count := 0;
    for parse_input(content) {
        if range_overlaps_another(it[0], it[1]) || range_overlaps_another(it[1], it[0]) {
            count += 1;
        }
    }
    print("Part 2: %: %\n", file_path, count);
}

main :: () {
    part_1("sample.txt");
    part_1("input.txt");
    part_2("sample.txt");
    part_2("input.txt");
}
