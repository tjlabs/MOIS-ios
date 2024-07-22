import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ScannedDeviceCountDataCell: UICollectionViewCell {
    static let identifier = "ScannedDeviceCountDataCell"
    
    let deviceCategoryLabel = PaddedLabel(padding: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)).then {
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.text = "Device Category"
        $0.textAlignment = .left
        $0.textColor = .black
//        $0.backgroundColor = .yellow
    }
    
    let fixedCountLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textAlignment = .center
        $0.textColor = .black
//        $0.backgroundColor = .green
    }

    let staticCountLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textAlignment = .center
        $0.textColor = .black
//        $0.backgroundColor = .green
    }
    
    let dynamicCountLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textAlignment = .center
        $0.textColor = .black
//        $0.backgroundColor = .red
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
        
        stackView.addArrangedSubview(deviceCategoryLabel)
        stackView.addArrangedSubview(fixedCountLabel)
        stackView.addArrangedSubview(staticCountLabel)
        stackView.addArrangedSubview(dynamicCountLabel)
        setupAppearance()
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview().inset(2)
        }
        
        fixedCountLabel.snp.makeConstraints { make in
            make.width.equalTo(60)
        }
        
        staticCountLabel.snp.makeConstraints { make in
            make.width.equalTo(60)
        }
        
        dynamicCountLabel.snp.makeConstraints { make in
            make.width.equalTo(80)
        }
    }
    
    private func setupAppearance() {
        stackView.layer.cornerRadius = 8
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = UIColor.lightGray.cgColor
        stackView.layer.masksToBounds = true
    }
    
    func configure(with data: DeviceCountData) {
        deviceCategoryLabel.text = data.category
        fixedCountLabel.text = "\(data.fixedCount)"
        staticCountLabel.text = "\(data.staticCount)"
        dynamicCountLabel.text = "\(data.dynamicCount)"
    }
}
