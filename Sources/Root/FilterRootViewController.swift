//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public class FilterRootViewController: UIViewController {
    private let navigator: RootFilterNavigator
    private let dataSource: FilterDataSource

    var popoverPresentationTransitioningDelegate: CustomPopoverPresentationTransitioningDelegate?

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.backgroundColor = .milk
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: .zero)
        return tableView
    }()

    private lazy var showResultsButtonView: FilterBottomButtonView = {
        let buttonView = FilterBottomButtonView()
        buttonView.delegate = self
        buttonView.buttonTitle = "Vis \(dataSource.numberOfHits) treff"
        return buttonView
    }()

    public lazy var bottomsheetTransitioningDelegate: BottomSheetTransitioningDelegate = {
        let delegate = BottomSheetTransitioningDelegate(for: self)
        delegate.presentationControllerDelegate = self
        return delegate
    }()

    public init(title: String, navigator: RootFilterNavigator, dataSource: FilterDataSource) {
        self.navigator = navigator
        self.dataSource = dataSource
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
}

private extension FilterRootViewController {
    func setup() {
        view.backgroundColor = .milk
        tableView.register(SearchQueryCell.self, forCellReuseIdentifier: SearchQueryCell.reuseIdentifier)
        tableView.register(FilterCell.self, forCellReuseIdentifier: FilterCell.reuseIdentifier)
        tableView.register(PreferencesCell.self, forCellReuseIdentifier: PreferencesCell.reuseIdentifier)
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

    func filterInfo(at index: Int) -> FilterInfoType {
        return dataSource.filterInfo[index]
    }

    func selectionValuesForFilterComponent(at index: Int) -> [String] {
        return dataSource.selectionValuesForFilterInfo(at: index)
    }
}

extension FilterRootViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filterInfo = self.filterInfo(at: indexPath.row)

        switch filterInfo {
        case let mulitlevelFilterInfo as MultiLevelFilterInfoType:
            navigator.navigate(to: .mulitLevelFilter(filterInfo: mulitlevelFilterInfo, delegate: self))
        case let rangeFilterInfo as RangeFilterInfoType:
            navigator.navigate(to: .rangeFilter(filterInfo: rangeFilterInfo, delegate: self))
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
        case let freeSearchInfo as FreeSearchFilterInfoType:
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchQueryCell.reuseIdentifier, for: indexPath) as! SearchQueryCell
            cell.searchQuery = freeSearchInfo.currentSearchQuery
            cell.placeholderText = freeSearchInfo.searchQueryPlaceholder
            return cell
        case let preferenceInfo as PreferenceFilterInfoType:
            let cell = tableView.dequeueReusableCell(withIdentifier: PreferencesCell.reuseIdentifier, for: indexPath) as! PreferencesCell
            cell.preferenceSelectionViewDataSource = PreferenceFilterDataSource(preferences: preferenceInfo.preferences)
            cell.preferenceSelectionViewDelegate = self
            cell.selectionStyle = .none
            return cell
        case let multiLevelInfo as MultiLevelFilterInfoType:
            let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.reuseIdentifier, for: indexPath) as! FilterCell
            cell.filterName = multiLevelInfo.name
            cell.selectedValues = selectionValues
            cell.accessoryType = .disclosureIndicator
            cell.delegate = self
            return cell
        case let rangeInfo as RangeFilterInfoType:
            let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.reuseIdentifier, for: indexPath) as! FilterCell
            cell.filterName = rangeInfo.name
            cell.accessoryType = .disclosureIndicator
            return cell
        default:
            fatalError("Unimplemented component \(filterInfo)")
        }
    }
}

extension FilterRootViewController: FilterBottomButtonViewDelegate {
    func filterBottomButtonView(_ filterBottomButtonView: FilterBottomButtonView, didTapButton button: UIButton) {
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
    public func preferenceSelectionView(_ preferenceSelectionView: PreferenceSelectionView, didTapPreferenceAtIndex index: Int) {
        guard let dataSource = preferenceSelectionView.dataSource as? PreferenceFilterDataSource, let preferenceInfo = dataSource.preferences[safe: index], let sourceView = preferenceSelectionView.viewForPreference(at: index) else {
            return
        }

        preferenceSelectionView.setPreference(at: index, selected: true)

        navigator.navigate(to: .preferenceFilterInPopover(preferenceInfo: preferenceInfo, sourceView: sourceView, delegate: self, popoverWillDismiss: { [weak preferenceSelectionView] in

            guard let preferenceSelectionView = preferenceSelectionView, let selectedIndex = preferenceSelectionView.indexesForSelectedPreferences.first else {
                return
            }

            preferenceSelectionView.setPreference(at: selectedIndex, selected: false)
        }))
    }
}

extension FilterRootViewController: PreferenceFilterListViewControllerDelegate {
    public func preferenceFilterListViewController(_ preferenceFilterListViewController: PreferenceFilterListViewController, with preferenceInfo: PreferenceInfoType, didSelect preferenceValue: PreferenceValueType) {
    }
}

extension FilterRootViewController: FilterCellDelegate {
    func filterCell(_ filterCell: FilterCell, didTapRemoveSelectedValueAtIndex: Int) {
        guard let indexPath = tableView.indexPath(for: filterCell) else {
            return
        }
    }
}

extension FilterRootViewController: MultiLevelFilterListViewControllerDelegate {
    public func multiLevelFilterListViewController(_ multiLevelFilterListViewController: MultiLevelFilterListViewController, with filterInfo: MultiLevelFilterInfoType, didSelect sublevelFilterInfo: MultiLevelFilterInfoType) {
    }
}

extension FilterRootViewController: FilterViewControllerDelegate {
    public func applyFilterButtonTapped(with filterSelectionValue: FilterSelectionValue?) {
        navigator.navigate(to: .root)
    }

    public func filterSelectionValueChanged(_ filterSelectionValue: FilterSelectionValue, forFilterWithFilterInfo filterInfo: FilterInfoType) {
    }
}

extension FilterRootViewController {
    class PreferenceFilterDataSource: PreferenceSelectionViewDataSource {
        let preferences: [PreferenceInfoType]

        init(preferences: [PreferenceInfoType]) {
            self.preferences = preferences
        }

        func preferenceSelectionView(_ preferenceSelectionView: PreferenceSelectionView, titleForPreferenceAtIndex index: Int) -> String? {
            return preferences[index].name
        }

        func numberOfPreferences(_ preferenceSelectionView: PreferenceSelectionView) -> Int {
            return preferences.count
        }
    }
}
