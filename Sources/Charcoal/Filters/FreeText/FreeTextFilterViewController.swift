//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit
import UIKit

public protocol FreeTextFilterDataSource: AnyObject {
    func numberOfSuggestions(in freeTextFilterViewController: FreeTextFilterViewController) -> Int
    func freeTextFilterViewController(_ freeTextFilterViewController: FreeTextFilterViewController, suggestionAt indexPath: IndexPath) -> String
}

public protocol FreeTextFilterDelegate: AnyObject {
    func freeTextFilterViewController(_ freeTextFilterViewController: FreeTextFilterViewController, didChangeText text: String?)
}

// Internal protocol to delegate back to root filter view controller
protocol FreeTextFilterViewControllerDelegate: AnyObject {
    func freeTextFilterViewControllerWillBeginEditing(_ viewController: FreeTextFilterViewController)
    func freeTextFilterViewControllerWillEndEditing(_ viewController: FreeTextFilterViewController)
    func freeTextFilterViewController(_ viewController: FreeTextFilterViewController, didEnter value: String?, for filter: Filter)
    func freeTextFilterViewController(_ viewController: FreeTextFilterViewController,
                                      didSelectSuggestion suggestion: String,
                                      at index: Int,
                                      for filter: Filter)
}

public class FreeTextFilterViewController: ScrollViewController {
    // MARK: - Public Properties

    weak var filterDelegate: FreeTextFilterDelegate?
    weak var filterDataSource: FreeTextFilterDataSource?

    weak var delegate: FreeTextFilterViewControllerDelegate?

    // MARK: - Private Properties

    private var didClearText = false

    private let filter: Filter
    private let selectionStore: FilterSelectionStore
    private let notificationCenter: NotificationCenter

    private(set) lazy var searchBar: UISearchBar = {
        let searchBar = FreeTextFilterSearchBar(frame: .zero)
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.backgroundColor = .milk
        searchBar.placeholder = filter.title
        searchBar.text = selectionStore.value(for: filter)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(IconTitleTableViewCell.self)
        tableView.removeLastCellSeparator()
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    // MARK: - Init

    init(filter: Filter, selectionStore: FilterSelectionStore, notificationCenter: NotificationCenter = .default) {
        self.filter = filter
        self.selectionStore = selectionStore
        self.notificationCenter = notificationCenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notificationCenter.removeObserver(self)
    }

    // MARK: - Public methods

    public func reloadData() {
        tableView.reloadData()
    }

    public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        view.bringSubviewToFront(searchBar)
    }

    // MARK: - Helper methods

    func reset() {
        searchBar.text = nil
        didClearText = false
        filterDelegate?.freeTextFilterViewController(self, didChangeText: nil)
    }

    @objc private func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        var keyboardHeight = view.convert(keyboardValue.cgRectValue, from: view.window).height

        if #available(iOS 11.0, *) {
            keyboardHeight -= view.window?.safeAreaInsets.bottom ?? 0
        }

        if notification.name == UIResponder.keyboardWillHideNotification {
            tableView.contentInset = .zero
        } else {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        }

        tableView.scrollIndicatorInsets = tableView.contentInset
    }
}

// MARK: - TableView DataSource

extension FreeTextFilterViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterDataSource?.numberOfSuggestions(in: self) ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(IconTitleTableViewCell.self, for: indexPath)
        let title = filterDataSource?.freeTextFilterViewController(self, suggestionAt: indexPath)
        cell.titleLabel.font = .bodyRegular
        cell.configure(with: FreeTextSuggestionCellViewModel(title: title ?? ""))
        cell.separatorInset = .leadingInset(48)
        return cell
    }
}

// MARK: - TableView Delegate

extension FreeTextFilterViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let value = filterDataSource?.freeTextFilterViewController(self, suggestionAt: indexPath) else { return }
        searchBar.text = value
        tableView.deselectRow(at: indexPath, animated: true)

        selectionStore.setValue(value, for: filter)
        delegate?.freeTextFilterViewController(self, didSelectSuggestion: value, at: indexPath.row, for: filter)

        returnToSuperView()
    }
}

// MARK: - SearchBar Delegate

extension FreeTextFilterViewController: UISearchBarDelegate {
    public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        // User clicked the x-button and cleared the text -> should not begin editing
        guard !didClearText else {
            didClearText = false
            return false
        }
        // Present if needed
        if searchBar.superview != view {
            setup()
            tableView.reloadData()
        }

        delegate?.freeTextFilterViewControllerWillBeginEditing(self)

        return true
    }

    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        returnToSuperView()
    }

    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: false)
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let value = searchBar.text else { return }

        selectionStore.setValue(value, for: filter)
        delegate?.freeTextFilterViewController(self, didEnter: value, for: filter)

        returnToSuperView()
    }

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if selectionStore.value(for: filter) as String? != nil, searchBar.text == nil || searchBar.text?.isEmpty == true {
            selectionStore.removeValues(for: filter)
            delegate?.freeTextFilterViewController(self, didEnter: nil, for: filter)
        }

        searchBar.text = selectionStore.value(for: filter)
        filterDelegate?.freeTextFilterViewController(self, didChangeText: selectionStore.value(for: filter))

        returnToSuperView()
    }

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // If not active, the user clicked the x-button while not editing and the search should be cancelled
        if !searchBar.isDescendant(of: view), searchText.isEmpty {
            didClearText = true

            selectionStore.removeValues(for: filter)
            delegate?.freeTextFilterViewController(self, didEnter: nil, for: filter)

            filterDelegate?.freeTextFilterViewController(self, didChangeText: nil)
            return
        }

        filterDelegate?.freeTextFilterViewController(self, didChangeText: searchText)
    }
}

// MARK: - Private methods

private extension FreeTextFilterViewController {
    func returnToSuperView() {
        if view.superview != nil {
            searchBar.endEditing(false)
            searchBar.setShowsCancelButton(false, animated: false)
            delegate?.freeTextFilterViewControllerWillEndEditing(self)
        }
    }

    func setup() {
        searchBar.removeFromSuperview()
        view.addSubview(searchBar)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .mediumSpacing),
            searchBar.topAnchor.constraint(equalTo: view.topAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.mediumSpacing),

            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        topSeparatorViewConstraint.constant = searchBar.frame.height
    }
}

private class FreeTextFilterSearchBar: UISearchBar {
    // Makes sure to setup appearance proxy one time and one time only
    private static let setupSearchQuerySearchBarAppereanceOnce: () = {
        let textFieldAppearance = UITextField.appearance(whenContainedInInstancesOf: [FreeTextFilterSearchBar.self])
        textFieldAppearance.defaultTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.licorice,
            NSAttributedString.Key.font: UIFont.bodyRegular,
        ]

        let barButtondAppearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [FreeTextFilterSearchBar.self])
        barButtondAppearance.setTitleTextAttributes([.font: UIFont.bodyRegular])
        barButtondAppearance.title = "cancel".localized()
    }()

    override init(frame: CGRect) {
        _ = FreeTextFilterSearchBar.setupSearchQuerySearchBarAppereanceOnce
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        _ = FreeTextFilterSearchBar.setupSearchQuerySearchBarAppereanceOnce
        super.init(coder: aDecoder)
    }
}
