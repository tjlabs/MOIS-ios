
import Foundation
import UIKit

struct DeviceCountData {
    var category: String
    var fixedCount: Int
    var staticCount: Int
    var dynamicCount: Int
    
    init(category: String, fixedCount: Int, staticCount: Int, dynamicCount: Int) {
        self.category = category
        self.fixedCount = fixedCount
        self.staticCount = staticCount
        self.dynamicCount = dynamicCount
    }
}

//struct DeviceCountDataBuffer {
//    var category: String
//    var timeBuffer: [Int]
//    var fixedCount: [Int]
//    var staticCount: [Int]
//    var dynamicCount: [Int]
//    
//    init(category: String, timeBuffer: [Int], fixedCount: [Int], staticCount: [Int], dynamicCount: [Int]) {
//        self.timeBuffer = timeBuffer
//        self.category = category
//        self.fixedCount = fixedCount
//        self.staticCount = staticCount
//        self.dynamicCount = dynamicCount
//    }
//}

struct DeviceCountBuffer {
    var Info: [String: CountInfo]
}

struct CountInfo {
    var timeBuffer: [Int]
    var fixedCount: [Int]
    var staticCount: [Int]
    var dynamicCount: [Int]
}
