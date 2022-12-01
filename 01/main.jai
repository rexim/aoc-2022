#import "Basic";
#import "File";
#import "String";
#import "Sort";

part_1 :: (file_path: string) {
    content, ok := read_entire_file(file_path);
    if !ok {
        print("ERROR: could not read file: %", file_path);
        exit(1);
    }
    found, left, right := split_from_left(content, #char "\n");
    sum := 0;
    ans := 0;
    while found {
        if left.count > 0 {
            sum += string_to_int(left);
        } else {
            if ans < sum then ans = sum;
            sum = 0;
        }
        found, left, right = split_from_left(right, #char "\n");
    }
    if sum > 0 if ans < sum then ans = sum;
    print("Part 1: %: %\n", file_path, ans);
}

part_2 :: (file_path: string) {
    content, ok := read_entire_file(file_path);
    if !ok {
        print("ERROR: could not read file: %", file_path);
        exit(1);
    }
    found, left, right := split_from_left(content, #char "\n");
    sum := 0;
    sums : [..]int;
    while found {
        if left.count > 0 {
            sum += string_to_int(left);
        } else {
            array_add(*sums, sum);
            sum = 0;
        }
        found, left, right = split_from_left(right, #char "\n");
    }
    if sum > 0 then array_add(*sums, sum);
    quick_sort(sums, (a: int, b: int) -> int {
        return b - a;
    });
    assert(sums.count >= 3);
    ans := 0;
    for 0..2 ans += sums[it];
    print("Part 2: %: %\n", file_path, ans);
}

main :: () {
    part_1("sample.txt");
    part_1("input.txt");
    part_2("sample.txt");
    part_2("input.txt");
}
