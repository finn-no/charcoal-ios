//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import CoreLocation
import FinniversKit
import UIKit
import Warp

public protocol LocationInfo {
    var name: String { get }
    var latitude: Double { get }
    var longitude: Double { get }
}

extension CLLocationCoordinate2D: LocationInfo {
    public var name: String {
        return ""
    }
}

public enum SearchLocationDataSourceResult {
    case finished(text: String, locations: [LocationInfo])
    case cancelled
    case failed(error: Error)
}

public protocol SearchLocationDataSource: AnyObject {
    func searchLocationViewController(_ searchLocationViewController: SearchLocationViewController, didRequestLocationsFor searchQuery: String, completion: @escaping ((_ result: SearchLocationDataSourceResult) -> Void))
    func recentLocation(in searchLocationViewController: SearchLocationViewController) -> [LocationInfo]
    func homeAddressLocation(in searchLocationViewController: SearchLocationViewController) -> LocationInfo?
    func showCurrentLocation(in searchLocationViewController: SearchLocationViewController) -> Bool
}

public protocol SearchLocationViewControllerDelegate: AnyObject {
    func searchLocationViewControllerWillBeginEditing(_ searchLocationViewController: SearchLocationViewController)
    func searchLocationViewControllerDidCancelSearch(_ searchLocationViewController: SearchLocationViewController)
    func searchLocationViewController(_ searchLocationViewController: SearchLocationViewController, didSelectLocation location: LocationInfo?)
    func searchLocationViewControllerDidSelectCurrentLocation(_ searchLocationViewController: SearchLocationViewController)
}

public class SearchLocationViewController: ScrollViewController {
    private enum Section: Int, CaseIterable {
        case homeAddress = 0
        case currentLocation
        case recentLocations
        case results
    }

    // MARK: - Public Properties

    public weak var delegate: SearchLocationViewControllerDelegate?
    public weak var searchLocationDataSource: SearchLocationDataSource?

    // MARK: - Private Properties

    private var locations: [LocationInfo] = []
    private var didClearText = false
    private var selectedLocation: LocationInfo?
    private var recentLocations: [LocationInfo] {
        return searchLocationDataSource?.recentLocation(in: self) ?? []
    }

    private(set) lazy var searchBar: UISearchBar = {
        let searchBar = SearchLocationSearchBar(frame: .zero)
        searchBar.placeholder = "map.search.placeholder".localized()
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.backgroundColor = Theme.mainBackground
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.preservesSuperviewLayoutMargins = false
        return searchBar
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(IconTitleTableViewCell.self)
        tableView.register(BasicTableViewCell.self)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private var searchResultsSectionActive: Bool {
        return !(searchBar.text?.isEmpty ?? true)
    }

    private var showHomeAddressOption: Bool {
        return !searchResultsSectionActive && (searchLocationDataSource?.homeAddressLocation(in: self) != nil)
    }

    private var showCurrentLocationOption: Bool {
        return !searchResultsSectionActive && (searchLocationDataSource?.showCurrentLocation(in: self) ?? false)
    }

    public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        view.endEditing(false)
    }
}

// MARK: - TableView DataSource

extension SearchLocationViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            return 0
        }
        switch section {
        case .homeAddress:
            return showHomeAddressOption ? 1 : 0
        case .currentLocation:
            return showCurrentLocationOption ? 1 : 0
        case .recentLocations:
            return !searchResultsSectionActive ? recentLocations.count : 0
        case .results:
            return locations.count
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            return tableView.dequeue(IconTitleTableViewCell.self, for: indexPath)
        }
        switch section {
        case .homeAddress:
            let cell = tableView.dequeue(IconTitleTableViewCell.self, for: indexPath)
            cell.configure(with: HomeAddressCellViewModel())
            cell.iconImageView.tintColor = Warp.UIToken.iconNegative
            return cell
        case .currentLocation:
            let cell = tableView.dequeue(IconTitleTableViewCell.self, for: indexPath)
            cell.configure(with: CurrentLocationCellViewModel())
            cell.iconImageView.tintColor = Warp.UIToken.iconNegative
            return cell
        case .recentLocations:
            let cell = tableView.dequeue(IconTitleTableViewCell.self, for: indexPath)
            let location = recentLocations[safe: indexPath.row]
            cell.configure(with: LocationCellViewModel(title: location?.name ?? ""))
            return cell
        case .results:
            let cell = tableView.dequeue(BasicTableViewCell.self, for: indexPath)
            let location = locations[safe: indexPath.row]
            cell.configure(with: LocationCellViewModel(title: location?.name ?? ""))
            return cell
        }
    }
}

// MARK: - TableView Delegate

extension SearchLocationViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
        endSearchBarEdit()
        switch section {
        case .homeAddress:
            let location = searchLocationDataSource?.homeAddressLocation(in: self)
            searchBar.text = location?.name
            delegate?.searchLocationViewController(self, didSelectLocation: location)
            selectedLocation = location
        case .currentLocation:
            searchBar.text = nil
            delegate?.searchLocationViewControllerDidSelectCurrentLocation(self)
        case .recentLocations:
            let location = recentLocations[safe: indexPath.row]
            searchBar.text = location?.name
            delegate?.searchLocationViewController(self, didSelectLocation: location)
            selectedLocation = location
        case .results:
            let location = locations[safe: indexPath.row]
            searchBar.text = location?.name
            delegate?.searchLocationViewController(self, didSelectLocation: location)
            selectedLocation = location
        }
    }
}

// MARK: - SearchBar Delegate

extension SearchLocationViewController: UISearchBarDelegate {
    public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        // User clicked the x-button and cleared the text -> should not begin editing
        guard !didClearText else {
            didClearText = false
            return false
        }
        // Present if needed
        if searchBar.superview != view {
            setup()
            if let searchText = searchBar.text {
                loadLocations(forSearchText: searchText)
            }
        }

        delegate?.searchLocationViewControllerWillBeginEditing(self)

        return true
    }

    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: false)
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {}

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        endSearchBarEdit()
        if let selectedLocation = selectedLocation {
            // return to previous search
            searchBar.text = selectedLocation.name
            loadLocations(forSearchText: selectedLocation.name)
            delegate?.searchLocationViewController(self, didSelectLocation: selectedLocation)
        } else {
            delegate?.searchLocationViewControllerDidCancelSearch(self)
            selectedLocation = nil
            searchBar.text = nil
            searchBar.setShowsCancelButton(false, animated: false)
            loadLocations(forSearchText: nil)
        }
    }

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // If not active, the user clicked the x-button while not editing and the search should be cancelled
        if !searchBar.isDescendant(of: view), searchText.isEmpty {
            didClearText = true
            delegate?.searchLocationViewControllerDidCancelSearch(self)
            selectedLocation = nil
            loadLocations(forSearchText: nil)
            return
        }
        // If the user clears the search field and then hits cancel, the search is cancelled
        if selectedLocation != nil, searchText.isEmpty {
            selectedLocation = nil
        }
        loadLocations(forSearchText: searchText)
    }
}

// MARK: - Private methods

private extension SearchLocationViewController {
    func endSearchBarEdit() {
        searchBar.endEditing(false)
        searchBar.setShowsCancelButton(false, animated: false)
    }

    func loadLocations(forSearchText searchText: String?) {
        locations.removeAll()
        tableView.reloadData()
        guard let searchText = searchText, !searchText.isEmpty else { return }
        searchLocationDataSource?.searchLocationViewController(self, didRequestLocationsFor: searchText, completion: { [weak self] result in
            switch result {
            case .cancelled:
                return
            case let .failed(error):
                // TODO: handle error when searching
                DebugLog.write("Location search error: \(error)")
                return
            case let .finished(text, locations):
                DispatchQueue.main.async {
                    guard let query = self?.searchBar.text else { return }
                    if query == text {
                        self?.locations = locations
                        self?.tableView.reloadData()
                    }
                }
            }
        })
    }

    func setup() {
        view.backgroundColor = UIColor.background.withAlphaComponent(0.9)
        tableView.backgroundColor = UIColor.clear
        searchBar.removeFromSuperview()
        view.insertSubview(tableView, belowSubview: topShadowView)
        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Warp.Spacing.spacing100),
            searchBar.topAnchor.constraint(equalTo: view.topAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Warp.Spacing.spacing100),

            topShadowView.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor),

            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

// MARK: - Private class

private class SearchLocationSearchBar: UISearchBar {
    // Makes sure to setup appearance proxy one time and one time only
    private static let setupSearchBarAppereanceOnce: () = {
        let textFieldAppearanceInSearch = UITextField.appearance(whenContainedInInstancesOf: [SearchLocationSearchBar.self])
        textFieldAppearanceInSearch.defaultTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.text,
            NSAttributedString.Key.font: UIFont.body,
        ]

        let barButtondAppearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [SearchLocationSearchBar.self])
        barButtondAppearance.setTitleTextAttributes([.font: UIFont.body])
        barButtondAppearance.title = "cancel".localized()
    }()

    override init(frame: CGRect) {
        _ = SearchLocationSearchBar.setupSearchBarAppereanceOnce
        super.init(frame: frame)
        smartQuotesType = .no
        smartDashesType = .no
    }

    required init?(coder aDecoder: NSCoder) {
        _ = SearchLocationSearchBar.setupSearchBarAppereanceOnce
        super.init(coder: aDecoder)
        smartQuotesType = .no
        smartDashesType = .no
    }
}

private struct HomeAddressCellViewModel: IconTitleTableViewCellViewModel {
    let detailText: String? = nil

    var icon: UIImage? {
        return UIImage(named: .homeAddressIcon).withRenderingMode(.alwaysTemplate)
    }

    var iconTintColor: UIColor? {
        return nil
    }

    var title: String {
        return "map.homeAddress".localized()
    }

    var subtitle: String? {
        return nil
    }

    var hasChevron: Bool {
        return false
    }
    
    var externalIcon: UIImage? {
        return nil
    }
}

private struct CurrentLocationCellViewModel: IconTitleTableViewCellViewModel {
    let detailText: String? = nil

    var icon: UIImage? {
        return UIImage(named: .currentLocationIcon).withRenderingMode(.alwaysTemplate)
    }

    var iconTintColor: UIColor? {
        return nil
    }

    var title: String {
        return "map.currentLocation".localized()
    }

    var subtitle: String? {
        return nil
    }

    var hasChevron: Bool {
        return false
    }
    
    var externalIcon: UIImage? {
        return nil
    }
}

private struct RecentLocationCellViewModel: IconTitleTableViewCellViewModel {
    let detailText: String? = nil

    var icon: UIImage? {
        return UIImage(named: .searchSmall)
    }

    var iconTintColor: UIColor? {
        return nil
    }

    let title: String
    var subtitle: String? {
        return nil
    }

    var hasChevron: Bool {
        return false
    }
    
    var externalIcon: UIImage? {
        return nil
    }
}

private struct LocationCellViewModel: IconTitleTableViewCellViewModel {
    let detailText: String? = nil

    var icon: UIImage? {
        return nil
    }

    var iconTintColor: UIColor? {
        return nil
    }

    let title: String
    var subtitle: String? {
        return nil
    }

    var hasChevron: Bool {
        return false
    }
    
    var externalIcon: UIImage? {
        return nil
    }
}
