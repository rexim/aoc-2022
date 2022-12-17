#!/usr/bin/env python3

def part1(file_path):
    content = open(file_path, "rb").read()

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
                "opened": False,
            }

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

    distance = {name: bfs(name) for name, valve in valves.items() if valve["rate"] > 0 or name == b"AA"}

    TIME_LIMIT = 30

    def rate():
        result = 0
        for v in valves.values():
            if v["opened"]:
                result += v["rate"]
        return result

    def bruteforce(stack, minutes = 0, released = 0):
        # print(minutes, released, stack)
        assert minutes <= 30
        max_released = released
        here = stack[-1]
        if minutes < TIME_LIMIT:
            all_open = True
            r = rate()
            for there in distance:
                if not valves[there]["opened"]:
                    all_open = False
                    d = distance[here][there]
                    if minutes + d + 1 <= TIME_LIMIT:
                        valves[there]["opened"] = True;
                        max_released = max(max_released, bruteforce(stack + [there], minutes + d + 1, released + (d + 1)*r));
                        valves[there]["opened"] = False;
                    else:
                        max_released = max(max_released, released + (TIME_LIMIT - minutes)*r)
            if all_open:
                max_released = max(max_released, released + (TIME_LIMIT - minutes)*r)
        return max_released

    valves[b"AA"]["opened"] = True
    print("Part 1", file_path, bruteforce([b"AA"]))

part1("sample.txt")
part1("input.txt")
