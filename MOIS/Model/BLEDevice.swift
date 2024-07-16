
import Foundation
import CoreBluetooth

struct BLEDevices {
    var Info: [String: BLEInfo]
}

struct BLEInfo {
    let pheripherl: CBPeripheral
    let type: String
    let RSSI: [Int]
    let scannedTime: [Int]
    let localName: String
    let manufacturer: String
    let serviceUUID: String
}
