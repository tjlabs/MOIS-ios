
import Foundation
import UIKit

struct FilterInfo: Hashable {
    var opened = Bool()
    var title = String()
    var manufacuterers: [Manufacturer]
    var rssi: RSSI
}

struct Manufacturer: Hashable {
    let name: String
    var isChecked: UISwitch
    
    init(name: String) {
        self.name = name
        self.isChecked = UISwitch(frame: CGRect())
        self.isChecked.onTintColor = .systemBlue
        self.isChecked.isOn = true
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
