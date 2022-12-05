#import "Basic";
#import "File";
#import "String";
#load "data.jai";

append_string :: (stack: *[..]int, s: string) {
    for 0..s.count-1 array_add(stack, s[it]);
}

make_state :: (rows: []string) -> [][..]u8 {
    result : [..][..]u8;
    for row: rows {
        column : [..]u8;
        for 0..row.count-1 {
            array_add(*column, row[it]);
        }
        array_add(*result, column);
    }
    return result;
}

apply_moves1 :: (state: [][..]u8, moves: [][3]int) {
    for move: moves {
        for 0..move[0]-1 {
            src := *state[move[1]-1];
            dst := *state[move[2]-1];
            assert(src.count > 0);
            array_add(dst, (<<src)[src.count - 1]);
            src.count -= 1;
        }
    }
}

apply_moves2 :: (state: [][..]u8, moves: [][3]int) {
    for move: moves {
        count := move[0];
        src := *state[move[1]-1];
        dst := *state[move[2]-1];
        assert(src.count >= count);
        for src.count - count..src.count-1 {
            array_add(dst, (<<src)[it]);
        }
        src.count -= count;
    }
}

get_message :: (state: [][..]u8) -> string {
    builder: String_Builder;
    for state {
        append(*builder, it[it.count - 1]);
    }
    return builder_to_string(*builder);
}

part_1 :: (init_state: []string, moves: [][3]int) -> string {
    state := make_state(init_state);
    apply_moves1(state, moves);
    return get_message(state);
}

part_2 :: (init_state: []string, moves: [][3]int) -> string {
    state := make_state(init_state);
    apply_moves2(state, moves);
    return get_message(state);
}

main :: () {
    print("part 1: sample: %\n", part_1(sample_state, sample_moves));
    print("part 1: input: %\n", part_1(input_state, input_moves));
    print("part 2: sample: %\n", part_2(sample_state, sample_moves));
    print("part 2: input: %\n", part_2(input_state, input_moves));
}
