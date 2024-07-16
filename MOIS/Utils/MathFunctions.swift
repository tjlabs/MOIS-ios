
import Foundation

func mean(of numbers: [Int]) -> Int {
    let sum = numbers.reduce(0, +)
    return Int(Double(sum) / Double(numbers.count))
}
