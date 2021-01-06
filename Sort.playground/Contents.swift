import Foundation



// MARK: - Algorithms

enum SortingAlgorithm
{
	// O(n*log(n)) average
	case merge
	case quick

	// О(n^2) average
	case insertion
	case selection
}



// MARK: - Array

extension Array
{
	func sorted(_ algorithm: SortingAlgorithm, shouldPreceede: @escaping (Element, Element) -> Bool) -> Self
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
			return mergeSortArray(self, shouldPreceede: shouldPreceede)

		case .quick:
			return quickSortArray(self, shouldPreceede: shouldPreceede)

		case .insertion:
			return insertionSortArray(self, shouldPreceede: shouldPreceede)

		case .selection:
			return selectionSortArray(self, shouldPreceede: shouldPreceede)
		}
	}

	mutating func sort(_ algorithm: SortingAlgorithm, shouldPreceede: @escaping (Element, Element) -> Bool)
	{
		self = sorted(algorithm, shouldPreceede: shouldPreceede)
	}
}



// MARK: - Array<Comparable>

extension Array where Element: Comparable
{
	func sorted(_ algorithm: SortingAlgorithm) -> Self
	{
		return sorted(algorithm, shouldPreceede: { $0 < $1 })
	}

	mutating func sort(_ algorithm: SortingAlgorithm)
	{
		self = sorted(algorithm, shouldPreceede: { $0 < $1 })
	}
}



// MARK: - Merge Sort Implementation

private func mergeSortArray<Element>(
	_ array: [Element],
	shouldPreceede: @escaping (Element, Element) -> Bool
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
		arr = mergePairs(arr, shouldPreceede: shouldPreceede)
	}

	return arr[0]
}



private func mergePairs<Element>(
	_ array: [[Element]],
	shouldPreceede: @escaping (Element, Element) -> Bool
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
						shouldPreceede: shouldPreceede
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
	shouldPreceede: (Element, Element) -> Bool
) -> [Element]
{
	var merged = [Element]()
	var lhs = lhs
	var rhs = rhs

	while !lhs.isEmpty && !rhs.isEmpty
	{
		merged.append(
			shouldPreceede(lhs[0], rhs[0])
				? lhs.removeFirst()
				: rhs.removeFirst()
		)
	}

	return merged + rhs + lhs
}



// MARK: - Quick Sort Implementation

private func quickSortArray<Element>(
	_ array: [Element],
	shouldPreceede: (Element, Element) -> Bool
) -> [Element]
{
	if array.count < 2
	{
		return array
	}

	var preceedingElements = [Element]()
	var followingElements = [Element]()

	let primaryKey = array.last!

	for i in 0..<(array.count - 1)
	{
		let secondaryKey = array[i]

		shouldPreceede(secondaryKey, primaryKey)
			? preceedingElements.append(secondaryKey)
			: followingElements.append(secondaryKey)
	}

	return quickSortArray(preceedingElements, shouldPreceede: shouldPreceede)
		+ [primaryKey]
		+ quickSortArray(followingElements, shouldPreceede: shouldPreceede)
}



// MARK: - Insertion Sort Implementation

private func insertionSortArray<Element>(
	_ array: [Element],
	shouldPreceede: (Element, Element) -> Bool
) -> [Element]
{
	var output = array

	for primaryIndex in 1..<output.count
	{
		let key = output[primaryIndex]
		var secondaryIndex = primaryIndex - 1

		while secondaryIndex >= 0,
			  shouldPreceede(key, output[secondaryIndex])
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
	shouldPreceede: (Element, Element) -> Bool
) -> [Element]
{
	var output = array

	for primaryIndex in 0..<output.count
	{
		var minIndex = primaryIndex

		for secondaryIndex in (primaryIndex + 1)..<output.count
		{
			if shouldPreceede(output[secondaryIndex], output[minIndex])
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


test(algorithm: .quick, arraySize: 10, numberOfTests: 30)
