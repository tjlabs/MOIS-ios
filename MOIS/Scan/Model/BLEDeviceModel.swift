
import Foundation
import CoreBluetooth

enum DeviceType: String {
    case ELECTRONICS
    case SMART_PHONE
    case WEARABLE
    case UNKNOWN
}

struct BLEDevices {
    var Info: [String: BLEInfo]
}

struct BLEInfo {
    var pheripherl: CBPeripheral
    var category: String
    var type: DeviceType
    var RSSI: [Int]
    var scannedTime: [Int]
    var localName: String
    var manufacturer: String
    var serviceUUID: String
}
