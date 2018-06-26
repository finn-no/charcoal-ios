//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FilterViewControllerDelegate: AnyObject {
    func filterSelectionValueChanged(_ filterSelectionValue: FilterSelectionValue, forFilterWithFilterInfo filterInfo: FilterInfoType)
    func applyFilterButtonTapped(with filterSelectionValue: FilterSelectionValue?)
}

public final class FilterViewController<ChildViewController: FilterViewContainer>: UIViewController {
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

    private lazy var showResultsButtonView: FilterBottomButtonView = {
        let buttonView = FilterBottomButtonView()
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.delegate = self
        buttonView.buttonTitle = "Bruk"
        return buttonView
    }()

    let filterInfo: FilterInfoType
    var delegate: FilterViewControllerDelegate?
    private(set) var filterSelectionValue: FilterSelectionValue?

    public required init?(filterInfo: FilterInfoType) {
        guard let child = ChildViewController(filterInfo: filterInfo), let childView = child.view else {
            return nil
        }

        self.filterInfo = filterInfo
        super.init(nibName: nil, bundle: nil)

        child.delegate = self
        addChildViewController(child)
        setup(with: childView)
        child.didMove(toParentViewController: self)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FilterViewController: FilterViewContainerDelegate {
    public func filterViewContainer(filterViewContainer: FilterViewContainer, didUpdateFilterSelectionValue filterSelectionValue: FilterSelectionValue) {
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
        view.addSubview(showResultsButtonView)

        NSLayoutConstraint.activate([
            filterView.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor, constant: 48),
            filterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterView.bottomAnchor.constraint(greaterThanOrEqualTo: showResultsButtonView.topAnchor),
            showResultsButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            showResultsButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            showResultsButtonView.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor),
        ])
    }
}
