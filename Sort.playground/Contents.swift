// None of this sorting algorithms is recomended to be used in production code.
// Default sort implementation is much more effective and well tested.
// The sole purpose of this code is educational.

import Foundation



// MARK: - Callback Type

typealias ShouldPrecede<Element> = (Element, Element) -> Bool



// MARK: - Algorithms

enum SortingAlgorithm
{
	// O(n*log(n)) average
	case merge
	case quick
	case heap

	// О(n^2) average
	case insertion
	case selection
}



// MARK: - Array

extension Array
{
	func sorted(
		_ algorithm: SortingAlgorithm,
		shouldPrecede: @escaping ShouldPrecede<Element>
	) -> Self
	{
		// handle trivial cases
		if count <= 1
		{
			return self
		}

		// sort
		switch algorithm
		{
		case .merge:
			return mergeSortArray(self, shouldPrecede: shouldPrecede)

		case .quick:
			return quickSortArray(self, shouldPrecede: shouldPrecede)

		case .heap:
			return heapSortArray(self, shouldPrecede: shouldPrecede)

		case .insertion:
			return insertionSortArray(self, shouldPrecede: shouldPrecede)

		case .selection:
			return selectionSortArray(self, shouldPrecede: shouldPrecede)
		}
	}

	mutating func sort(
		_ algorithm: SortingAlgorithm,
		shouldPrecede: @escaping ShouldPrecede<Element>
	)
	{
		self = sorted(algorithm, shouldPrecede: shouldPrecede)
	}
}



// MARK: - Array<Comparable>

extension Array where Element: Comparable
{
	func sorted(_ algorithm: SortingAlgorithm) -> Self
	{
		return sorted(algorithm, shouldPrecede: { $0 < $1 })
	}

	mutating func sort(_ algorithm: SortingAlgorithm)
	{
		self = sorted(algorithm, shouldPrecede: { $0 < $1 })
	}
}



// MARK: - Merge Sort Implementation

private func mergeSortArray<Element>(
	_ array: [Element],
	shouldPrecede: @escaping ShouldPrecede<Element>
) -> [Element]
{
	// slit array in one-element subarrays
	var arr = [[Element]]()

	for element in array
	{
		arr.append([element])
	}

	// merge
	while arr.count > 1
	{
		arr = mergePairs(arr, shouldPrecede: shouldPrecede)
	}

	return arr[0]
}



private func mergePairs<Element>(
	_ array: [[Element]],
	shouldPrecede: @escaping ShouldPrecede<Element>
) -> [[Element]]
{
	var result = [[Element]]()

	for i in 0..<array.count
	{
		if i % 2 == 0
		{
			if (i + 1) <= (array.count - 1)
			{
				result.append(
					merge(
						array[i],
						array[i + 1],
						shouldPrecede: shouldPrecede
					)
				)
			}
			else
			{
				result.append(array[i])
			}
		}
	}

	return result
}


private func merge<Element>(
	_ lhs: [Element],
	_ rhs: [Element],
	shouldPrecede: ShouldPrecede<Element>
) -> [Element]
{
	var merged = [Element]()
	var lhs = lhs
	var rhs = rhs

	while !lhs.isEmpty && !rhs.isEmpty
	{
		merged.append(
			shouldPrecede(lhs[0], rhs[0])
				? lhs.removeFirst()
				: rhs.removeFirst()
		)
	}

	return merged + rhs + lhs
}



// MARK: - Quick Sort Implementation

private let useDefaultQuickSortImplementation = true

private func quickSortArray<Element>(
	_ array: [Element],
	shouldPrecede: ShouldPrecede<Element>
) -> [Element]
{
	if useDefaultQuickSortImplementation
	{
		var output = array

		quickSortArrayDefault(
			&output,
			lowIndex: 0,
			highIndex: array.count - 1,
			shouldPrecede: shouldPrecede
		)

		return output
	}
	else
	{
		return quickSortArraySimple(
			array,
			shouldPrecede: shouldPrecede
		)
	}
}



// Has extra impact on memory due to intermediate arrays allocations
// The algorithm seems clearer though

private func quickSortArraySimple<Element>(
	_ array: [Element],
	shouldPrecede: ShouldPrecede<Element>
) -> [Element]
{
	if array.count < 2
	{
		return array
	}

	var precedingElements = [Element]()
	var followingElements = [Element]()

	let primaryKey = array.last!

	for i in 0..<(array.count - 1)
	{
		let secondaryKey = array[i]

		shouldPrecede(secondaryKey, primaryKey)
			? precedingElements.append(secondaryKey)
			: followingElements.append(secondaryKey)
	}

	return quickSortArray(precedingElements, shouldPrecede: shouldPrecede)
		+ [primaryKey]
		+ quickSortArray(followingElements, shouldPrecede: shouldPrecede)
}



// Memory effective

private func quickSortArrayDefault<Element>(
	_ array: inout [Element],
	lowIndex: Int,
	highIndex: Int,
	shouldPrecede: ShouldPrecede<Element>
)
{
	if lowIndex > highIndex
	{
		return
	}

	let primaryKey = array[highIndex]

	var partitionIndex = highIndex
	var i = lowIndex

	while (i != partitionIndex)
	{
		let secondaryKey = array[i]

		if shouldPrecede(secondaryKey, primaryKey)
		{
			i += 1
		}
		else
		{
			let secondaryKey = array.remove(at: i)
			array.insert(secondaryKey, at: partitionIndex)

			partitionIndex -= 1
		}
	}

	quickSortArrayDefault(
		&array,
		lowIndex: lowIndex,
		highIndex: partitionIndex - 1,
		shouldPrecede: shouldPrecede
	)

	quickSortArrayDefault(
		&array,
		lowIndex: partitionIndex + 1,
		highIndex: highIndex,
		shouldPrecede: shouldPrecede
	)
}



// MARK: - Heap Sort Implementations

private func heapSortArray<Element>(
	_ array: [Element],
	shouldPrecede: ShouldPrecede<Element>
) -> [Element]
{
	var output = array

	buildMaxHeap(&output, shouldPrecede: shouldPrecede)

	for index in stride(from: array.count - 1, to: -1, by: -1)
	{
		swap(0, index, in: &output)

		siftDown(
			&output,
			index: 0,
			heapSize: index,
			shouldPrecede: shouldPrecede
		)
	}

	return output
}



// Test Max Heap

private func isMaxHeap<Element>(
	_ array: [Element],
	heapSize: Int,
	shouldPrecede: ShouldPrecede<Element>
) -> Bool
{
	for root in 0..<heapSize
	{
		let left = 2 * root + 1
		let right = 2 * root + 2

		if left < heapSize, shouldPrecede(array[root], array[left])
		{
			return false
		}

		if right < heapSize, shouldPrecede(array[root], array[right])
		{
			return false
		}
	}

	return true
}



private func buildMaxHeap<Element>(
	_ array: inout [Element],
	shouldPrecede: ShouldPrecede<Element>
)
{
	for index in stride(from: array.count / 2 - 1, to: -1, by: -1)
	{
		siftDown(
			&array,
			index: index,
			heapSize: array.count,
			shouldPrecede: shouldPrecede
		)
	}
}



private func siftDown<Element>(
	_ array: inout [Element],
	index: Int,
	heapSize: Int,
	shouldPrecede: ShouldPrecede<Element>
)
{
	var root = index
	let left = 2 * root + 1
	let right = 2 * root + 2

	if left < heapSize, shouldPrecede(array[root], array[left])
	{
		root = left
	}

	if right < heapSize, shouldPrecede(array[root], array[right])
	{
		root = right
	}

	if root != index
	{
		swap(index, root, in: &array)
		siftDown(&array, index: root, heapSize: heapSize, shouldPrecede: shouldPrecede)
	}
}



// MARK: - Insertion Sort Implementation

private func insertionSortArray<Element>(
	_ array: [Element],
	shouldPrecede: ShouldPrecede<Element>
) -> [Element]
{
	var output = array

	for primaryIndex in 1..<output.count
	{
		let key = output[primaryIndex]
		var secondaryIndex = primaryIndex - 1

		while secondaryIndex >= 0,
			  shouldPrecede(key, output[secondaryIndex])
		{
			output[secondaryIndex + 1] = output[secondaryIndex]
			secondaryIndex -= 1
		}

		output[secondaryIndex + 1] = key
	}

	return output
}



// MARK: - Selection Sort Implementation

private func selectionSortArray<Element>(
	_ array: [Element],
	shouldPrecede: ShouldPrecede<Element>
) -> [Element]
{
	var output = array

	for primaryIndex in 0..<output.count
	{
		var minIndex = primaryIndex

		for secondaryIndex in (primaryIndex + 1)..<output.count
		{
			if shouldPrecede(output[secondaryIndex], output[minIndex])
			{
				minIndex = secondaryIndex
			}
		}

		swap(minIndex, primaryIndex, in: &output)
	}

	return output
}



private func swap<Element>(
	_ firstIndex: Int,
	_ secondIndex: Int,
	in array: inout [Element]
)
{
	if firstIndex == secondIndex
	{
		return
	}

	let temp = array[secondIndex]
	array[secondIndex] = array[firstIndex]
	array[firstIndex] = temp
}



// MARK: - Test

func test(
	algorithm: SortingAlgorithm,
	arraySize: Int,
	numberOfTests: Int
)
{
	var sortingTime = Double()
	var systemSortingTime = Double()

	for _ in 0..<numberOfTests
	{
		let array = (0..<arraySize)
			.map { _ in return Int.random(in: -10_000...10_000) }

		let start = CFAbsoluteTimeGetCurrent()
		let sortedArray = array.sorted(algorithm)
		sortingTime += CFAbsoluteTimeGetCurrent() - start

		let sysemStart = CFAbsoluteTimeGetCurrent()
		let systemSortedArray = array.sorted(by: { $0 < $1 })
		systemSortingTime += CFAbsoluteTimeGetCurrent() - sysemStart

		if sortedArray != systemSortedArray
		{
			print("Something's wrong!!!")
			print("array", array)
			print("sortedArray", sortedArray)
			print("systemSortedArray", systemSortedArray)
		}
	}

	let averageSortingTime = sortingTime / Double(numberOfTests)
	let averageSystemSortingTime = systemSortingTime / Double(numberOfTests)

	print("averageSortingTime", averageSortingTime)
	print("averageSystemSortingTime", averageSystemSortingTime)
}


test(algorithm: .heap, arraySize: 100, numberOfTests: 10)
