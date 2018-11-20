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

public final class FilterViewController<ChildViewController: FilterContainerViewController>: UIViewController, ApplySelectionButtonOwner, AnyFilterViewController {
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
        buttonView.buttonTitle = "apply_button_title".localized()
        return buttonView
    }()

    private var applySelectionButtonBottomConstraint: NSLayoutConstraint?

    let filterInfo: FilterInfoType
    let selectionDataSource: FilterSelectionDataSource
    let navigator: FilterNavigator
    let filterContainerViewController: FilterContainerViewController
    weak var delegate: FilterViewControllerDelegate?
    weak var parentApplySelectionButtonOwner: ApplySelectionButtonOwner?
    var applyButtonHiddenConstraintConstant: CGFloat {
        return applySelectionButton.height
    }

    public var showsApplySelectionButton: Bool {
        didSet {
            guard showsApplySelectionButton != oldValue else {
                return
            }
            view.layoutIfNeeded()
            applySelectionButton.alpha = showsApplySelectionButton ? 0 : 1
            applySelectionButton.isHidden = false
            applySelectionButtonBottomConstraint?.constant = showsApplySelectionButton ? 0 : applyButtonHiddenConstraintConstant
            UIView.animate(withDuration: 0.25, animations: { [applySelectionButton, showsApplySelectionButton] in
                applySelectionButton.alpha = showsApplySelectionButton ? 1 : 0
                self.view.layoutIfNeeded()
            }) { [applySelectionButton, showsApplySelectionButton] _ in
                applySelectionButton.isHidden = !showsApplySelectionButton
            }
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
            parentApplySelectionButtonOwner?.showsApplySelectionButton = showsApplySelectionButton
        }
    }

    public var mainScrollableContentView: UIScrollView? {
        return (filterContainerViewController as? ScrollableContainerViewController)?.mainScrollableView
    }

    public var isMainScrollableViewScrolledToTop: Bool {
        return (filterContainerViewController as? ScrollableContainerViewController)?.isMainScrollableViewScrolledToTop ?? true
    }

    public required init?(filterInfo: FilterInfoType, dataSource: FilterDataSource, selectionDataSource: FilterSelectionDataSource, navigator: FilterNavigator) {
        guard let child = ChildViewController(filterInfo: filterInfo, dataSource: dataSource, selectionDataSource: selectionDataSource) else {
            return nil
        }

        self.filterInfo = filterInfo
        self.selectionDataSource = selectionDataSource
        self.navigator = navigator
        showsApplySelectionButton = false
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
        let applySelectionButtonBottomConstraint = applySelectionButton.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor, constant: applyButtonHiddenConstraintConstant)
        self.applySelectionButtonBottomConstraint = applySelectionButtonBottomConstraint

        NSLayoutConstraint.activate([
            filterView.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor),
            filterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterView.bottomAnchor.constraint(equalTo: applySelectionButton.topAnchor),
            applySelectionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            applySelectionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            applySelectionButtonBottomConstraint,
        ])

        if showsApplySelectionButton {
            applySelectionButtonBottomConstraint.constant = 0
        } else {
            applySelectionButton.isHidden = true
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
