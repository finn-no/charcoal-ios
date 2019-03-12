//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

final class RangeFilterViewController: FilterViewController {
    private enum InputMethod {
        case slider
        case keyboard
    }

    var eventLogger: EventLogging?

    // MARK: - Private properties

    private let lowValueFilter: Filter
    private let highValueFilter: Filter
    private let filterConfig: RangeFilterConfiguration
    private var lastInputMethod: InputMethod?

    private lazy var rangeFilterView: RangeFilterView = {
        let view = RangeFilterView(filterConfig: filterConfig)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()

    // MARK: - Init

    init(title: String, lowValueFilter: Filter, highValueFilter: Filter,
         filterConfig: RangeFilterConfiguration, selectionStore: FilterSelectionStore) {
        self.lowValueFilter = lowValueFilter
        self.highValueFilter = highValueFilter
        self.filterConfig = filterConfig
        super.init(title: title, selectionStore: selectionStore)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let lastInputMethod = lastInputMethod {
            switch lastInputMethod {
            case .slider:
                eventLogger?.log(event: .rangeSliderUsed)
            case .keyboard:
                eventLogger?.log(event: .rangeKeyboardUsed)
            }
        }
    }
}

// MARK: - RangeFilterViewDelegate

extension RangeFilterViewController: RangeFilterViewDelegate {
    func rangeFilterView(_ rangeFilterView: RangeFilterView, didSetLowValue lowValue: Int?, fromSlider: Bool) {
        setValue(lowValue, forSubfilter: lowValueFilter)
        lastInputMethod = fromSlider ? .slider : .keyboard
    }

    func rangeFilterView(_ rangeFilterView: RangeFilterView, didSetHighValue highValue: Int?, fromSlider: Bool) {
        setValue(highValue, forSubfilter: highValueFilter)
        lastInputMethod = fromSlider ? .slider : .keyboard
    }

    private func setValue(_ value: Int?, forSubfilter subfilter: Filter) {
        selectionStore.setValue(value, for: subfilter)
        delegate?.filterViewController(self, didSelectFilter: subfilter)
        showBottomButton(true, animated: true)
    }
}

private extension RangeFilterViewController {
    func setup() {
        bottomButton.buttonTitle = "apply_button_title".localized()

        let lowValue: Int? = selectionStore.value(for: lowValueFilter)
        rangeFilterView.setLowValue(lowValue, animated: false)

        let highValue: Int? = selectionStore.value(for: highValueFilter)
        rangeFilterView.setHighValue(highValue, animated: false)

        view.addSubview(rangeFilterView)

        NSLayoutConstraint.activate([
            rangeFilterView.topAnchor.constraint(equalTo: view.topAnchor, constant: 48),
            rangeFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rangeFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rangeFilterView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
        ])
    }
}
