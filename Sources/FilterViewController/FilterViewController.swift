//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FilterViewControllerDelegate: AnyObject {
    func applyFilterButtonTapped()
}

public protocol ApplySelectionButtonOwner: AnyObject {
    var showsApplySelectionButton: Bool { get set }
}

public final class FilterViewController<ChildViewController: FilterContainerViewController>: UIViewController, ApplySelectionButtonOwner {
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

    private lazy var applySelectionButton: FilterBottomButtonView = {
        let buttonView = FilterBottomButtonView()
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.delegate = self
        buttonView.buttonTitle = "Bruk"
        return buttonView
    }()

    private var applySelectionButtonBottomConstraint: NSLayoutConstraint?

    let filterInfo: FilterInfoType
    let selectionDataSource: FilterSelectionDataSource
    let navigator: FilterNavigator
    let filterContainerViewController: FilterContainerViewController
    weak var delegate: FilterViewControllerDelegate?
    weak var parentApplySelectionButtonOwner: ApplySelectionButtonOwner?

    public var showsApplySelectionButton: Bool {
        didSet {
            view.layoutIfNeeded()
            applySelectionButtonBottomConstraint?.constant = showsApplySelectionButton ? 0 : applySelectionButton.height
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
            parentApplySelectionButtonOwner?.showsApplySelectionButton = showsApplySelectionButton
        }
    }

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

        addChild(childViewController)
        setup(with: childViewController.view)
        childViewController.didMove(toParent: self)
    }
}

private extension FilterViewController {
    func setup(with filterView: UIView) {
        view.backgroundColor = .milk
        title = filterInfo.title

        filterView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterView)

        view.addSubview(applySelectionButton)
        let applySelectionButtonBottomConstraint = applySelectionButton.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor, constant: applySelectionButton.height)
        self.applySelectionButtonBottomConstraint = applySelectionButtonBottomConstraint

        NSLayoutConstraint.activate([
            filterView.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor),
            filterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterView.bottomAnchor.constraint(greaterThanOrEqualTo: safeLayoutGuide.bottomAnchor),
            filterView.bottomAnchor.constraint(greaterThanOrEqualTo: applySelectionButton.topAnchor),
            applySelectionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            applySelectionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            applySelectionButtonBottomConstraint,
        ])

        if showsApplySelectionButton {
            applySelectionButtonBottomConstraint.constant = 0
        }
    }
}

extension FilterViewController: FilterContainerViewControllerDelegate {
    public func filterContainerViewControllerDidChangeSelection(filterContainerViewController: FilterContainerViewController) {
        showsApplySelectionButton = true
    }

    public func filterContainerViewController(filterContainerViewController: FilterContainerViewController, navigateTo filterInfo: FilterInfoType) {
        switch filterInfo {
        case let multiLevelSelectionFilterInfo as MultiLevelListSelectionFilterInfo:
            navigator.navigate(to: .subLevel(filterInfo: multiLevelSelectionFilterInfo, delegate: delegate, parent: self))
        default:
            break
        }
    }
}

extension FilterViewController: FilterBottomButtonViewDelegate {
    func filterBottomButtonView(_ filterBottomButtonView: FilterBottomButtonView, didTapButton button: UIButton) {
        // TODO: Apply current selection
        navigator.navigate(to: .root)
    }
}
