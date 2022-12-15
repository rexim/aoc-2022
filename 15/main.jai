#import "Basic";
#import "File";
#import "String";
#import "Math";
#import "Hash_Table";
#import "Sort";

Vec2 :: struct {
    x, y: int;
}

check_and_strip_prefix :: (s: string, prefix: string) -> string {
    assert(starts_with(s, prefix), "\"%\" does not start with \"%\"", s, prefix);
    return slice(s, prefix.count, s.count - prefix.count);
}

parse_point :: (s: string) -> Vec2 {
    comps := split(s, ", ");
    assert(comps.count == 2);
    return .{
        x = string_to_int(check_and_strip_prefix(comps[0], "x=")),
        y = string_to_int(check_and_strip_prefix(comps[1], "y=")),
    };
}

parse_input :: (content: string) -> (sensors: []Vec2, beacons: []Vec2) {
    sensors : [..]Vec2;
    beacons : [..]Vec2;
    for line: split(content, "\n") {
        if line.count == 0 continue;
        comps := split(line, ": ");
        assert(comps.count == 2);
        array_add(*sensors, parse_point(check_and_strip_prefix(comps[0], "Sensor at ")));
        array_add(*beacons, parse_point(check_and_strip_prefix(comps[1], "closest beacon is at ")));
    }
    return sensors, beacons;
}

Range :: struct {
    low, high: int;
}

scan_row :: (sensors: []Vec2, beacons: []Vec2, row: int) -> []Range {
    ranges: [..]Range;
    for sensor: sensors {
        d := abs(sensor.x - beacons[it_index].x) + abs(sensor.y - beacons[it_index].y);
        t := d - abs(sensor.y - row);
        if t > 0 {
            x1 := sensor.x - t;
            x2 := sensor.x + t;
            array_add(*ranges, .{x1, x2});
        }
    }
    return ranges;
}

merge_and_bound :: (ranges: []Range, upper_bound: int) -> []Range {
    for *ranges {
        if it.low < 0 then it.low = 0;
        if it.high > upper_bound then it.high = upper_bound;
    }
    quick_sort(ranges, (a: Range, b: Range) -> int {
        return a.low - b.low;
    });
    merged_ranges : [..]Range;
    for ranges {
        if merged_ranges.count == 0 {
            array_add(*merged_ranges, it);
        } else {
            m := *merged_ranges[merged_ranges.count-1];
            if intersect(m, it) || m.high + 1 == it.low {
                m.high = max(m.high, it.high);
            } else {
                array_add(*merged_ranges, it);
            }
        }
    }
    return merged_ranges;
}

part1 :: (file_path: string, row: int) {
    content, ok := read_entire_file(file_path);
    assert(ok, "Can't open file %", file_path);
    sensors, beacons := parse_input(content);
    visited : Table(int, bool);
    for scan_row(sensors, beacons, row) {
        for col: it.low..it.high {
            if table_find_pointer(*visited, col) == null {
                table_add(*visited, col, true);
            }
        }
    }
    for beacon: beacons {
        if beacon.y == row && table_find_pointer(*visited, beacon.x) != null {
            table_remove(*visited, beacon.x);
        }
    }
    print("Part: 1, file: %, row: %, answer: %\n", file_path, row, visited.count);
}

intersect :: (a: Range, b: Range) -> bool {
    return a.high >= b.low && b.high >= a.low;
}

part2 :: (file_path: string, upper_bound: int) {
    content, ok := read_entire_file(file_path);
    assert(ok, "Can't open file %", file_path);
    sensors, beacons := parse_input(content);
    for row: 0..upper_bound {
        ranges := merge_and_bound(scan_row(sensors, beacons, row), upper_bound);
        if ranges.count > 1 {
            x := ranges[0].high + 1;
            y := row;
            print("%: % (%, %) %\n", row, ranges, x, y, x*4000000 + y);
        }
    }
}

main :: () {
    part1("sample.txt", 10);
    part1("input.txt", 10);
    part1("input.txt", 2000000);
    part2("sample.txt", 20);
    part2("input.txt", 4000000);
}
