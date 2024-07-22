import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class FilterDistanceCell: UICollectionViewCell {
    static let identifier = "FilterDistanceCell"
    
    let nameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .black
    }
    
    
    let distanceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textAlignment = .right
        $0.textColor = .black
    }
    
    let slider = UISlider().then {
        $0.minimumValue = 0
        $0.maximumValue = 100
        $0.isContinuous = true
        $0.isUserInteractionEnabled = true
    }
    
    
    private let disposeBag = DisposeBag()
    let sliderValueSubject = PublishSubject<Float>()
    var sliderValueChanged: ((Float) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        bindSlider()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(distanceLabel)
        contentView.addSubview(slider)
        
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        
        distanceLabel.snp.makeConstraints { make in
            make.width.equalTo(90)
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        
        slider.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(20)
            make.trailing.equalTo(distanceLabel.snp.leading).offset(-20)
            make.centerY.equalToSuperview()
        }
    }
    
    private func bindSlider() {
        slider.rx.value
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                
                self.distanceLabel.text = "\(distanceLabel) m"
                self.sliderValueSubject.onNext(value)
                self.sliderValueChanged?(value)
            })
            .disposed(by: disposeBag)
    }
    
    func configure(with distance: Distance){
        nameLabel.text = "Distance"
        distanceLabel.text = "\(distance.value) m"
        slider.value = Float(distance.value)
    }
}
