#import "Basic";
#import "File";
#import "String";

Outcome :: enum int {
    LOSE :: 0;
    DRAW :: 1;
    WIN  :: 2;
}

Shape :: enum int {
    ROCK     :: 0;
    PAPER    :: 1;
    SCISSORS :: 2;
}

parse_input :: (content: string) -> [][2]int {
    input : [..][2]int;
    found: bool;
    left: string;
    right := content;
    score := 0;
    while right.count > 0 {
        found, left, right = split_from_left(right, #char "\n");
        assert(left.count == 3);
        row : [2]int;
        row[0] = left[0] - #char "A";
        row[1] = left[2] - #char "X";
        array_add(*input, row);
    }
    return input;
}

part_1 :: (file_path: string) {
    PLAY : [3][3]Outcome : .[
        // Rock   Paper  Scissors
        .[.DRAW, .WIN,  .LOSE ], // Rock
        .[.LOSE, .DRAW, .WIN], // Paper
        .[.WIN,  .LOSE, .DRAW], // Scissors
    ];

    content, ok := read_entire_file(file_path);
    assert(ok);
    input := parse_input(content);
    score := 0;
    for 0..input.count-1 {
        opponent := input[it][0];
        you := input[it][1];
        score += cast(int)PLAY[opponent][you]*3 + you + 1;
    }
    print("Part 1: %: %\n", file_path, score);
}

part_2 :: (file_path: string) {
    PLAY : [3][3]Shape : .[
        // Lose       Draw    Win
        .[.SCISSORS, .ROCK,     .PAPER],    // Rock
        .[.ROCK,     .PAPER,    .SCISSORS], // Paper
        .[.PAPER,    .SCISSORS, .ROCK],     // Scissors
    ];

    content, ok := read_entire_file(file_path);
    assert(ok);
    input := parse_input(content);
    score := 0;
    for 0..input.count-1 {
        opponent := input[it][0];
        outcome := input[it][1];
        score += outcome*3 + cast(int)PLAY[opponent][outcome] + 1;
    }
    print("Part 2: %: %\n", file_path, score);
}

main :: () {
    part_1("sample.txt");
    part_1("input.txt");
    part_2("sample.txt");
    part_2("input.txt");
}
