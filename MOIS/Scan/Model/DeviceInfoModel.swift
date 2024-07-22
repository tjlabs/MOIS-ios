
import Foundation
import UIKit

enum DeviceState: String {
    case FIXED_STATE
    case STATIC_STATE
    case DYNAMIC_STATE
}

struct DeviceScanData {
    var state: DeviceState
    var category: String
    var rssi: Int
    var distance: Int
    
    init(state: DeviceState, category: String, rssi: Int, distance: Int) {
        self.state = state
        self.category = category
        self.rssi = rssi
        self.distance = distance
    }
}
