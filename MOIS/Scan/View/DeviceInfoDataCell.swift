import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class DeviceInfoDataCell: UICollectionViewCell {
    static let identifier = "DeviceInfoDataCell"
    
    let stateImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "blackCircle")
    }
    
//    let deviceCategoryLabel = UILabel().then {
//        $0.font = UIFont.boldSystemFont(ofSize: 14)
//        $0.text = "Device Category"
//        $0.textAlignment = .left
//        $0.textColor = .black
//    }
    
    let deviceCategoryLabel = PaddedLabel(padding: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)).then {
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.text = "Device Category"
        $0.textAlignment = .left
        $0.textColor = .black
    }

    
    let rssiValueLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textAlignment = .center
        $0.textColor = .black
    }
    
    let distanceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textAlignment = .center
        $0.textColor = .black
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(stackView)
        
        stackView.addArrangedSubview(stateImageView)
        stackView.addArrangedSubview(deviceCategoryLabel)
        stackView.addArrangedSubview(rssiValueLabel)
        stackView.addArrangedSubview(distanceLabel)
        setupAppearance()
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview().inset(5)
        }
            
        stateImageView.snp.makeConstraints { make in
            make.width.equalTo(50)
        }
        
        rssiValueLabel.snp.makeConstraints { make in
            make.width.equalTo(80)
        }
        
        distanceLabel.snp.makeConstraints { make in
            make.width.equalTo(80)
        }
    }
    
    private func setupAppearance() {
        stackView.layer.cornerRadius = 8
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = UIColor.lightGray.cgColor
        stackView.layer.masksToBounds = true
    }
    
    func configure(with data: DeviceScanData) {
        deviceCategoryLabel.text = data.category
        rssiValueLabel.text = "\(data.rssi) dBm"
//        distanceLabel.text = String(format: "%.1f m", data.distance)
        distanceLabel.text = "\(data.distance) m"
    }
}
