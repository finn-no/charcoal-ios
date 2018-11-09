//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol FilterRootViewControllerDelegate: AnyObject {
    func filterRootViewController(_: FilterRootViewController, didChangeVertical vertical: Vertical)
    func filterRootViewControllerShouldShowResults(_: FilterRootViewController)
}

public class FilterRootViewController: UIViewController {
    private let navigator: RootFilterNavigator
    private let dataSource: FilterDataSource
    public let selectionDataSource: FilterSelectionDataSource
    weak var delegate: FilterRootViewControllerDelegate?

    var popoverPresentationTransitioningDelegate: CustomPopoverPresentationTransitioningDelegate?

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.backgroundColor = .milk
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: .zero)

        if UIDevice.isPreiOS11 {
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 44
        }
        return tableView
    }()

    private lazy var showResultsButtonView: FilterBottomButtonView = {
        let buttonView = FilterBottomButtonView()
        buttonView.delegate = self
        buttonView.buttonTitle = "Vis \(dataSource.numberOfHits) treff"
        return buttonView
    }()

    private lazy var loadingView: UIView = {
        let coverView = UIView(frame: .zero)
        coverView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        let activityIndicator = UIActivityIndicatorView(style: .white)
        coverView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: coverView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: coverView.centerYAnchor),
        ])
        activityIndicator.startAnimating()
        return coverView
    }()

    public lazy var bottomsheetTransitioningDelegate: BottomSheetTransitioningDelegate = {
        let delegate = BottomSheetTransitioningDelegate(for: self)
        delegate.presentationControllerDelegate = self
        return delegate
    }()

    public init(title: String, navigator: RootFilterNavigator, dataSource: FilterDataSource, selectionDataSource: FilterSelectionDataSource) {
        self.navigator = navigator
        self.dataSource = dataSource
        self.selectionDataSource = selectionDataSource
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

private extension FilterRootViewController {
    func setup() {
        view.backgroundColor = .milk
        tableView.register(SearchQueryCell.self)
        tableView.register(FilterCell.self)
        tableView.register(PreferencesCell.self)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        showResultsButtonView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(showResultsButtonView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            showResultsButtonView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            showResultsButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            showResultsButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            showResultsButtonView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor),
        ])
    }

    func filterInfo(at index: Int) -> FilterInfoType? {
        return dataSource.filterInfo[safe: index]
    }

    func selectionValuesForFilterComponent(at index: Int) -> [String] {
        return dataSource.selectionValueTitlesForFilterInfoAndSubFilters(at: index)
    }
}

extension FilterRootViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filterInfo = self.filterInfo(at: indexPath.row)

        switch filterInfo {
        case let listSelectionFilterInfo as ListSelectionFilterInfoType:
            navigator.navigate(to: .selectionListFilter(filterInfo: listSelectionFilterInfo, delegate: self))
        case let multiLevelListSelectionFilterInfo as MultiLevelListSelectionFilterInfoType:
            navigator.navigate(to: .multiLevelSelectionListFilter(filterInfo: multiLevelListSelectionFilterInfo, delegate: self))
        case let rangeFilterInfo as RangeFilterInfoType:
            navigator.navigate(to: .rangeFilter(filterInfo: rangeFilterInfo, delegate: self))
        case let searchQueryFilterInfo as SearchQueryFilterInfoType:
            navigator.navigate(to: .searchQueryFilter(filterInfo: searchQueryFilterInfo, delegate: self))
        case let stepperFilterInfo as StepperFilterInfoType:
            navigator.navigate(to: .stepperFilter(filterInfo: stepperFilterInfo, delegate: self))
        default:
            break
        }
    }
}

extension FilterRootViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.filterInfo.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let filterInfo = self.filterInfo(at: indexPath.row)
        let selectionValues = selectionValuesForFilterComponent(at: indexPath.row)

        switch filterInfo {
        case let searchQueryInfo as SearchQueryFilterInfoType:
            let cell = tableView.dequeue(SearchQueryCell.self, for: indexPath)
            cell.searchText = selectionValues.first
            cell.placeholderText = searchQueryInfo.placeholderText
            cell.delegate = self
            return cell
        case let preferenceInfo as PreferenceFilterInfoType:
            let cell = tableView.dequeue(PreferencesCell.self, for: indexPath)
            cell.setupWith(verticals: dataSource.verticals, preferences: preferenceInfo.preferences, delegate: self, selectionDataSource: selectionDataSource)
            cell.selectionStyle = .none
            return cell
        case let listSelectionInfo as ListSelectionFilterInfoType:
            let cell = tableView.dequeue(FilterCell.self, for: indexPath)
            cell.filterName = listSelectionInfo.title
            cell.selectedValues = selectionValues
            cell.accessoryType = .disclosureIndicator
            cell.delegate = self
            return cell
        case let multiLevelListSelectionInfo as MultiLevelListSelectionFilterInfoType:
            let cell = tableView.dequeue(FilterCell.self, for: indexPath)
            cell.filterName = multiLevelListSelectionInfo.title
            cell.selectedValues = selectionValues
            cell.accessoryType = .disclosureIndicator
            cell.delegate = self
            return cell
        case let rangeInfo as RangeFilterInfoType:
            let cell = tableView.dequeue(FilterCell.self, for: indexPath)
            cell.filterName = rangeInfo.title
            cell.selectedValues = selectionValues
            cell.accessoryType = .disclosureIndicator
            cell.delegate = self
            return cell
        case let stepperInfo as StepperFilterInfoType:
            let cell = tableView.dequeue(FilterCell.self, for: indexPath)
            cell.filterName = stepperInfo.title
            cell.selectedValues = selectionValues
            cell.accessoryType = .disclosureIndicator
            cell.delegate = self
            return cell
        default:
            fatalError("Unimplemented component \(String(describing: filterInfo))")
        }
    }
}

extension FilterRootViewController: FilterBottomButtonViewDelegate {
    func filterBottomButtonView(_ filterBottomButtonView: FilterBottomButtonView, didTapButton button: UIButton) {
        delegate?.filterRootViewControllerShouldShowResults(self)
    }
}

// MARK: For BottomSheet

private extension FilterRootViewController {
    var isScrolledToTop: Bool {
        let scrollPos: CGFloat
        if #available(iOS 11.0, *) {
            scrollPos = (tableView.contentOffset.y + tableView.adjustedContentInset.top)
        } else {
            scrollPos = (tableView.contentOffset.y + tableView.contentInset.top)
        }
        return scrollPos < 1
    }

    var isScrollEnabled: Bool {
        get {
            return tableView.isScrollEnabled
        } set {
            tableView.isScrollEnabled = newValue
        }
    }
}

extension FilterRootViewController: BottomSheetPresentationControllerDelegate {
    public func bottomsheetPresentationController(_ bottomsheetPresentationController: BottomSheetPresentationController, shouldBeginTransitionWithTranslation translation: CGPoint, from contentSizeMode: BottomSheetPresentationController.ContentSizeMode) -> Bool {
        switch contentSizeMode {
        case .expanded:
            let isDownwardTranslation = translation.y > 0.0

            if isDownwardTranslation {
                isScrollEnabled = !isScrolledToTop
                return isScrolledToTop
            } else {
                return false
            }
        default:
            return true
        }
    }

    public func bottomsheetPresentationController(_ bottomsheetPresentationController: BottomSheetPresentationController, willTranstionFromContentSizeMode current: BottomSheetPresentationController.ContentSizeMode, to new: BottomSheetPresentationController.ContentSizeMode) {
        switch (current, new) {
        case (_, .compact):
            isScrollEnabled = false
        case (_, .expanded):
            isScrollEnabled = true
        }
    }
}

extension FilterRootViewController: PreferenceSelectionViewDelegate {
    public func preferenceSelectionView(_ preferenceSelectionView: PreferenceSelectionView, didTapExpandablePreferenceAtIndex index: Int, view sourceButton: ExpandableSelectionButton) {
        sourceButton.isSelected = true

        navigator.navigate(to: .verticalSelectionInPopover(verticals: preferenceSelectionView.verticals, sourceView: sourceButton, delegate: self, popoverWillDismiss: { [weak preferenceSelectionView] in
            preferenceSelectionView?.expandablePreferenceClosed()
        }))
    }
}

extension FilterRootViewController: FilterCellDelegate {
    func filterCell(_ filterCell: FilterCell, didTapRemoveSelectedValueAtIndex: Int) {
        guard let indexPath = tableView.indexPath(for: filterCell), let filterInfo = filterInfo(at: indexPath.row) else {
            return
        }
        // TODO: That filterInfo is not always the correct one
        selectionDataSource.clearAll(for: filterInfo)
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
}

extension FilterRootViewController: SearchQueryCellDelegate {
    func searchQueryCellDidTapSearchBar(_ searchQueryCell: SearchQueryCell) {
        guard let indexPath = tableView.indexPath(for: searchQueryCell) else {
            return
        }
        guard let searchQueryFilterInfo = self.filterInfo(at: indexPath.row) as? SearchQueryFilterInfoType else {
            return
        }
        navigator.navigate(to: .searchQueryFilter(filterInfo: searchQueryFilterInfo, delegate: self))
    }

    func searchQueryCellDidTapRemoveSelectedValue(_ searchQueryCell: SearchQueryCell) {
        guard let indexPath = tableView.indexPath(for: searchQueryCell) else {
            return
        }
        guard let searchQueryFilterInfo = self.filterInfo(at: indexPath.row) as? SearchQueryFilterInfoType else {
            return
        }
        selectionDataSource.clearAll(for: searchQueryFilterInfo)
    }
}

extension FilterRootViewController: FilterViewControllerDelegate {
    public func applyFilterButtonTapped() {
        navigator.navigate(to: .root)
    }
}

extension FilterRootViewController: VerticalListViewControllerDelegate {
    public func verticalListViewController(_: VerticalListViewController, didSelectVertical vertical: Vertical, at index: Int) {
        let vc = UIViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.view.addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.fillInSuperview()

        presentedViewController?.present(vc, animated: true, completion: nil)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.dismiss(animated: true, completion: {
            })
        }

        delegate?.filterRootViewController(self, didChangeVertical: vertical)
    }
}
