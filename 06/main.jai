#import "Basic";
#import "String";
#import "File";

Marker :: struct(capacity: int) {
    items : [capacity]u8;
    begin, count : int;
};

marker_string :: (using marker: Marker) -> string {
    sb : String_Builder;
    for 0..count-1 {
        append(*sb, items[(it + begin)%items.count]);
    }
    return builder_to_string(*sb);
}

marker_add :: (using marker : *Marker, char: u8) {
    items[(begin + count)%items.count] = char;
    if count < items.count {
        count += 1;
    } else {
        begin = (begin + 1)%items.count;
    }
}

marker_is_start :: (using marker : Marker) -> bool {
    if count < items.count {
        return false;
    }
    for i: 0..count-2 {
        for j: i+1..count-1 {
            if items[(begin + i)%items.count] == items[(begin + j)%items.count] {
                return false;
            }
        }
    }

    return true;
}

find_start :: ($capacity: int, message: string) -> int {
    marker : Marker(capacity);
    count := 0;
    for 0..message.count-1 {
        if marker_is_start(marker) {
            return count;
        }
        marker_add(*marker, message[it]);
        count += 1;
    }
    assert(false, "unreachable");
    return 0;
}

main :: () {
    print("Samples:\n");
    samples : []string = .[
        "mjqjpqmgbljsphdztnvjfqwrcgsmlb",
        "bvwbjplbgvbhsrlpgdmjqwftvncz",
        "nppdvjthqldpwncqszvftbrmjlhg",
        "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg",
        "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw",
    ];
    for samples {
        print("    % => %\n", it, find_start(4, it));
    }
    content, ok := read_entire_file("input.txt");
    assert(ok);
    print("Part 1: %\n", find_start(4, content));
    print("Part 2: %\n", find_start(14, content));
}
