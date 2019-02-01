//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public final class RangeFilterViewController: FilterViewController {

    // MARK: - Private attributes

    private let filterInfo: RangeFilterInfoType
    private var currentRangeValue: RangeValue?
    private lazy var swallowPanGesture: UIPanGestureRecognizer = {
        let gestureRecognizer = UIPanGestureRecognizer()
        gestureRecognizer.cancelsTouchesInView = true
        return gestureRecognizer
    }()

    lazy var rangeFilterView: RangeFilterView = {
        let view = RangeFilterView(filterInfo: filterInfo)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()

    // MARK: - Init

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(filterInfo: RangeFilterInfoType, dataSource: FilterDataSource, selectionDataSource: FilterSelectionDataSource, navigator: FilterNavigator) {
        self.filterInfo = filterInfo
        super.init(dataSource: dataSource, selectionDataSource: selectionDataSource, navigator: navigator)
        title = filterInfo.title
    }

    public required init?(string: String) {
        fatalError("init(string:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setSelectionValue(selectionDataSource.rangeValue(for: filterInfo))
    }
}

// MARK: - Private

private extension RangeFilterViewController {
    func setup() {
        view.addGestureRecognizer(swallowPanGesture)
        view.backgroundColor = .milk
        title = filterInfo.title

        view.addSubview(rangeFilterView)

        NSLayoutConstraint.activate([
            rangeFilterView.topAnchor.constraint(equalTo: view.topAnchor, constant: 48),
            rangeFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rangeFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rangeFilterView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
        ])
    }

    func setSelectionValue(_ range: RangeValue?) {
        currentRangeValue = range
        rangeFilterView.setHighValue(range?.highValue, animated: false)
        rangeFilterView.setLowValue(range?.lowValue, animated: false)
    }

    func updateSelectionDataSource() {
        if let rangeValue = currentRangeValue {
            selectionDataSource.setValue(rangeValue, for: filterInfo)
        } else {
            selectionDataSource.clearAll(for: filterInfo)
        }
        showApplyButton(true)
    }
}

// MARK: - RangeFilterViewDelegate

extension RangeFilterViewController: RangeFilterViewDelegate {
    public func rangeFilterView(_ rangeFilterView: RangeFilterView, didSetLowValue lowValue: Int?) {
        if lowValue != currentRangeValue?.lowValue {
            currentRangeValue = RangeValue.create(lowValue: lowValue, highValue: currentRangeValue?.highValue)
            updateSelectionDataSource()
        }
    }

    public func rangeFilterView(_ rangeFilterView: RangeFilterView, didSetHighValue highValue: Int?) {
        if highValue != currentRangeValue?.highValue {
            currentRangeValue = RangeValue.create(lowValue: currentRangeValue?.lowValue, highValue: highValue)
            updateSelectionDataSource()
        }
    }
}
