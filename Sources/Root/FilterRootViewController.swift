//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public class FilterRootViewController: UIViewController {
    private let navigator: RootFilterNavigator
    private let components: [FilterComponent]

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
        buttonView.buttonTitle = "Vis 42 treff"
        return buttonView
    }()

    public lazy var bottomsheetTransitioningDelegate: BottomSheetTransitioningDelegate = {
        let delegate = BottomSheetTransitioningDelegate(for: self)
        delegate.presentationControllerDelegate = self
        return delegate
    }()

    public init(navigator: RootFilterNavigator, components: [FilterComponent]) {
        self.navigator = navigator
        self.components = components
        super.init(nibName: nil, bundle: nil)
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
}

extension FilterRootViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let component = components[indexPath.row]

        navigator.navigate(to: .filter(filterInfo: component.filterInfo))
    }
}

extension FilterRootViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return components.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let component = components[indexPath.row]

        switch component {
        case let freeSearch as FreeSearchFilterComponent:
            let filterInfo = freeSearch.filterInfo as? FreeSearchFilterComponent.Info
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchQueryCell.reuseIdentifier, for: indexPath) as! SearchQueryCell
            cell.searchQuery = filterInfo?.currentSearchQuery
            cell.placeholderText = filterInfo?.searchQueryPlaceholder
            return cell
        case let preference as PreferenceFilterComponent:
            let filterInfo = preference.filterInfo as? PreferenceFilterComponent.Info
            let cell = tableView.dequeueReusableCell(withIdentifier: PreferencesCell.reuseIdentifier, for: indexPath) as! PreferencesCell
            cell.horizontalScrollButtonGroupViewDataSource = PreferenceFilterDataSource(preferences: filterInfo?.preferences ?? [])
            cell.horizontalScrollButtonGroupViewDelegate = self
            cell.selectionStyle = .none
            return cell
        case let multiLevel as MultiLevelFilterComponent:
            let filterInfo = multiLevel.filterInfo as? MultiLevelFilterComponent.Info
            let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.reuseIdentifier, for: indexPath) as! FilterCell
            cell.filterName = filterInfo?.name
            cell.selectedValues = filterInfo?.selectedValues
            cell.accessoryType = .disclosureIndicator
            cell.delegate = self
            return cell
        default:
            fatalError("Unimplemented component \(component)")
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

extension FilterRootViewController: HorizontalScrollButtonGroupViewDelegate {
    public func preferenceSelectionView(_ preferenceSelectionView: PreferenceSelectionView, didTapPreferenceAtIndex index: Int) {
        guard let dataSource = preferenceSelectionView.dataSource as? PreferenceFilterDataSource, let preferenceInfo = dataSource.preferences[safe: index] else {
        guard let preferenceInfo = preferenceDataSource.preference(at: index) else {
            return
        }

        preferenceSelectionView.setPreference(at: index, selected: true)

        navigator.navigate(to: .preferenceFilterInPopover(preferenceInfo: preferenceInfo, sourceView: button, popoverWillDismiss: { [weak preferenceSelectionView] in
            guard let preferenceSelectionView = preferenceSelectionView, let selectedIndex = preferenceSelectionView.indexesForSelectedPreferences.first else {
                return
            }

            preferenceSelectionView.setPreference(at: selectedIndex, selected: false)
        }))
    }
}

extension FilterRootViewController: FilterCellDelegate {
    func filterCell(_ filterCell: FilterCell, didTapRemoveSelectedValueAtIndex: Int) {
        guard let indexPath = tableView.indexPath(for: filterCell) else {
            return
        }
    }
}

extension FilterRootViewController {
    class PreferenceFilterDataSource: HorizontalScrollButtonGroupViewDataSource {
        let preferences: [PreferenceInfo]

        init(preferences: [PreferenceInfo]) {
            self.preferences = preferences
        }

        func horizontalScrollButtonGroupView(_ horizontalScrollButtonGroupView: HorizontalScrollButtonGroupView, titleForButtonAtIndex index: Int) -> String? {
            return preferences[index].name
        }

        func numberOfButtons(_ horizontalScrollButtonGroupView: HorizontalScrollButtonGroupView) -> Int {
            return preferences.count
        }
    }
}
