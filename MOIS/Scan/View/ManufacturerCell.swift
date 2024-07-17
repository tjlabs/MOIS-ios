import UIKit
import SnapKit

final class ManufacturerCell: UICollectionViewCell {
    static let identifier = "ManufacturerCell"
    
    let nameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .black
    }
    
    let switchControl = UISwitch().then {
        $0.onTintColor = .blue
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(switchControl)
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        
        switchControl.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(with manufacturer: Manufacturer) {
        nameLabel.text = manufacturer.name
        switchControl.onTintColor = manufacturer.isChecked.onTintColor
        switchControl.isOn = manufacturer.isChecked.isOn
    }
}
