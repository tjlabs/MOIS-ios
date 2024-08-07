
import Foundation
import UIKit

let FILTER_ORDER = ["Apple", "Google", "Samsung", "LG", "TJLABS", "Etc"]
//let FILTER_ORDER = ["Apple", "Google", "Samsung", "TJLABS", "LG", "Microsoft", "Sony", "Etc"]

// MARK: Filter Device
struct FilterDeviceInfo: Hashable {
    var opened = Bool()
    var title = String()
    var manufacuterers: [Manufacturer]
    var rssi: RSSI
    var distance: Distance
}

struct Manufacturer: Hashable {
    let name: String
    var isChecked: UISwitch
    
    init(name: String) {
        self.name = name
        self.isChecked = UISwitch(frame: CGRect())
        self.isChecked.onTintColor = .systemBlue
        self.isChecked.isOn = false
    }
}

struct RSSI: Hashable {
    let name: String
    var value: Float
    
    init() {
        self.name = "RSSI"
//        self.value = -84.31364
        self.value = -100
    }
}

struct Distance: Hashable {
    let name: String
    var value: Int
    
    init() {
        self.name = "Distance"
        self.value = 0
    }
}

// MARK: Filter State
struct FilterStateInfo: Hashable {
    var opened = Bool()
    var title = String()
    var state: [State]
}

struct State: Hashable {
    let name: String
    var type: DeviceState
    var isChecked: UISwitch
    
    init(name: String) {
        self.name = name
        if name == "Fixed" {
            self.type = .FIXED_STATE
        } else if name == "Static" {
            self.type = .STATIC_STATE
        } else {
            self.type = .DYNAMIC_STATE
        }
        self.isChecked = UISwitch(frame: CGRect())
        self.isChecked.onTintColor = .systemBlue
        self.isChecked.isOn = false
    }
}
