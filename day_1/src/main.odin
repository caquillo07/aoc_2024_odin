package main

import "core:fmt"
import "core:os"
import "core:math"
import "core:strings"
import "core:strconv"
import "core:slice"

read_input :: proc(file_name: string) -> (leftNumbers: [dynamic]int, rightNumbers: [dynamic]int) {
	fileData, err := os.read_entire_file_or_err(file_name)
	if err != nil {
		fmt.panicf("failed to open file: %v", err)
	}
	lines, linesErr := strings.split_lines(string(fileData))
	if linesErr != nil {
		fmt.panicf("failed to open file: %v", err)
	}

	delete(fileData)

	leftNumbers = make([dynamic]int, 0, len(lines))
	rightNumbers = make([dynamic]int, 0, len(lines))
	for line in lines {
		defer free_all(context.temp_allocator)
		parts, err := strings.split(line, "   ", context.temp_allocator)
		if err != nil {
			fmt.panicf("failed to split %q: %v", line, err)
		}
		leftNum, leftOk := strconv.parse_int(parts[0], 10)
		if !leftOk {
			fmt.panicf("failed to convert %s to string", parts[0])
		}
		rightNum, rightOk := strconv.parse_int(parts[1], 10)
		if !rightOk {
			fmt.panicf("failed to convert %s to string", parts[0])
		}

		append(&leftNumbers, leftNum)
		append(&rightNumbers, rightNum)
	}
	slice.sort(leftNumbers[:])
	slice.sort(rightNumbers[:])
	return leftNumbers, rightNumbers
}

main :: proc() {
	leftNumbers, rightNumbers := read_input("./input.txt")
	defer delete(leftNumbers)
	defer delete(rightNumbers)


	rightListMap := make(map[int]int, len(rightNumbers))
	defer delete(rightListMap)

	accumulator: int
	for i := 0; i < len(leftNumbers); i += 1 {
		rightNum := rightNumbers[i]
		leftNum := leftNumbers[i]

		accumulator += math.abs(rightNum - leftNum)
		rightListMap[rightNumbers[i]] += 1
	}
	fmt.printfln("part 1 result: %d", accumulator)

	accumulator = 0
	for leftNum in leftNumbers {
		if count, ok := rightListMap[leftNum]; ok {
			accumulator += (leftNum * count)
		}
	}
	fmt.printfln("part 2 result: %d", accumulator)
}
