
import Foundation
import UIKit

struct DeviceCountData {
    var category: String
    var staticCount: Int
    var dynamicCount: Int
    
    init(category: String, staticCount: Int, dynamicCount: Int) {
        self.category = category
        self.staticCount = staticCount
        self.dynamicCount = dynamicCount
    }
}
