import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class DeviceInfoDataCell: UICollectionViewCell {
    static let identifier = "DeviceInfoDataCell"
    
    let nameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .black
    }
    
    
    let rssiValueLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textAlignment = .right
        $0.textColor = .black
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
        contentView.addSubview(rssiValueLabel)
        
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        
        rssiValueLabel.snp.makeConstraints { make in
            make.width.equalTo(90)
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(){
        nameLabel.text = "RSSI"
        rssiValueLabel.text = "-100 dBm"
    }
}
