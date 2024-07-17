import UIKit
import SnapKit

class FilterCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "FilterCollectionViewCell"
    
    // MARK: - Property
    let contentLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }
    
//    func setupView() {
//        setupLayout()
//    }
    
    func setupView(title: String) {
        setupLayout()
        contentLabel.text = title
    }
}

private extension FilterCollectionViewCell {
    func setupLayout() {
        addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalTo(20)
        }
    }
}
