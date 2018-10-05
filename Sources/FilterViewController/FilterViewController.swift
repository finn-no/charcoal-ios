//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FilterViewControllerDelegate: AnyObject {
    func filterSelectionValueChanged(_ filterSelectionValue: FilterSelectionValue?, forFilterWithFilterInfo filterInfo: FilterInfoType)
    func applyFilterButtonTapped()
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
                layoutGuide.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor),
                layoutGuide.rightAnchor.constraint(equalTo: view.rightAnchor),
            ])

            return layoutGuide
        }
    }()

    private lazy var applySelectionButton: FilterBottomButtonView = { // TODO: change name, it is not really `apply` since we update as soon as values change, `done` is probably better
        let buttonView = FilterBottomButtonView()
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.delegate = self
        buttonView.buttonTitle = "Bruk"
        return buttonView
    }()

    let filterInfo: FilterInfoType
    let selectionDataSource: FilterSelectionDataSource
    let navigator: FilterNavigator
    let showsApplySelectionButton: Bool
    let filterContainerViewController: FilterContainerViewController
    weak var delegate: FilterViewControllerDelegate?

    public required init?(filterInfo: FilterInfoType, selectionDataSource: FilterSelectionDataSource, navigator: FilterNavigator, showsApplySelectionButton: Bool) {
        guard let child = ChildViewController(filterInfo: filterInfo, selectionDataSource: selectionDataSource) else {
            return nil
        }

        self.filterInfo = filterInfo
        self.selectionDataSource = selectionDataSource
        self.navigator = navigator
        self.showsApplySelectionButton = showsApplySelectionButton
        filterContainerViewController = child
        super.init(nibName: nil, bundle: nil)
        child.filterSelectionDelegate = self
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        let childViewController = filterContainerViewController.controller

        addChildViewController(childViewController)
        setup(with: childViewController.view)
        childViewController.didMove(toParentViewController: self)
    }
}

private extension FilterViewController {
    func setup(with filterView: UIView) {
        view.backgroundColor = .milk
        title = filterInfo.title

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
                filterView.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor),
            ])
        }
    }
}

extension FilterViewController: FilterContainerViewControllerDelegate {
    public func filterContainerViewController(filterContainerViewController: FilterContainerViewController, navigateTo filterInfo: FilterInfoType) {
        switch filterInfo {
        case let multiLevelSelectionFilterInfo as MultiLevelListSelectionFilterInfo:
            navigator.navigate(to: .subLevel(filterInfo: multiLevelSelectionFilterInfo, delegate: delegate))
        default:
            break
        }
    }
}

extension FilterViewController: FilterBottomButtonViewDelegate {
    func filterBottomButtonView(_ filterBottomButtonView: FilterBottomButtonView, didTapButton button: UIButton) {
        delegate?.applyFilterButtonTapped()
    }
}
