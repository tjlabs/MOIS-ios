import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class FilterDeviceRSSICell: UICollectionViewCell {
    static let identifier = "FilterDeviceRSSICell"
    
    let nameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .black
    }
    
    
    let distanceValueLabel = UILabel().then {
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
        contentView.addSubview(distanceValueLabel)
        contentView.addSubview(slider)
        
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        
        distanceValueLabel.snp.makeConstraints { make in
            make.width.equalTo(90)
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        
        slider.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(20)
            make.trailing.equalTo(distanceValueLabel.snp.leading).offset(-20)
            make.centerY.equalToSuperview()
        }
    }
    
    private func bindSlider() {
        slider.rx.value
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                let rssiValue = self.convertSliderToRSSIValue(value: value)
//                self.distanceValueLabel.text = "\(String(format: "%.1f", rssiValue)) dBm"
                let distanceValue = BLEManager.shared.convertForSlider(RSSI: rssiValue)
                print("Slider : distanceValue = \(distanceValue)")
                distanceValueLabel.text = "\(String(format: "%.1f", distanceValue)) m"
                self.sliderValueSubject.onNext(value)
                self.sliderValueChanged?(value)
            })
            .disposed(by: disposeBag)
    }
    
    func configure(with rssi: RSSI) {
        nameLabel.text = "Distance"
//        print("Init value : rssiValue = \(rssi.value)")
        let rssiValue = convertRSSItoSilderValue(value: rssi.value)
        let distanceValue = BLEManager.shared.convertForSlider(RSSI: rssi.value)
        distanceValueLabel.text = "\(String(format: "%.1f", distanceValue)) m"
        slider.value = rssiValue
    }
    
    public func convertRSSItoSilderValue(value: Float) -> Float {
        let newValue = abs(value)
        return Float(newValue)
    }
    
    public func convertSliderToRSSIValue(value: Float) -> Float {
        return -value
    }
}
