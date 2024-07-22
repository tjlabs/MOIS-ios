import UIKit
import SnapKit

final class ScannedDeviceCountSectionHeaderView: UICollectionReusableView {
    static let identifier = "ScannedDeviceCountSectionHeaderView"
    
    let deviceCategoryLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 12)
        $0.text = "Device Category"
        $0.textAlignment = .center
        $0.textColor = .black
//        $0.backgroundColor = .yellow
    }
    
    let fixedCountLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 12)
        $0.text = "Fixed"
        $0.textAlignment = .center
        $0.textColor = .black
//        $0.backgroundColor = .green
    }
    
    let fixedImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "circleFixed")
//        $0.backgroundColor = .systemPink
    }
    
    let staticCountLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 12)
        $0.text = "Static"
        $0.textAlignment = .center
        $0.textColor = .black
//        $0.backgroundColor = .green
    }
    
    let staticImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "circleStatic")
//        $0.backgroundColor = .systemPink
    }
    
    let dynamicCountLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 12)
        $0.text = "Dynamic"
        $0.textAlignment = .center
        $0.textColor = .black
//        $0.backgroundColor = .red
    }
    
    let dynamicImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "circleDynamic")
//        $0.backgroundColor = .systemPink
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        return stackView
    }()
    
    private let stackViewFixedCount: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 2
        return stackView
    }()
    
    private let stackViewStaticCount: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 2
        return stackView
    }()
    
    private let stackViewDynamicCount: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 2
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
        stackViewFixedCount.addArrangedSubview(fixedCountLabel)
        stackViewFixedCount.addArrangedSubview(fixedImageView)
        stackViewStaticCount.addArrangedSubview(staticCountLabel)
        stackViewStaticCount.addArrangedSubview(staticImageView)
        stackViewDynamicCount.addArrangedSubview(dynamicCountLabel)
        stackViewDynamicCount.addArrangedSubview(dynamicImageView)
        
        stackView.addArrangedSubview(deviceCategoryLabel)
        stackView.addArrangedSubview(stackViewFixedCount)
        stackView.addArrangedSubview(stackViewStaticCount)
        stackView.addArrangedSubview(stackViewDynamicCount)
        
//        stackView.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview().inset(10)
//            make.top.bottom.equalToSuperview()
//        }
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview()
        }
        
        fixedImageView.snp.makeConstraints { make in
            make.width.equalTo(20)
        }
        
        stackViewFixedCount.snp.makeConstraints { make in
            make.width.equalTo(60)
        }
        
        staticImageView.snp.makeConstraints { make in
            make.width.equalTo(20)
        }
        
        stackViewStaticCount.snp.makeConstraints { make in
            make.width.equalTo(60)
        }
        
        dynamicImageView.snp.makeConstraints { make in
            make.width.equalTo(20)
        }
        
        stackViewDynamicCount.snp.makeConstraints { make in
            make.width.equalTo(80)
        }
    }
}
