//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FilterViewControllerDelegate: AnyObject {
    func filterSelectionValueChanged(_ filterSelectionValue: FilterSelectionValue, forFilterWithFilterInfo filterInfo: FilterInfoType)
    func applyFilterButtonTapped(with filterSelectionValue: FilterSelectionValue?, forFilterWithFilterInfo filterInfo: FilterInfoType)
}

public final class FilterViewController<ChildViewController: FilterContainerViewController>: UIViewController {
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
    let navigator: FilterNavigator
    let showsApplySelectionButton: Bool
    weak var delegate: FilterViewControllerDelegate?
    private(set) var filterSelectionValue: FilterSelectionValue?
    weak var filterContainerViewController: FilterContainerViewController?

    public required init?(filterInfo: FilterInfoType, navigator: FilterNavigator, showsApplySelectionButton: Bool) {
        guard let child = ChildViewController(filterInfo: filterInfo), let childView = child.controller.view else {
            return nil
        }
        self.filterInfo = filterInfo
        self.navigator = navigator
        self.showsApplySelectionButton = showsApplySelectionButton
        filterContainerViewController = child
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

public extension FilterViewController {
    func setSelectionValue(_ selectionValue: FilterSelectionValue) {
        filterContainerViewController?.setSelectionValue(selectionValue)
    }
}

private extension FilterViewController {
    func setup(with filterView: UIView) {
        view.backgroundColor = .milk
        title = filterInfo.name

        filterView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterView)

        if showsApplySelectionButton {
            view.addSubview(applySelectionButton)

            NSLayoutConstraint.activate([
                filterView.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor),
                filterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                filterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                filterView.bottomAnchor.constraint(greaterThanOrEqualTo: applySelectionButton.topAnchor),
                applySelectionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                applySelectionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                applySelectionButton.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                filterView.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor),
                filterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                filterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                filterView.bottomAnchor.constraint(greaterThanOrEqualTo: safeLayoutGuide.bottomAnchor),
            ])
        }
    }

    func canNavigate(to filterInfo: FilterInfoType, from filterContainerViewController: FilterContainerViewController) -> Bool {
        guard let multiLevelFilterInfo = filterInfo as? MultiLevelSelectionFilterInfoType else {
            return false
        }

        let shouldNavigateToSublevel = !multiLevelFilterInfo.filters.isEmpty

        return shouldNavigateToSublevel
    }
}

extension FilterViewController: FilterContainerViewControllerDelegate {
    public func filterContainerViewController(filterContainerViewController: FilterContainerViewController, navigateTo filterInfo: FilterInfoType) {
        if canNavigate(to: filterInfo, from: filterContainerViewController) {
            navigator.navigate(to: .subLevel(filterInfo: filterInfo, delegate: delegate))
        }
    }

    public func filterContainerViewController(filterContainerViewController: FilterContainerViewController, canNavigateTo filterInfo: FilterInfoType) -> Bool {
        return canNavigate(to: filterInfo, from: filterContainerViewController)
    }

    public func filterContainerViewController(filterContainerViewController: FilterContainerViewController, didUpdateFilterSelectionValue filterSelectionValue: FilterSelectionValue) {
        self.filterSelectionValue = filterSelectionValue
        delegate?.filterSelectionValueChanged(filterSelectionValue, forFilterWithFilterInfo: filterInfo)
    }
}

extension FilterViewController: FilterBottomButtonViewDelegate {
    func filterBottomButtonView(_ filterBottomButtonView: FilterBottomButtonView, didTapButton button: UIButton) {
        delegate?.applyFilterButtonTapped(with: filterSelectionValue, forFilterWithFilterInfo: filterInfo)
    }
}
