
import Foundation
import UIKit

struct FilterInfo: Hashable {
    var opened = Bool()
    var title = String()
    var manufacuterers: [Manufacturer]
}

struct Manufacturer: Hashable {
    let name: String
    let isChecked: UISwitch
    
    init(name: String) {
        self.name = name
        self.isChecked = UISwitch(frame: CGRect())
        self.isChecked.onTintColor = .systemBlue
        self.isChecked.isOn = true
    }
}
