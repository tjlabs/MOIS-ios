import UIKit
import SnapKit

final class FilterDeviceManufacturerCell: UICollectionViewCell {
    static let identifier = "FilterDeviceManufacturerCell"
    
    let nameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .black
    }
    
    let switchControl = UISwitch().then {
        $0.onTintColor = .blue
    }
    var switchValueChanged: ((Bool) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(switchControl)
        
        nameLabel.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.leading.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        
        switchControl.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupActions() {
        switchControl.addTarget(self, action: #selector(switchValueChangedAction(_:)), for: .valueChanged)
    }
    
    @objc private func switchValueChangedAction(_ sender: UISwitch) {
        switchValueChanged?(sender.isOn)
    }
    
    func configure(with manufacturer: Manufacturer) {
        nameLabel.text = manufacturer.name
        switchControl.isOn = manufacturer.isChecked.isOn
        switchControl.onTintColor = manufacturer.isChecked.onTintColor
    }
}
