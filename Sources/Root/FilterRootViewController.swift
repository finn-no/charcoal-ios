//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol FilterRootViewControllerDelegate: AnyObject {
    func filterRootViewController(_: FilterRootViewController, didChangeVertical vertical: Vertical)
    func filterRootViewControllerShouldShowResults(_: FilterRootViewController)
}

public class FilterRootViewController: UIViewController {
    enum Section: Int, CaseIterable {
        case searchQuery = 0
        case preferences
        case filters
    }

    private let navigator: RootFilterNavigator

    var searchQueryFilter: SearchQueryFilterInfoType? {
        didSet {
            if isViewLoaded && hasUIChanges(lhs: oldValue, rhs: searchQueryFilter) {
                tableView.reloadSections([Section.searchQuery.rawValue], with: .fade)
            }
        }
    }

    var verticalsFilters: [Vertical] = [] {
        didSet {
            if isViewLoaded && hasUIChanges(lhs: oldValue, rhs: verticalsFilters) {
                tableView.reloadSections([Section.preferences.rawValue], with: .fade)
            }
        }
    }

    var preferenceFilters: [PreferenceFilterInfoType] = [] {
        didSet {
            if isViewLoaded && hasUIChanges(lhs: oldValue, rhs: preferenceFilters) {
                tableView.reloadSections([Section.preferences.rawValue], with: .fade)
            }
        }
    }

    var filters: [FilterInfoType] = [] {
        didSet {
            if isViewLoaded && hasUIChanges(lhs: oldValue, rhs: filters) {
                tableView.reloadSections([Section.filters.rawValue], with: .fade)
            }
        }
    }

    var numberOfHits: Int? {
        didSet {
            if isViewLoaded {
                showResultsButtonView.buttonTitle = showResultsButtonViewTitle()
            }
        }
    }

    var selectionDataSource: FilterSelectionDataSource? {
        didSet {
            tableView.reloadData()
        }
    }

    weak var delegate: FilterRootViewControllerDelegate?
    var searchQuerySuggestionDataSource: SearchQuerySuggestionsDataSource?
    let filterSelectionTitleProvider: FilterSelectionTitleProvider

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
        buttonView.buttonTitle = showResultsButtonViewTitle()
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

    lazy var searchViewController: SearchQueryViewController = {
        let searchViewController = SearchQueryViewController()
        searchViewController.delegate = self
        return searchViewController
    }()

    lazy var searchQueryCell: SearchQueryCell = {
        let cell = SearchQueryCell(frame: .zero)
        cell.searchBar = searchViewController.searchBar
        cell.searchBar?.placeholder = searchQueryFilter?.placeholderText
        return cell
    }()

    lazy var bottomsheetTransitioningDelegate: BottomSheetTransitioningDelegate = {
        let delegate = BottomSheetTransitioningDelegate(for: self)
        return delegate
    }()

    public init(title: String, navigator: RootFilterNavigator, selectionDataSource: FilterSelectionDataSource, filterSelectionTitleProvider: FilterSelectionTitleProvider, delegate: FilterRootViewControllerDelegate? = nil) {
        self.navigator = navigator
        self.selectionDataSource = selectionDataSource
        self.filterSelectionTitleProvider = filterSelectionTitleProvider
        self.delegate = delegate
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

    func filterInfo(at indexPath: IndexPath) -> FilterInfoType? {
        guard let section = Section(rawValue: indexPath.section) else {
            return nil
        }
        switch section {
        case .searchQuery:
            return searchQueryFilter
        case .preferences:
            return nil
        case .filters:
            return filters[safe: indexPath.row]
        }
    }

    func selectionValuesForFilterComponent(at indexPath: IndexPath) -> [FilterSelectionInfo] {
        guard let filterInfo = self.filterInfo(at: indexPath) else {
            return []
        }
        return selectionDataSource?.valueAndSubLevelValues(for: filterInfo) ?? []
    }

    func showResultsButtonViewTitle() -> String? {
        if let numberOfHits = numberOfHits {
            return String(format: "show_x_hits_button_title".localized(), numberOfHits)
        } else {
            return "show_hits_button_title".localized()
        }
    }
}

// MARK: - Helpers to check if UI needs to be updated

private extension FilterRootViewController {
    private func hasUIChanges(lhs lhsOrNil: SearchQueryFilterInfoType?, rhs rhsOrNil: SearchQueryFilterInfoType?) -> Bool {
        guard let lhs = lhsOrNil, let rhs = rhsOrNil else {
            return lhsOrNil != nil || rhsOrNil != nil
        }
        return lhs.title != rhs.title || lhs.placeholderText != rhs.placeholderText
    }

    private func hasUIChanges(lhs: [Vertical], rhs: [Vertical]) -> Bool {
        if lhs.count != rhs.count {
            return true
        }
        return !lhs.elementsEqual(rhs, by: { hasUIChanges(lhs: $0, rhs: $1) })
    }

    private func hasUIChanges(lhs: Vertical, rhs: Vertical) -> Bool {
        return lhs.title != rhs.title || lhs.isCurrent != rhs.isCurrent || lhs.isExternal != rhs.isExternal
    }

    private func hasUIChanges(lhs: [PreferenceFilterInfoType], rhs: [PreferenceFilterInfoType]) -> Bool {
        if lhs.count != rhs.count {
            return true
        }
        return !lhs.elementsEqual(rhs, by: { hasUIChanges(lhs: $0, rhs: $1) })
    }

    private func hasUIChanges(lhs: PreferenceFilterInfoType, rhs: PreferenceFilterInfoType) -> Bool {
        if lhs.title != rhs.title || lhs.isMultiSelect != rhs.isMultiSelect || lhs.values.count != rhs.values.count {
            return true
        }
        return !lhs.values.elementsEqual(rhs.values, by: { hasUIChanges(lhs: $0, rhs: $1) })
    }

    private func hasUIChanges(lhs: FilterValueType, rhs: FilterValueType) -> Bool {
        return lhs.title != rhs.title
    }

    private func hasUIChanges(lhs: [FilterInfoType], rhs: [FilterInfoType]) -> Bool {
        if lhs.count != rhs.count {
            return true
        }
        return !lhs.elementsEqual(rhs, by: { hasUIChanges(lhs: $0, rhs: $1) })
    }

    private func hasUIChanges(lhs: FilterInfoType, rhs: FilterInfoType) -> Bool {
        return lhs.title != rhs.title
    }
}

// MARK: -

extension FilterRootViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            return
        }
        switch section {
        case .searchQuery:
            return
        case .preferences:
            return
        case .filters:
            let filterInfo = self.filterInfo(at: indexPath)

            switch filterInfo {
            case let listSelectionFilterInfo as ListSelectionFilterInfoType:
                navigator.navigate(to: .selectionListFilter(filterInfo: listSelectionFilterInfo, delegate: self))
            case let multiLevelListSelectionFilterInfo as MultiLevelListSelectionFilterInfoType:
                navigator.navigate(to: .multiLevelSelectionListFilter(filterInfo: multiLevelListSelectionFilterInfo, delegate: self))
            case let rangeFilterInfo as RangeFilterInfoType:
                navigator.navigate(to: .rangeFilter(filterInfo: rangeFilterInfo, delegate: self))
            case let stepperFilterInfo as StepperFilterInfoType:
                navigator.navigate(to: .stepperFilter(filterInfo: stepperFilterInfo, delegate: self))
            default:
                break
            }
        }
    }
}

extension FilterRootViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            return 0
        }
        switch section {
        case .searchQuery:
            return searchQueryFilter != nil ? 1 : 0
        case .preferences:
            let hasData = !verticalsFilters.isEmpty || !preferenceFilters.isEmpty
            return hasData ? 1 : 0
        case .filters:
            return filters.count
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Unknown section")
        }
        switch section {
        case .searchQuery:
            guard let searchQueryFilter = searchQueryFilter else {
                return searchQueryCell
            }
            let value = selectionDataSource?.value(for: searchQueryFilter)?.first
            searchQueryCell.searchBar?.text = "Test" // value
            return searchQueryCell

        case .preferences:
            let cell = tableView.dequeue(PreferencesCell.self, for: indexPath)
            cell.setupWith(verticals: verticalsFilters, preferences: preferenceFilters, delegate: self, selectionDataSource: selectionDataSource)
            cell.selectionStyle = .none
            return cell

        case .filters:
            let filterInfo = self.filterInfo(at: indexPath)
            let selectionValues = selectionValuesForFilterComponent(at: indexPath)

            switch filterInfo {
            case let listSelectionInfo as ListSelectionFilterInfoType:
                let cell = tableView.dequeue(FilterCell.self, for: indexPath)
                cell.filterName = listSelectionInfo.title
                cell.selectedValues = selectionValues.map({ SelectionWithTitle(selectionInfo: $0, title: filterSelectionTitleProvider.titleForSelection($0)) })
                cell.accessoryType = .disclosureIndicator
                cell.delegate = self
                return cell
            case let multiLevelListSelectionInfo as MultiLevelListSelectionFilterInfoType:
                let cell = tableView.dequeue(FilterCell.self, for: indexPath)
                cell.filterName = multiLevelListSelectionInfo.title
                cell.selectedValues = selectionValues.map({ SelectionWithTitle(selectionInfo: $0, title: filterSelectionTitleProvider.titleForSelection($0)) })
                cell.accessoryType = .disclosureIndicator
                cell.delegate = self
                return cell
            case let rangeInfo as RangeFilterInfoType:
                let cell = tableView.dequeue(FilterCell.self, for: indexPath)
                cell.filterName = rangeInfo.title
                cell.selectedValues = selectionValues.map({ SelectionWithTitle(selectionInfo: $0, title: filterSelectionTitleProvider.titleForSelection($0)) })
                cell.accessoryType = .disclosureIndicator
                cell.delegate = self
                return cell
            case let stepperInfo as StepperFilterInfoType:
                let cell = tableView.dequeue(FilterCell.self, for: indexPath)
                cell.filterName = stepperInfo.title
                cell.selectedValues = selectionValues.map({ SelectionWithTitle(selectionInfo: $0, title: filterSelectionTitleProvider.titleForSelection($0)) })
                cell.accessoryType = .disclosureIndicator
                cell.delegate = self
                return cell
            default:
                fatalError("Unimplemented component \(String(describing: filterInfo))")
            }
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

extension FilterRootViewController: AnyFilterViewController {
    public var mainScrollableContentView: UIScrollView? {
        return tableView
    }

    public var isMainScrollableViewScrolledToTop: Bool {
        return isScrolledToTop
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

// MARK: -

extension FilterRootViewController: FilterCellDelegate {
    func filterCell(_ filterCell: FilterCell, didTapRemoveSelectedValue selectionValue: SelectionWithTitle) {
        guard let indexPath = tableView.indexPath(for: filterCell), let filterInfo = filterInfo(at: indexPath) else {
            return
        }
        if filterInfo is ListSelectionFilterInfo || filterInfo is MultiLevelListSelectionFilterInfo {
            selectionDataSource?.clearSelection(at: 0, in: selectionValue.selectionInfo)
        } else {
            selectionDataSource?.clearAll(for: filterInfo)
        }
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
}

extension FilterRootViewController: SearchViewControllerDelegate {
    public func presentSearchViewController(_ searchViewController: SearchQueryViewController) {
        searchViewController.searchQuerySuggestionDataSource = searchQuerySuggestionDataSource
        // Add view controller as child view controller
        addChild(searchViewController)
        view.addSubview(searchViewController.view)
        searchViewController.view.fillInSuperview()
        view.layoutIfNeeded()
        searchViewController.didMove(toParent: self)
        // Expand bottom sheet if needed
        guard let presentationController = navigationController?.presentationController as? BottomSheetPresentationController else {
            return
        }
        searchViewController.previousSizeMode = presentationController.currentContentSizeMode
        guard presentationController.currentContentSizeMode == .compact else {
            return
        }
        presentationController.transition(to: .expanded)
    }

    public func searchViewController(_ searchViewController: SearchQueryViewController, didSelectQuery query: String?) {
        searchQueryCell.searchBar = searchViewController.searchBar
        guard let query = query, let searchQueryFilterInfo = self.filterInfo(at: IndexPath(row: 0, section: Section.searchQuery.rawValue)) else {
            return
        }
        selectionDataSource?.setValue([query], for: searchQueryFilterInfo)
    }

    public func searchViewControllerDidCancelSearch(_ searchViewController: SearchQueryViewController) {
        searchQueryCell.searchBar = searchViewController.searchBar
        guard let searchQueryFilterInfo = self.filterInfo(at: IndexPath(row: 0, section: Section.searchQuery.rawValue)) else {
            return
        }
        selectionDataSource?.clearAll(for: searchQueryFilterInfo)
    }
}

extension FilterRootViewController: FilterViewControllerDelegate {
    public func applyFilterButtonTapped() {
        navigator.navigate(to: .root)
    }
}

extension FilterRootViewController: VerticalListViewControllerDelegate {
    public func verticalListViewController(_: VerticalListViewController, didSelectVertical vertical: Vertical, at index: Int) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else {
                return
            }
            self.delegate?.filterRootViewController(self, didChangeVertical: vertical)
        }
    }
}
