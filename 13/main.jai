#import "Basic";
#import "String";
#import "File";
#import "Sort";

Packet :: struct {
    kind : enum { NUMBER; LIST; }
    number: int;
    children: [..]Packet;
}

parse_packet_number :: (source: string) -> (Packet, string) {
    assert(source.count > 0);
    index := 0;
    while index < source.count && #char "0" <= source[index] && source[index] <= #char "9" {
        index += 1;
    }
    assert(index > 0, "Number does not start with digit: |%|", source);

    return Packet.{
        kind = .NUMBER,
        number = string_to_int(slice(source, 0, index)),
    }, slice(source, index, source.count - index);
}

parse_packet_list :: (source0: string) -> (Packet, string) {
    source := source0;

    assert(source.count > 0 && source[0] == #char "[");
    source = slice(source, 1, source.count - 1);

    packet := Packet.{ kind = .LIST };

    if source.count > 0 && source[0] == #char "]" {
        return packet, slice(source, 1, source.count - 1);
    }

    item, rest := parse_packet(source);
    array_add(*packet.children, item);
    source = rest;

    while source.count > 0 && source[0] == #char "," {
        source = slice(source, 1, source.count - 1);
        item, rest = parse_packet(source);
        array_add(*packet.children, item);
        source = rest;
    }

    assert(source.count > 0 && source[0] == #char "]");

    return packet, slice(source, 1, source.count - 1);
}

parse_packet :: (source: string) -> (Packet, string) {
    assert(source.count > 0);
    if source[0] == #char "[" {
        packet, rest := parse_packet_list(source);
        return packet, rest;
    } else {
        packet, rest := parse_packet_number(source);
        return packet, rest;
    }
}

Order :: enum {
    CORRECT;
    WRONG;
    CONTINUE;
}

check_order_of_int :: (l: int, r: int) -> Order {
    if l < r return .CORRECT;
    if l > r return .WRONG;
    return .CONTINUE;
}

packet_number :: (x: int) -> Packet {
    return .{
        kind = .NUMBER,
        number = x,
    };
}

packet_wrap_in_list :: (packet: Packet) -> Packet {
    list: Packet;
    list.kind = .LIST;
    array_add(*list.children, packet);
    return list;
}

check_order_of_packet :: (lp: Packet, rp: Packet) -> Order {
    if lp.kind == .NUMBER && rp.kind == .NUMBER  {
        return check_order_of_int(lp.number, rp.number);
    }
    if lp.kind == .LIST && rp.kind == .LIST {
        n := min(lp.children.count, rp.children.count);
        for 0..n-1 {
            order := check_order_of_packet(*lp.children[it], *rp.children[it]);
            if order != .CONTINUE return order;
        }
        return check_order_of_int(lp.children.count, rp.children.count);
    }
    if lp.kind == .NUMBER && rp.kind == .LIST {
        return check_order_of_packet(packet_wrap_in_list(lp), rp);
    }
    if lp.kind == .LIST && rp.kind == .NUMBER {
        return check_order_of_packet(lp, packet_wrap_in_list(rp));
    }
    assert(false, "unreachable");
    return .CONTINUE;
}

part1 :: (file_path: string) {
    content, ok := read_entire_file(file_path);
    assert(ok);
    lines := split(content, "\n");
    left_packet, right_packet: Packet;

    index := 1;
    answer := 0;
    while lines.count >= 2 {
        left_packet, content = parse_packet(lines[0]);
        right_packet, content = parse_packet(lines[1]);

        order := check_order_of_packet(left_packet, right_packet);
        assert(order != .CONTINUE);
        if order == .CORRECT then answer += index;

        lines.data += 2; lines.count -= 2;
        if lines.count > 0 && lines[0].count == 0 {
            lines.data += 1; lines.count -= 1;
        }
        index += 1;
    }
    print("Part 1: %: %\n", file_path, answer);
}

print_packet :: (using p: Packet) {
    if kind == {
        case .NUMBER; print("%", number);
        case .LIST; {
            print("[");
            for children {
                if it_index > 0 then print(",");
                print_packet(it);
            }
            print("]");
        }
    }
}

packet_is_divider :: (packet: Packet) -> bool {
    return packet.kind == .LIST &&
        packet.children.count == 1 &&
        packet.children[0].kind == .LIST &&
        packet.children[0].children.count == 1 &&
        packet.children[0].children[0].kind == .NUMBER &&
        (packet.children[0].children[0].number == 2 ||
         packet.children[0].children[0].number == 6);
}

part2 :: (file_path: string) {
    content, ok := read_entire_file(file_path);
    assert(ok);
    lines := split(content, "\n");
    packets : [..]Packet;
    for line: lines {
        if line.count == 0 continue;

        packet, rest := parse_packet(line);
        assert(rest.count == 0);
        array_add(*packets, packet);
    }
    array_add(*packets, packet_wrap_in_list(packet_wrap_in_list(packet_number(2))));
    array_add(*packets, packet_wrap_in_list(packet_wrap_in_list(packet_number(6))));
    bubble_sort(packets, (a: Packet, b: Packet) -> int {
        if check_order_of_packet(*a, *b) == {
            case .CORRECT; return -1;
            case .WRONG; return 1;
        }
        assert(false, "unreachable");
        return 0;
    });
    answer := 1;
    for packets {
        if packet_is_divider(it) {
            answer *= it_index + 1;
        }
    }
    print("Part 2: %: %\n", file_path, answer);
}

main :: () {
    part1("sample.txt");
    part1("input.txt");
    part2("sample.txt");
    part2("input.txt");
}
