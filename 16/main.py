#!/usr/bin/env python3

def name_to_index(name):
    # return name
    return (name[1] - ord('A'))*26 + name[0] - ord('A')

def parse_valves(content):
    valves = {}
    for line in content.splitlines():
        if len(line) > 0:
            components = line.split(b"; ")
            node = components[0].split(b" has flow rate=")
            name = node[0].split(b"Valve ")[1];
            rate = int(node[1])
            neighbors = components[1].split(b", ")
            neighbors[0] = neighbors[0][-2:]
            valves[name_to_index(name)] = {
                "rate": rate,
                "neighbors": [name_to_index(n) for n in neighbors],
            }
    return valves

def distance_map(valves):
    def bfs(start):
        distances = {start: 0}
        wave = [start]
        while len(wave) > 0:
            new_wave = []
            for current in wave:
                for neighbor in valves[current]["neighbors"]:
                    if neighbor not in distances:
                        distances[neighbor] = distances[current] + 1
                        new_wave.append(neighbor)
            wave = new_wave
        return distances
    return {name: bfs(name) for name, valve in valves.items() if valve["rate"] > 0 or name == name_to_index(b"AA")}

def rate(valves, opened):
    result = 0
    for name, valve in valves.items():
        if name in opened:
            result += valve["rate"]
    return result

def part1(file_path):
    content = open(file_path, "rb").read()
    valves = parse_valves(content)
    distance = distance_map(valves)
    TIME_LIMIT = 30
    def bruteforce(here, opened, released = []):
        if len(released) >= TIME_LIMIT:
            return sum(released[0:TIME_LIMIT])

        r = rate(valves, opened)
        max_released = 0
        all_open = True
        for there in distance:
            if there not in opened:
                all_open = False
                d = distance[here][there]
                max_released = max(
                    max_released,
                    bruteforce(there, opened.union({there}), released + [r]*(d + 1))
                )
        if all_open:
            return bruteforce(here, opened, released + [r]*(TIME_LIMIT - len(released)))
        else:
            return max_released
    print("Part 1", file_path, bruteforce(name_to_index(b"AA"), {name_to_index(b"AA")}))

max_result = 0

def part2(file_path):
    content = open(file_path, "rb").read()
    valves = parse_valves(content)
    distance = distance_map(valves)
    start = name_to_index(b"AA")
    TIME_LIMIT = 26

    def bruteforce_of_bruteforce(here, outer_opened, outer_released = []):
        if len(outer_released) >= TIME_LIMIT:
            chain = outer_released[0:TIME_LIMIT]
            x = sum(chain)
            global max_result
            if x > max_result:
                max_result = x
                print(max_result, chain)
            return

        r = rate(valves, outer_opened)
        all_open = True
        for there in distance:
            if there not in outer_opened:
                all_open = False
                d = distance[here][there]
                bruteforce_of_bruteforce(there, outer_opened.union({there}), outer_released + [r]*(d + 1))

        def nested_bruteforce(here, inner_opened = set(), inner_released = []):
            if len(inner_released) >= TIME_LIMIT:
                chain = list(map(lambda x: x[0] + x[1], zip(inner_released, outer_released)))
                x = sum(chain)
                global max_result
                if x > max_result:
                    max_result = x
                    print(max_result, chain)
                return

            r = rate(valves, inner_opened)
            all_open = True
            for there in distance:
                if there not in inner_opened and there not in outer_opened:
                    all_open = False
                    d = distance[here][there]
                    nested_bruteforce(there, inner_opened.union({there}), inner_released + [r]*(d + 1))
            if all_open:
                nested_bruteforce(here, inner_opened, inner_released + [r]*(TIME_LIMIT - len(inner_released)))

        outer_released = outer_released + [r]*max(0, TIME_LIMIT - len(outer_released))
        nested_bruteforce(start)

    bruteforce_of_bruteforce(start, {start})

# part1("sample.txt")
# part1("input.txt")
# part2("sample.txt")
part2("input.txt")
