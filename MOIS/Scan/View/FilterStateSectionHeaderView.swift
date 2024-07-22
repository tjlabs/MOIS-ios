import UIKit
import SnapKit

final class FilterStateSectionHeaderView: UICollectionReusableView {
    static let identifier = "FilterStateSectionHeaderView"
    
    let titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 18)
        $0.textColor = .black
    }
    
    let toggleImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "closeInfo_toggle")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(titleLabel)
        addSubview(toggleImageView)

        titleLabel.snp.makeConstraints { make in

            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        toggleImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }
    
    func configure(isExpanded: Bool) {
        if isExpanded {
            backgroundColor = .systemGray5
            titleLabel.textColor = .black
            toggleImageView.image = UIImage(named: "showInfo_toggle")
        } else {
            backgroundColor = .clear
            titleLabel.textColor = .black
            toggleImageView.image = UIImage(named: "closeInfo_toggle")
        }
    }
}
