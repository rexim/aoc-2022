#!/usr/bin/env python3

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
            valves[name] = {
                "rate": rate,
                "neighbors": neighbors,
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
    return {name: bfs(name) for name, valve in valves.items() if valve["rate"] > 0 or name == b"AA"}

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
    print("Part 1", file_path, bruteforce(b"AA", {b"AA"}))

part1("sample.txt")
part1("input.txt")
