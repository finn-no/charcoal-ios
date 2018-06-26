//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FilterViewControllerDelegate: AnyObject {
    func filterSelectionValueChanged(_ filterSelectionValue: FilterSelectionValue, forFilterWithFilterInfo filterInfo: FilterInfoType)
}

public final class FilterViewController<View: FilterView>: UIViewController {
    let filterInfo: FilterInfoType
    var delegate: FilterViewControllerDelegate?
    private(set) var filterSelectionValue: FilterSelectionValue?

    public required init?(filterInfo: FilterInfoType) {
        guard let filterView = View(filterInfo: filterInfo) else {
            return nil
        }

        self.filterInfo = filterInfo
        super.init(nibName: nil, bundle: nil)

        setup(with: filterView)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FilterViewController: FilterViewDelegate {
    public func filterView(filterView: FilterView, didUpdateFilterSelectionValue filterSelectionValue: FilterSelectionValue) {
        self.filterSelectionValue = filterSelectionValue
        delegate?.filterSelectionValueChanged(filterSelectionValue, forFilterWithFilterInfo: filterInfo)
    }
}

private extension FilterViewController {
    func setup(with filterView: UIView) {
        view.backgroundColor = .milk
        title = filterInfo.name
        filterView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(filterView)

        let safeTopAnchor: NSLayoutYAxisAnchor = {
            if #available(iOS 11.0, *) {
                return view.safeAreaLayoutGuide.topAnchor
            } else {
                return view.topAnchor
            }
        }()

        NSLayoutConstraint.activate([
            filterView.topAnchor.constraint(equalTo: safeTopAnchor, constant: 48),
            filterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
            filterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}
