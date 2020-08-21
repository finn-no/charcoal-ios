//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol RootFilterViewControllerDelegate: AnyObject {
    func rootFilterViewControllerDidResetAllFilters(_ viewController: RootFilterViewController)
    func rootFilterViewController(_ viewController: RootFilterViewController, didRemoveFilter filter: Filter)
    func rootFilterViewController(_ viewController: RootFilterViewController, didSelectInlineFilter filter: Filter)
    func rootFilterViewController(_ viewController: RootFilterViewController, didSelectFreeTextFilter filter: Filter)
    func rootFilterViewController(_ viewController: RootFilterViewController, didSelectSuggestionAt index: Int, filter: Filter)
    func rootFilterViewController(_ viewController: RootFilterViewController, didSelectVertical vertical: Vertical)
}

final class RootFilterViewController: FilterViewController {
    // MARK: - Internal properties

    weak var rootDelegate: (RootFilterViewControllerDelegate & FilterViewControllerDelegate)? {
        didSet { delegate = rootDelegate }
    }

    weak var freeTextFilterDelegate: FreeTextFilterDelegate? {
        didSet { freeTextFilterViewController?.filterDelegate = freeTextFilterDelegate }
    }

    weak var freeTextFilterDataSource: FreeTextFilterDataSource? {
        didSet { freeTextFilterViewController?.filterDataSource = freeTextFilterDataSource }
    }

    var focusOnFreeTextFilterOnNextAppearance: Bool = false

    // MARK: - Private properties

    private lazy var verticalSelectorView = VerticalSelectorView(withAutoLayout: true)

    private lazy var tableView: UITableView = {
        let tableView = AppearanceColoredTableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RootFilterCell.self)
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = Theme.mainBackground

        if #available(iOS 11, *) {
            tableView.estimatedRowHeight = UITableView.automaticDimension
        } else {
            // This is needed for autosizing to work on pre iOS 11 device
            tableView.estimatedRowHeight = 54
        }
        return tableView
    }()

    private lazy var resetButton: UIBarButtonItem = {
        let action = #selector(handleResetButtonTap)
        let button = UIBarButtonItem(title: "reset".localized(), style: .plain, target: self, action: action)
        let font = UIFont.bodyStrong
        let textColor = UIColor.textPrimary
        button.setTitleTextAttributes([.font: font, .foregroundColor: textColor])
        button.setTitleTextAttributes([.font: font, .foregroundColor: textColor.withAlphaComponent(0.3)], for: .disabled)
        return button
    }()

    private lazy var verticalViewController: VerticalListViewController = {
        let viewController = VerticalListViewController()
        viewController.delegate = self
        return viewController
    }()

    private lazy var loadingViewController = LoadingViewController(backgroundColor: Theme.mainBackground, presentationDelay: 0)
    private var loadingStartTimeInterval: TimeInterval?

    private var freeTextFilterViewController: FreeTextFilterViewController?
    private var inlineFilterView: InlineFilterView?
    private var searchBarTopConstraint: NSLayoutConstraint?
    private var inlineFilterTopConstraint: NSLayoutConstraint?

    // MARK: - Filter

    private var filterContainer: FilterContainer

    // MARK: - Init

    init(filterContainer: FilterContainer, selectionStore: FilterSelectionStore) {
        self.filterContainer = filterContainer
        super.init(title: "root.title".localized(), selectionStore: selectionStore)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        updateNavigationTitleView()
        showResetButton(true)
        showBottomButton(true, animated: false)
        updateBottomButtonTitle()
        setup()

        configureInlineFilter()
        inlineFilterView?.slideInWithFade()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        bottomButton.update(with: tableView)
        updateResetButtonAvailability()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if focusOnFreeTextFilterOnNextAppearance {
            freeTextFilterViewController?.searchBar.becomeFirstResponder()
            focusOnFreeTextFilterOnNextAppearance = false
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            configureInlineFilter()
            inlineFilterView?.resetContentOffset()
            updateNavigationTitleView()
            updateBottomButtonTitle()
        }
    }

    // MARK: - Internal

    func reloadFilters() {
        configureInlineFilter()
        tableView.reloadData()
        updateResetButtonAvailability()
        freeTextFilterViewController?.reloadSearchBarText()
    }

    func set(filterContainer: FilterContainer) {
        self.filterContainer = filterContainer
        updateNavigationTitleView()
        updateBottomButtonTitle()
        reloadFilters()
    }

    func showLoadingIndicator(_ show: Bool) {
        resetButton.isEnabled = !show
        verticalSelectorView.isEnabled = !show

        if show {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            loadingStartTimeInterval = Date().timeIntervalSinceReferenceDate
            add(loadingViewController)
            loadingViewController.viewWillAppear(false)
        } else {
            let minTimeInterval: TimeInterval = 0.5
            let timeInterval = Date().timeIntervalSinceReferenceDate
            let diff = loadingStartTimeInterval.map { minTimeInterval - (timeInterval - $0) } ?? minTimeInterval
            let delay = diff > 0 ? diff : 0

            loadingStartTimeInterval = nil

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.loadingViewController.remove()
            }
        }
    }

    func updateResetButtonAvailability() {
        resetButton.isEnabled = !selectionStore.isEmpty
    }

    // MARK: - Private

    private func showResetButton(_ show: Bool) {
        navigationItem.rightBarButtonItem = show ? resetButton : nil
    }

    private func updateNavigationTitleView() {
        if let vertical = filterContainer.verticals?.first(where: { $0.isCurrent }) {
            verticalSelectorView.delegate = self
            verticalSelectorView.configure(
                withTitle: "root.verticalSelector.title".localized(),
                buttonTitle: vertical.title
            )
            navigationItem.titleView = verticalSelectorView
        } else {
            navigationItem.titleView = nil
        }
    }

    private func updateBottomButtonTitle() {
        let localizedString = String(format: "showResultsButton".localized(), filterContainer.numberOfResults)
        let title = localizedString.replacingOccurrences(
            of: "\(filterContainer.numberOfResults)",
            with: filterContainer.numberOfResults.decimalFormatted
        )

        bottomButton.buttonTitle = title
    }

    private func configureInlineFilter() {
        guard let inlineFilter = filterContainer.inlineFilter else {
            return
        }

        let segmentTitles = inlineFilter.subfilters.map { $0.subfilters.map { $0.title } }
        let selectedItems = inlineFilter.subfilters.map {
            $0.subfilters.enumerated().compactMap { index, filter in
                self.selectionStore.isSelected(filter) ? index : nil
            }
        }

        inlineFilterView?.configure(withTitles: segmentTitles, selectedItems: selectedItems)
    }

    private func resetFilters(_ alert: UIAlertAction) {
        selectionStore.removeValues(for: filterContainer.allFilters)
        rootDelegate?.rootFilterViewControllerDidResetAllFilters(self)

        freeTextFilterViewController?.reset()
        configureInlineFilter()
        inlineFilterView?.resetContentOffset()

        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        tableView.layoutIfNeeded()
        tableView.reloadData()
    }

    // MARK: - Actions

    @objc private func handleResetButtonTap() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)

        guard !selectionStore.isEmpty else { return }

        let alertController = UIAlertController(title: nil, message: "alert.reset.message".localized(), preferredStyle: .actionSheet)
        let resetAction = UIAlertAction(title: "alert.action.reset".localized(), style: .destructive, handler: resetFilters(_:))
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel)

        alertController.addAction(resetAction)
        alertController.addAction(cancelAction)

        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = resetButton
        }

        present(alertController, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension RootFilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterContainer.rootFilters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentFilter = filterContainer.rootFilters[indexPath.row]
        let titles = selectionStore.titles(for: currentFilter)
        let isValid = selectionStore.isValid(currentFilter)
        let cell = tableView.dequeue(RootFilterCell.self, for: indexPath)

        cell.delegate = self
        cell.configure(withTitle: currentFilter.title, selectionTitles: titles, isValid: isValid, style: currentFilter.style)

        let mutuallyExclusiveFilters = filterContainer.rootFilters.filter {
            currentFilter.mutuallyExclusiveFilterKeys.contains($0.key)
        }

        cell.isEnabled = !mutuallyExclusiveFilters.reduce(false) {
            $0 || selectionStore.hasSelectedSubfilters(for: $1)
        }

        cell.isSeparatorHidden = indexPath.row == filterContainer.rootFilters.count - 1
        cell.accessibilityIdentifier = currentFilter.title

        return cell
    }
}

// MARK: - UITableViewDelegate

extension RootFilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.filterViewController(self, didSelectFilter: filterContainer.rootFilters[indexPath.row])
    }
}

// MARK: - RootFilterCellDelegate

extension RootFilterViewController: RootFilterCellDelegate {
    func rootFilterCell(_ cell: RootFilterCell, didRemoveTagAt index: Int) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }

        let currentFilter = filterContainer.rootFilters[indexPath.row]
        let selectedSubfilters = selectionStore.selectedSubfilters(for: currentFilter)
        let filterToRemove = selectedSubfilters[index]

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        selectionStore.removeValues(for: filterToRemove)
        rootDelegate?.rootFilterViewController(self, didRemoveFilter: filterToRemove)
        reloadCellsWithExclusiveFilters(for: currentFilter)
    }

    func rootFilterCellDidRemoveAllTags(_ cell: RootFilterCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }

        let currentFilter = filterContainer.rootFilters[indexPath.row]

        selectionStore.removeValues(for: currentFilter)
        rootDelegate?.rootFilterViewController(self, didRemoveFilter: currentFilter)
        reloadCellsWithExclusiveFilters(for: currentFilter)
    }

    private func reloadCellsWithExclusiveFilters(for filter: Filter) {
        let keys = filter.mutuallyExclusiveFilterKeys

        let indexPathsToReload = filterContainer.rootFilters.enumerated().compactMap { index, subfilter in
            return keys.contains(subfilter.key) ? IndexPath(row: index, section: 0) : nil
        }

        tableView.reloadRows(at: indexPathsToReload, with: .none)
    }
}

// MARK: - InlineFilterViewDelegate

extension RootFilterViewController: InlineFilterViewDelegate {
    func inlineFilterView(_ inlineFilteView: InlineFilterView, didChange segment: Segment, at index: Int) {
        guard let inlineFilter = filterContainer.inlineFilter else { return }

        if let subfilter = inlineFilter.subfilter(at: index) {
            selectionStore.removeValues(for: subfilter)

            for index in segment.selectedItems {
                if let subfilter = subfilter.subfilter(at: index) {
                    selectionStore.setValue(from: subfilter)
                }
            }

            rootDelegate?.rootFilterViewController(self, didSelectInlineFilter: inlineFilter)
        }
    }
}

// MARK: - VerticalSelectorViewDelegate

extension RootFilterViewController: VerticalSelectorViewDelegate {
    func verticalSelectorViewDidSelectButton(_ view: VerticalSelectorView) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        if view.arrowDirection == .up {
            hideVerticalViewController()
        } else {
            showVerticalViewController()
        }
    }

    private func showVerticalViewController() {
        guard let verticals = filterContainer.verticals else { return }

        showResetButton(false)
        verticalSelectorView.arrowDirection = .up

        add(verticalViewController)
        verticalViewController.verticals = verticals
        verticalViewController.view.alpha = 0.6
        verticalViewController.view.frame.origin.y = -.spacingXL

        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            self?.verticalViewController.view.alpha = 1
        })

        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 1,
            options: [],
            animations: { [weak self] in self?.verticalViewController.view.frame.origin.y = 0 }
        )
    }

    private func hideVerticalViewController() {
        showResetButton(true)
        verticalSelectorView.arrowDirection = .down

        tableView.alpha = 0
        bottomButton.alpha = 0

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: ({ [weak self] in
            self?.verticalViewController.view.frame.origin.y = -.spacingXXL
            self?.verticalViewController.view.alpha = 0
        }), completion: ({ [weak self] _ in
            self?.verticalViewController.remove()
        }))

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.tableView.alpha = 1
            self?.bottomButton.alpha = 1
        })
    }
}

// MARK: - VerticalListViewControllerDelegate

extension RootFilterViewController: VerticalListViewControllerDelegate {
    func verticalListViewController(_ verticalViewController: VerticalListViewController, didSelectVerticalAtIndex index: Int) {
        if let vertical = filterContainer.verticals?[safe: index], !vertical.isCurrent {
            freeTextFilterViewController?.searchBar.text = nil
            hideVerticalViewController()
            rootDelegate?.rootFilterViewController(self, didSelectVertical: vertical)
        } else {
            hideVerticalViewController()
        }
    }
}

// MARK: - FreeTextFilterViewControllerDelegate

extension RootFilterViewController: FreeTextFilterViewControllerDelegate {
    func freeTextFilterViewController(_ viewController: FreeTextFilterViewController, didEnter value: String?, for filter: Filter) {
        rootDelegate?.rootFilterViewController(self, didSelectFreeTextFilter: filter)
    }

    func freeTextFilterViewController(_ viewController: FreeTextFilterViewController,
                                      didSelectSuggestion suggestion: String,
                                      at index: Int,
                                      for filter: Filter) {
        rootDelegate?.rootFilterViewController(self, didSelectSuggestionAt: index, filter: filter)
    }

    func freeTextFilterViewControllerWillBeginEditing(_ viewController: FreeTextFilterViewController) {
        rootDelegate?.filterViewControllerWillBeginTextEditing(self)
        showResetButton(false)
        verticalSelectorView.isEnabled = false
        add(viewController)
    }

    func freeTextFilterViewControllerWillEndEditing(_ viewController: FreeTextFilterViewController) {
        rootDelegate?.filterViewControllerWillEndTextEditing(self)
        showResetButton(true)
        verticalSelectorView.isEnabled = true
        viewController.remove()

        freeTextFilterViewController?.searchBar.removeFromSuperview()
        setupFreeTextFilter()
    }
}

// MARK: - Setup

private extension RootFilterViewController {
    func setupFreeTextFilter() {
        guard let freeTextFilter = filterContainer.freeTextFilter else { return }

        if freeTextFilterViewController == nil {
            freeTextFilterViewController = FreeTextFilterViewController(filter: freeTextFilter, selectionStore: selectionStore)
            freeTextFilterViewController?.delegate = self
            freeTextFilterViewController?.filterDelegate = freeTextFilterDelegate
            freeTextFilterViewController?.filterDataSource = freeTextFilterDataSource
        }

        let searchBar = freeTextFilterViewController!.searchBar
        tableView.addSubview(searchBar)

        if searchBarTopConstraint == nil {
            searchBarTopConstraint = searchBar.topAnchor.constraint(equalTo: tableView.topAnchor)
        }

        NSLayoutConstraint.activate([
            searchBarTopConstraint!,
            searchBar.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: .spacingS),
            searchBar.widthAnchor.constraint(equalTo: tableView.widthAnchor, constant: -.spacingM),
        ])
    }

    func setupInlineFilter() {
        guard filterContainer.inlineFilter != nil else { return }

        if inlineFilterView == nil {
            inlineFilterView = InlineFilterView(withAutoLayout: true)
            inlineFilterView?.delegate = self
            tableView.addSubview(inlineFilterView!)
        }

        if inlineFilterTopConstraint == nil {
            inlineFilterTopConstraint = inlineFilterView!.topAnchor.constraint(equalTo: tableView.topAnchor)
        }

        NSLayoutConstraint.activate([
            inlineFilterTopConstraint!,
            inlineFilterView!.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            inlineFilterView!.widthAnchor.constraint(equalTo: tableView.widthAnchor),
        ])
    }

    func setup() {
        setupFreeTextFilter()
        setupInlineFilter()

        let freeTextFilterInset = freeTextFilterViewController?.searchBar.intrinsicContentSize.height ?? 0
        let inlineFilterInset = inlineFilterView?.intrinsicContentSize.height ?? 0
        let totalInset = freeTextFilterInset + inlineFilterInset

        searchBarTopConstraint?.constant = -totalInset
        inlineFilterTopConstraint?.constant = -inlineFilterInset

        tableView.contentOffset = CGPoint(x: 0, y: -totalInset)
        tableView.contentInset = UIEdgeInsets(top: totalInset, left: 0, bottom: 0, right: 0)

        view.insertSubview(tableView, belowSubview: bottomButton)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomButton.topAnchor),
        ])
    }
}
