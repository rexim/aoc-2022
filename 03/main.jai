#import "Basic";
#import "File";
#import "String";

parse_input :: (content: string) -> []string {
    input : [..]string;
    found: bool;
    left: string;
    right := content;
    score := 0;
    while right.count > 0 {
        found, left, right = split_from_left(right, #char "\n");
        array_add(*input, left);
    }
    return input;
}

priority :: (x: int) -> int {
    if #char "a" <= x && x <= #char "z" return x - #char "a" + 1;
    if #char "A" <= x && x <= #char "Z" return x - #char "A" + 27;
    assert(false, "unreachable");
    return 0;
}

part_1 :: (file_path: string) {
    content, ok := read_entire_file(file_path);
    assert(ok);
    lines := parse_input(content);
    ans := 0;
    for 0..lines.count-1 {
        half_line := lines[it].count/2;
        left := slice(lines[it], 0, half_line);
        right := slice(lines[it], half_line, half_line);
        count_common := 0;
        for 0..half_line-1 {
            index := find_index_from_left(right, left[it]);
            if index >= 0 {
                ans += priority(left[it]);
                break;
            }
        }
    }
    print("Part 1: %: %\n", file_path, ans);
}

rucksack_stats :: (items: string) -> [52]int {
    result : [52]int;
    for 0..items.count-1 {
        result[priority(items[it])-1] += 1;
    }
    return result;
}

part_2 :: (file_path : string) {
    content, ok := read_entire_file(file_path);
    assert(ok);
    lines := parse_input(content);
    ans := 0;
    for 0..lines.count/3-1 {
        r1 := rucksack_stats(lines[it*3+0]);
        r2 := rucksack_stats(lines[it*3+1]);
        r3 := rucksack_stats(lines[it*3+2]);
        for 0..51 {
            if r1[it] > 0 && r2[it] > 0 && r3[it] > 0 {
                ans += it + 1;
                break;
            }
        }
    }
    print("Part 2: %: %\n", file_path, ans);
}

main :: () {
    part_1("sample.txt");
    part_1("input.txt");
    part_2("sample.txt");
    part_2("input.txt");
}
