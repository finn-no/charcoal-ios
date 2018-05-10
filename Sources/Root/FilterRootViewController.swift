//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public class FilterRootViewController: UIViewController {
    private enum Sections: String {
        case query
        case preference
        case context
        case filter

        static var all: [Sections] {
            return [
                .query,
                .preference,
                .context,
                .filter,
            ]
        }
    }

    private let navigator: FilterNavigator
    private let filterDataSource: FilterRootViewControllerDataSource
    private let preferenceDataSource: FilterRootViewControllerPreferenceDataSource
    private weak var delegate: FilterRootViewControllerDelegate?

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
        buttonView.buttonTitle = filterDataSource.doneButtonTitle
        return buttonView
    }()

    public lazy var bottomsheetTransitioningDelegate: BottomSheetTransitioningDelegate = {
        let delegate = BottomSheetTransitioningDelegate(for: self)
        delegate.presentationControllerDelegate = self
        return delegate
    }()

    public init(navigator: FilterNavigator, filterDataSource: FilterRootViewControllerDataSource, preferenceDataSource: FilterRootViewControllerPreferenceDataSource, delegate: FilterRootViewControllerDelegate?) {
        self.navigator = navigator
        self.filterDataSource = filterDataSource
        self.preferenceDataSource = preferenceDataSource
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    public convenience init(navigator: FilterNavigator, dataSource: FilterRootViewControllerDataSource & FilterRootViewControllerPreferenceDataSource, delegate: FilterRootViewControllerDelegate?) {
        self.init(navigator: navigator, filterDataSource: dataSource, preferenceDataSource: dataSource, delegate: delegate)
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

    private func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, in section: Sections) -> UITableViewCell {
        switch section {
        case .query:
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchQueryCell.reuseIdentifier, for: indexPath) as! SearchQueryCell
            cell.searchQuery = filterDataSource.currentSearchQuery
            cell.placeholderText = filterDataSource.searchQueryPlaceholder
            return cell
        case .filter:
            let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.reuseIdentifier, for: indexPath) as! FilterCell
            if let filter = filterDataSource.filter(at: indexPath.item) {
                cell.filterName = filter.name
                cell.selectedValues = filter.selectedValues
                cell.accessoryType = .disclosureIndicator
                cell.delegate = self
            }
            return cell
        case .context:
            let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.reuseIdentifier, for: indexPath) as! FilterCell
            if let filter = filterDataSource.contextFilter(at: indexPath.item) {
                cell.filterName = filter.name
                cell.selectedValues = filter.selectedValues
                cell.accessoryType = .disclosureIndicator
                cell.delegate = self
            }
            return cell
        case .preference:
            let cell = tableView.dequeueReusableCell(withIdentifier: PreferencesCell.reuseIdentifier, for: indexPath) as! PreferencesCell
            cell.horizontalScrollButtonGroupViewDataSource = preferenceDataSource.preferencesDataSource
            cell.horizontalScrollButtonGroupViewDelegate = self
            return cell
        }
    }
}

extension FilterRootViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Sections.all[safe: indexPath.section] else {
            return
        }
        switch section {
        case .context:
            delegate?.filterRootViewController(self, didSelectContextFilterAt: indexPath)
            break
        case .filter:
            delegate?.filterRootViewController(self, didSelectFilterAt: indexPath)
            break
        default:
            break
        }
    }
}

extension FilterRootViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.all.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Sections.all[safe: section] else {
            return 0
        }
        switch section {
        case .query:
            return 1
        case .preference:
            return preferenceDataSource.hasPreferences ? 1 : 0
        case .context:
            return filterDataSource.numberOfContextFilters
        case .filter:
            return filterDataSource.numberOfFilters
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Sections.all[safe: indexPath.section] else {
            fatalError("Undefined section")
        }
        return self.tableView(tableView, cellForRowAt: indexPath, in: section)
    }
}

extension FilterRootViewController: FilterBottomButtonViewDelegate {
    func filterBottomButtonView(_ filterBottomButtonView: FilterBottomButtonView, didTapButton button: UIButton) {
        delegate?.filterRootViewControllerDidSelectShowResults(self)
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

    func filterInfo(at indexPath: IndexPath) -> FilterInfo? {
        guard let section = Sections.all[safe: indexPath.section] else {
            return nil
        }
        let filterInfo: FilterInfo?
        switch section {
        case .filter:
            filterInfo = filterDataSource.filter(at: indexPath.item)
            break
        case .context:
            filterInfo = filterDataSource.contextFilter(at: indexPath.item)
            break
        default:
            filterInfo = nil
            break
        }
        return filterInfo
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
    public func horizontalScrollButtonGroupView(_ horizontalScrollButtonGroupView: HorizontalScrollButtonGroupView, didTapButton button: UIButton, atIndex index: Int) {
        horizontalScrollButtonGroupView.setButton(at: index, selected: !button.isSelected)

        navigator.navigate(to: .preferenceFilterInPopover(preferenceIndex: index, sourceView: button, popoverWillDismiss: { [weak horizontalScrollButtonGroupView] in
            guard let horizontalScrollButtonGroupView = horizontalScrollButtonGroupView, let selectedIndex = horizontalScrollButtonGroupView.indexesForSelectedButtons.first else {
                return
            }

            horizontalScrollButtonGroupView.setButton(at: selectedIndex, selected: false)
        }))
    }
}

extension FilterRootViewController: FilterCellDelegate {
    func filterCell(_ filterCell: FilterCell, didTapRemoveSelectedValueAtIndex: Int) {
        guard let indexPath = tableView.indexPath(for: filterCell) else {
            return
        }
        guard let _ = filterInfo(at: indexPath) else {
            return
        }
    }
}
