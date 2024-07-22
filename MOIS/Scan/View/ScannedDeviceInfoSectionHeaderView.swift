import UIKit
import SnapKit

final class ScannedDeviceInfoSectionHeaderView: UICollectionReusableView {
    static let identifier = "ScannedDeviceInfoSectionHeaderView"
    
    let stateLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 12)
        $0.text = "State"
        $0.textAlignment = .center
        $0.textColor = .black
//        $0.backgroundColor = .red
    }
    
    let deviceCategoryLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 12)
        $0.text = "Device Category"
        $0.textAlignment = .center
        $0.textColor = .black
//        $0.backgroundColor = .green
    }
    
    let rssiLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 12)
        $0.text = "RSSI"
        $0.textAlignment = .center
        $0.textColor = .black
//        $0.backgroundColor = .blue
    }
    
    let distanceLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 12)
        $0.text = "Distacne"
        $0.textAlignment = .center
        $0.textColor = .black
//        $0.backgroundColor = .yellow
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
        stackView.addArrangedSubview(stateLabel)
        stackView.addArrangedSubview(deviceCategoryLabel)
        stackView.addArrangedSubview(rssiLabel)
        stackView.addArrangedSubview(distanceLabel)
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview()
        }
        
        stateLabel.snp.makeConstraints { make in
            make.width.equalTo(50)
        }
        
        rssiLabel.snp.makeConstraints { make in
            make.width.equalTo(80)
        }
        
        distanceLabel.snp.makeConstraints { make in
            make.width.equalTo(80)
        }
    }
}
