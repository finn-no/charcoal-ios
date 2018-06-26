//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FilterViewControllerDelegate: AnyObject {
    func filterSelectionValueChanged(_ filterSelectionValue: FilterSelectionValue, forFilterWithFilterInfo filterInfo: FilterInfoType)
    func applyFilterButtonTapped(with filterSelectionValue: FilterSelectionValue?)
}

public final class FilterViewController<ChildViewController: FilterChildViewController>: UIViewController {
    private lazy var safeLayoutGuide: UILayoutGuide = {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide
        } else {
            let layoutGuide = UILayoutGuide()
            view.addLayoutGuide(layoutGuide)

            NSLayoutConstraint.activate([
                layoutGuide.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
                layoutGuide.leftAnchor.constraint(equalTo: view.leftAnchor),
                layoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                layoutGuide.rightAnchor.constraint(equalTo: view.rightAnchor),
            ])

            return layoutGuide
        }
    }()

    private lazy var applySelectionButton: FilterBottomButtonView = {
        let buttonView = FilterBottomButtonView()
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.delegate = self
        buttonView.buttonTitle = "Bruk"
        return buttonView
    }()

    let filterInfo: FilterInfoType
    let showsApplySelectionButton: Bool
    var delegate: FilterViewControllerDelegate?
    private(set) var filterSelectionValue: FilterSelectionValue?

    public required init?(filterInfo: FilterInfoType, showsApplySelectionButton: Bool = true) {
        guard var child = ChildViewController(filterInfo: filterInfo), let childView = child.controller.view else {
            return nil
        }
        self.filterInfo = filterInfo
        self.showsApplySelectionButton = showsApplySelectionButton
        super.init(nibName: nil, bundle: nil)

        child.filterSelectionDelegate = self
        addChildViewController(child.controller)
        setup(with: childView)
        child.controller.didMove(toParentViewController: self)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FilterViewController: FilterChildViewControllerDelegate {
    public func filterChildViewController(filterChildViewController: FilterChildViewController, didUpdateFilterSelectionValue filterSelectionValue: FilterSelectionValue) {
        self.filterSelectionValue = filterSelectionValue
        delegate?.filterSelectionValueChanged(filterSelectionValue, forFilterWithFilterInfo: filterInfo)
    }
}

extension FilterViewController: FilterBottomButtonViewDelegate {
    func filterBottomButtonView(_ filterBottomButtonView: FilterBottomButtonView, didTapButton button: UIButton) {
        delegate?.applyFilterButtonTapped(with: filterSelectionValue)
    }
}

private extension FilterViewController {
    func setup(with filterView: UIView) {
        view.backgroundColor = .milk
        title = filterInfo.name

        filterView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterView)

        let filterViewBottomAnchor = showsApplySelectionButton ? filterView.bottomAnchor.constraint(greaterThanOrEqualTo: applySelectionButton.topAnchor) : filterView.bottomAnchor.constraint(greaterThanOrEqualTo: safeLayoutGuide.bottomAnchor)

        NSLayoutConstraint.activate([
            filterView.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor),
            filterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterViewBottomAnchor,
        ])

        if showsApplySelectionButton {
            view.addSubview(applySelectionButton)

            NSLayoutConstraint.activate([
                applySelectionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                applySelectionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                applySelectionButton.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor),
            ])
        }
    }
}
