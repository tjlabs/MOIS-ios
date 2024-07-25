
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
    let pheripherl: CBPeripheral
    let category: String
    let type: DeviceType
    let RSSI: [Int]
    let scannedTime: [Int]
    let localName: String
    let manufacturer: String
    let serviceUUID: String
}