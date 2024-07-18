import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class FilterRSSICell: UICollectionViewCell {
    static let identifier = "FilterRSSICell"
    
    let nameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .black
    }
    
    
    let rssiValueLabel = UILabel().then {
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
        contentView.addSubview(rssiValueLabel)
        contentView.addSubview(slider)
        
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        
        rssiValueLabel.snp.makeConstraints { make in
            make.width.equalTo(90)
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        
        slider.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(20)
            make.trailing.equalTo(rssiValueLabel.snp.leading).offset(-20)
            make.centerY.equalToSuperview()
        }
    }
    
    private func bindSlider() {
        slider.rx.value
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                let rssiValue = self.convertSliderToRSSIValue(value: value)
                
                self.rssiValueLabel.text = "\(String(format: "%.1f", rssiValue)) dBm"
                self.sliderValueSubject.onNext(value)
            })
            .disposed(by: disposeBag)
    }
    
    func configure(with rssi: RSSI){
        nameLabel.text = "RSSI"
        let rssiValue = convertRSSItoSilderValue(value: rssi.value)
        rssiValueLabel.text = "\(String(format: "%.1f", rssi.value)) dBm"
        slider.value = rssiValue
    }
    
    private func convertRSSItoSilderValue(value: Float) -> Float {
        let newValue = value + 100
        return Float(newValue)
    }
    
    private func convertSliderToRSSIValue(value: Float) -> Float {
        return value - 100
    }
}
