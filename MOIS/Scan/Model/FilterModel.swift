
import Foundation
import UIKit

let FILTER_ORDER = ["Apple", "Google", "Samsung", "TJLABS", "Etc"]
//let FILTER_ORDER = ["Apple", "Google", "Samsung", "TJLABS", "LG", "Microsoft", "Sony", "Etc"]

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
