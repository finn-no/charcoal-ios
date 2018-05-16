//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit
import UIKit

final class PopoverDemoViewController: UIViewController {
    lazy var preferenceSelectionView: PreferenceSelectionView = {
        let view = PreferenceSelectionView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.dataSource = self
        view.delegate = self
        return view
    }()

    lazy var popoverPresentationTransitioningDelegate: CustomPopoverPresentationTransitioningDelegate = {
        let transitioningDelegate = CustomPopoverPresentationTransitioningDelegate()
        transitioningDelegate.willDismissPopoverHandler = willDismissPopoverHandler
        return transitioningDelegate
    }()

    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    var selectedPreferenceView: UIView?

    func setup() {
        view.backgroundColor = .white
        view.addSubview(preferenceSelectionView)

        NSLayoutConstraint.activate([
            preferenceSelectionView.topAnchor.constraint(equalTo: view.compatibleTopAnchor, constant: .mediumLargeSpacing),
            preferenceSelectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            preferenceSelectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            preferenceSelectionView.heightAnchor.constraint(equalToConstant: PreferenceSelectionView.defaultButtonHeight),
        ])
    }
}

private extension PopoverDemoViewController {
    class PopoverFilterViewController: UITableViewController {
        var filters = [String]()

        convenience init(filters: [String]) {
            self.init(style: .plain)
            self.filters = filters
            view.backgroundColor = .milk
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        }

        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filters.count
        }

        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
            cell.textLabel?.text = filters[indexPath.row]
            cell.textLabel?.font = .body
            cell.textLabel?.textColor = .primaryBlue
            return cell
        }

        override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 48
        }
    }

    func willDismissPopoverHandler(_ popoverPresentationController: UIPopoverPresentationController) {
        guard let selectedIndex = preferenceSelectionView.indexesForSelectedPreferences.first else {
            return
        }

        preferenceSelectionView.setPreference(at: selectedIndex, selected: false)
    }
}

extension PopoverDemoViewController: PreferenceSelectionViewDataSource {
    struct PreferenceFilter {
        let name: String
        let values: [String]
    }

    static var preferenceFilters: [PreferenceFilter] {
        return [
            PreferenceFilter(name: "Type søk", values: ["Til salgs", "Gis bort", "Ønskes kjøpt"]),
            PreferenceFilter(name: "Tilstand", values: ["Alle", "Brukt", "Nytt"]),
            PreferenceFilter(name: "Selger", values: ["Alle", "Forhandler", "Privat"]),
            PreferenceFilter(name: "Publisert", values: ["Nye i dag"]),
        ]
    }

    func preferenceSelectionView(_ preferenceSelectionView: PreferenceSelectionView, titleForPreferenceAtIndex index: Int) -> String? {
        return PopoverDemoViewController.preferenceFilters[index].name
    }

    func numberOfPreferences(_ preferenceSelectionView: PreferenceSelectionView) -> Int {
        return PopoverDemoViewController.preferenceFilters.count
    }
}

extension PopoverDemoViewController: PreferenceSelectionViewDelegate {
    func preferenceSelectionView(_ preferenceSelectionView: PreferenceSelectionView, didTapPreferenceAtIndex index: Int) {
        print("Button at index \(index) with title \(PreferenceSelectionViewDemoView.titles[index]) was tapped")

        let isSelected = preferenceSelectionView.isPreferenceSelected(at: index)
        preferenceSelectionView.setPreference(at: index, selected: !isSelected)
        selectedPreferenceView = preferenceSelectionView.viewForPreference(at: index)

        let preferenceFilter = PopoverDemoViewController.preferenceFilters[index]
        let listItems = preferenceFilter.values.map(PopoverDemoListItem.init)
        let popover = ListViewController(title: preferenceFilter.name, items: listItems)
        popover.preferredContentSize = CGSize(width: view.frame.size.width, height: 144)
        popover.modalPresentationStyle = .custom
        popoverPresentationTransitioningDelegate.sourceView = selectedPreferenceView
        popover.transitioningDelegate = popoverPresentationTransitioningDelegate

        present(popover, animated: true, completion: nil)
    }
}

private extension PopoverDemoViewController {
    struct PopoverDemoListItem: ListItem {
        var title: String?
        let detail: String? = nil
        let showsDisclosureIndicator: Bool = false
    }
}
