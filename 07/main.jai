#import "Basic";
#import "File";
#import "String";

INode :: struct {
    type : enum { FILE; DIRECTORY; };
    name: string;
    parent: *INode;
    size: int;
    children: [..]*INode;
}

find_child :: (using node : *INode, child_name: string) -> *INode {
    for children if it.name == child_name return it;
    return null;
}

print_tree :: (using inode: *INode, level: int = 0) {
    for 0..level-1 print("  ");
    if type == .DIRECTORY && !ends_with(name, "/") {
        print("%/ (%)\n", name, size);
    } else {
        print("% (%)\n", name, size);
    }
    if type == .DIRECTORY for children print_tree(it, level + 1);
}

compute_dir_sizes :: (using inode: *INode) -> int {
    if type == .DIRECTORY {
        size = 0;
        for children size += compute_dir_sizes(it);
    }

    return size;
}

find_all_dirs_with_at_most_size :: (using inode: *INode, upper_size: int, dirs: *[..]*INode) {
    if type == .DIRECTORY && size <= upper_size then array_add(dirs, inode);
    for children find_all_dirs_with_at_most_size(it, upper_size, dirs);
}

find_smallest_dir_that_is_bigger_or_equal_to :: (using root: *INode, bottom_size: int, dir: **INode) {
    if type != .DIRECTORY return;
    if size >= bottom_size && (<<dir == null || (<<dir).size > size) then <<dir = root;
    for children find_smallest_dir_that_is_bigger_or_equal_to(it, bottom_size, dir);
}

remove_prefix :: (s: string, prefix: string) -> string {
    n := prefix.count;
    if n > s.count then n = s.count;
    return slice(s, n, s.count - n);
}

main :: () {
    file_path :: "input.txt";
    content, ok := read_entire_file(file_path);
    assert(ok);
    found: bool;
    left: string;
    right := content;
    line_count := 1;
    root : *INode = null;
    current_directory : *INode = null;
    while right.count > 0 {
        found, left, right = split_from_left(right, #char "\n");
        command_prefix :: "$ ";
        cd_prefix :: "cd ";
        ls_prefix :: "ls";
        if starts_with(left, command_prefix) {
            cmd := remove_prefix(left, command_prefix);
            if starts_with(cmd, cd_prefix) {
                name := remove_prefix(cmd, cd_prefix);
                print("%:%: Change directory to %\n", file_path, line_count, name);
                if (name == "..") {
                    assert(current_directory != null);
                    assert(current_directory.parent != null);
                    current_directory = current_directory.parent;
                } else {
                    if current_directory == null {
                        current_directory = New(INode);
                        current_directory.type = .DIRECTORY;
                        current_directory.name = name;
                        root = current_directory;
                    } else {
                        child := find_child(current_directory, name);
                        assert(child != null);
                        assert(child.type == .DIRECTORY);
                        current_directory = child;
                    }
                }
            } else if starts_with(cmd, ls_prefix) {
                assert(current_directory != null);
                print("%:%: List files\n", file_path, line_count);
            } else {
                assert(false, "unreachable");
            }
        } else {
            assert(current_directory != null);
            found, type_or_size, name := split_from_left(left, #char " ");
            if type_or_size == "dir" {
                child := find_child(current_directory, name);
                if child == null {
                    child = New(INode);
                    child.type = .DIRECTORY;
                    child.name = name;
                    child.parent = current_directory;
                    array_add(*current_directory.children, child);
                }
                assert(child.type == .DIRECTORY);
            } else {
                size := string_to_int(type_or_size);
                child := find_child(current_directory, name);
                if child == null {
                    child = New(INode);
                    child.type = .FILE;
                    child.name = name;
                    child.size = size;
                    child.parent = current_directory;
                    array_add(*current_directory.children, child);
                }
                assert(child.type == .FILE);
                assert(child.size == size);
            }
            print("%:%: type or size: %, name: %\n", file_path, line_count, type_or_size, name);
        }
        line_count += 1;
    }
    compute_dir_sizes(root);
    print("------------------------------\n");
    print_tree(root);
    print("------------------------------\n");
    dirs : [..]*INode;
    find_all_dirs_with_at_most_size(root, 100_000, *dirs);
    answer := 0;
    for dirs {
        print("%/ (%)\n", it.name, it.size);
        answer += it.size;
    }
    print("Part 1: %: %\n", file_path, answer);
    print("------------------------------\n");
    total_size :: 70_000_000;
    required_free_space :: 30_000_000;
    actual_free_space := total_size - root.size;
    assert(required_free_space >= actual_free_space);
    need_to_free_up := required_free_space - actual_free_space;
    print("Need to free up: %\n", need_to_free_up);
    dir : *INode = null;
    find_smallest_dir_that_is_bigger_or_equal_to(root, need_to_free_up, *dir);
    assert(dir != null);
    print("Part 2: %: %\n", file_path, dir.size);
}
