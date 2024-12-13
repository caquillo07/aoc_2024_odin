package main

import "core:fmt"
import "core:math"
import "core:os"
import "core:strconv"
import "core:strings"

read_input :: proc(file_name: string) -> [dynamic][10]int {
	fileData, err := os.read_entire_file_or_err(file_name)
	if err != nil {
		fmt.panicf("failed to open file: %v", err)
	}

	lines, linesErr := strings.split_lines(string(fileData))
	if linesErr != nil {
		fmt.panicf("failed to open file: %v", err)
	}

	delete(fileData)

	inputs := make([dynamic][10]int, 0, len(lines))
	for line in lines {
		defer free_all(context.temp_allocator)
		parts, err := strings.split(line, " ", context.temp_allocator)
		if err != nil {
			fmt.panicf("failed to split %q: %v", line, err)
		}

		// we know there is no 0s in the input, so we will use the 0 as a
		// sentinal value.
		report: [10]int
		for num, i in parts {
			if i >= 10 {
				fmt.panicf("we have more entries than space")
			}
			parsedNum, ok := strconv.parse_int(num, 10)
			if !ok {
				fmt.panicf("failed to convert %s to string", num)
			}

			report[i] = parsedNum
		}

		append(&inputs, report)
	}
	return inputs
}

is_report_valid :: proc(report: [10]int) -> bool {
	dir: int
	for entry, i in report {
		currDir := 1 if entry > 0 else -1
		if i == 0 {
			dir = currDir
			continue
		}

		if entry == 0 { // we hit the sentinal value
			break
		}

		if currDir != dir {
			return false
		}

		prevEntry := report[i-1]
		if prevEntry == entry {
			return false
		}

		diff := math.abs(math.abs(entry) - math.abs(prevEntry))
		if diff > 3 {
			return false
		}
	}
	return true
}

main :: proc() {
	reports := read_input("./input.txt")

	accumulator: int
	for report, i in reports {
		if i == 10 {
			break
		}
		safe: bool
		if safe = is_report_valid(report); safe {
			accumulator += 1
		}
		fmt.printfln("%v: %v", report, safe)
	}
	fmt.printfln("result %d", accumulator)
}
