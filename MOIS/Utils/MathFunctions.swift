
import Foundation

func mean(of numbers: [Int]) -> Int {
    let sum = numbers.reduce(0, +)
    return Int(Double(sum) / Double(numbers.count))
}

func calVariance(buffer: [Int], bufferMean: Int) -> Double {
    if (buffer.count == 1) {
        return 0.0
    } else {
        var bufferSum: Double = 0
        
        for i in 0..<buffer.count {
            bufferSum += pow((Double(buffer[i]) - Double(bufferMean)), 2)
        }
        
        return bufferSum / Double(buffer.count - 1)
    }
}


func calStd(buffer: [Int], bufferMean: Int) -> Double {
    if (buffer.count == 1) {
        return 0.0
    } else {
        var bufferSum: Double = 0
        
        for i in 0..<buffer.count {
            bufferSum += pow((Double(buffer[i]) - Double(bufferMean)), 2)
        }
        
        return sqrt(bufferSum / Double(buffer.count - 1))
    }
}
