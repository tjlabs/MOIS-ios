import UIKit
import SnapKit

final class DeviceCountSectionHeaderView: UICollectionReusableView {
    static let identifier = "DeviceCountSectionHeaderView"
    
    let deviceCategoryLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.text = "Device Category"
        $0.textAlignment = .center
        $0.textColor = .black
        $0.backgroundColor = .yellow
    }
    
    let staticCountLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.text = "Static Count"
        $0.textAlignment = .center
        $0.textColor = .black
        $0.backgroundColor = .green
    }
    
    let staticImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "blackCircle")
        $0.backgroundColor = .systemPink
    }
    
    let dynamicCountLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.text = "Dynamic Count"
        $0.textAlignment = .center
        $0.textColor = .black
        $0.backgroundColor = .red
    }
    
    let dynamicImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "blackCircle")
        $0.backgroundColor = .systemPink
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        return stackView
    }()
    
    private let stackViewStaticCount: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 5
        return stackView
    }()
    
    private let stackViewDynamicCount: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 5
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
        stackViewStaticCount.addArrangedSubview(staticCountLabel)
        stackViewStaticCount.addArrangedSubview(staticImageView)
        stackViewDynamicCount.addArrangedSubview(dynamicCountLabel)
        stackViewDynamicCount.addArrangedSubview(dynamicImageView)
        
        stackView.addArrangedSubview(deviceCategoryLabel)
        stackView.addArrangedSubview(stackViewStaticCount)
        stackView.addArrangedSubview(stackViewDynamicCount)
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview()
        }
    }
}
