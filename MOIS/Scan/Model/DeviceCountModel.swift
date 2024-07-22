
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
