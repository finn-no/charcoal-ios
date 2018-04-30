//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public class FilterRootViewController: UIViewController {
    fileprivate enum Sections: String {
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

    fileprivate let filterDataSource: FilterRootViewControllerDataSource
    fileprivate weak var delegate: FilterRootViewControllerDelegate?

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.backgroundColor = .milk
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: .zero)
        return tableView
    }()

    fileprivate lazy var showResultsButtonView: FilterBottomButtonView = {
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

    public init(filterDataSource: FilterRootViewControllerDataSource, delegate: FilterRootViewControllerDelegate?) {
        self.filterDataSource = filterDataSource
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        view.backgroundColor = .milk
        tableView.register(SearchQueryCell.self, forCellReuseIdentifier: SearchQueryCell.reuseIdentifier)
        tableView.register(FilterCell.self, forCellReuseIdentifier: FilterCell.reuseIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
            showResultsButtonView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor)
            ])
    }

    fileprivate func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, in section: Sections) -> UITableViewCell {
        switch section {
        case .query:
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchQueryCell.reuseIdentifier, for: indexPath) as! SearchQueryCell
            cell.searchQuery = filterDataSource.currentSearchQuery
            cell.placeholderText = filterDataSource.searchQueryPlaceholder
            return cell
        case .filter:
            let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.reuseIdentifier, for: indexPath)
            if let filter = filterDataSource.filter(at: indexPath.item) {
                cell.textLabel?.text = filter.name
                cell.textLabel?.font = .body
                cell.textLabel?.textColor = .licorice
                cell.accessoryType = .disclosureIndicator
            }
            return cell
        case .context:
            let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.reuseIdentifier, for: indexPath)
            if let filter = filterDataSource.contextFilter(at: indexPath.item) {
                cell.textLabel?.text = filter.name
                cell.textLabel?.font = .body
                cell.textLabel?.textColor = .licorice
                cell.accessoryType = .disclosureIndicator
            }
            return cell
        case .preference:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = nil
            cell.accessoryType = .none
            if let preferencesView = filterDataSource.preferencesView {
                cell.contentView.clipsToBounds = false
                preferencesView.translatesAutoresizingMaskIntoConstraints = false
                cell.contentView.addSubview(preferencesView)
                NSLayoutConstraint.activate([
                    preferencesView.topAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.topAnchor),
                    preferencesView.bottomAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.bottomAnchor),
                    preferencesView.leadingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.leadingAnchor),
                    preferencesView.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor)
                    ])
            }
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
            return filterDataSource.hasPreferences ? 1 : 0
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
extension FilterRootViewController {
    fileprivate var isScrolledToTop: Bool {
        let scrollPos: CGFloat
        if #available(iOS 11.0, *) {
            scrollPos = (tableView.contentOffset.y + tableView.adjustedContentInset.top)
        } else {
            scrollPos = (tableView.contentOffset.y + tableView.contentInset.top)
        }
        return scrollPos < 1
    }

    fileprivate var isScrollEnabled: Bool {
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

