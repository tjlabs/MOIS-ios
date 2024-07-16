import UIKit

class MainViewController: UIViewController {
    private let categoryTitleList = [ "Scan", "Flow", "Knock" ]
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "MOIS"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private lazy var pagingTabBar = PagingTabBar(categoryTitleList: categoryTitleList)
    private lazy var pagingView = PagingView(categoryTitleList: categoryTitleList, pagingTabBar: pagingTabBar)
    
    let bleScanner = BLEScanner()
    let locationManager = LocationManager()
    
    var bleTimer: DispatchSourceTimer?
    let BLE_TIMER_INTERVAL: TimeInterval = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        bleScanner.startScan()
        startTimer()
    }
    
    func startTimer() {
        if (self.bleTimer == nil) {
            let queueBLE = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".bleTimer")
            self.bleTimer = DispatchSource.makeTimerSource(queue: queueBLE)
            self.bleTimer!.schedule(deadline: .now(), repeating: BLE_TIMER_INTERVAL)
            self.bleTimer!.setEventHandler(handler: self.bleTimerUpdate)
            self.bleTimer!.resume()
        }
    }
    
    func stopTimer() {
        self.bleTimer?.cancel()
        self.bleTimer = nil
    }
    
    @objc func bleTimerUpdate() {
        let BLE = bleScanner.getBLE()
        
        for (key, value) in BLE.Info {
            let rssiValue = mean(of: value.RSSI)
            print(getLocalTimeString() + " , (BLE Scan) : UUID = \(key) // company = \(value.manufacturer) // RSSI = \(rssiValue)")
        }
        print(getLocalTimeString() + " , (BLE Scan) : --------------------------------")
    }
}

private extension MainViewController {
    func setupLayout() {
        [
            titleLabel,
            pagingTabBar,
            pagingView
        ].forEach { view.addSubview($0) }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-30)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }
        
        pagingTabBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(pagingTabBar.cellHeight)
        }
        pagingView.snp.makeConstraints { make in
            make.top.equalTo(pagingTabBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
