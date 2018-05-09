//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit
import UIKit

final class PopoverDemoViewController: UIViewController {
    lazy var horizontalScrollButtonGroupView: HorizontalScrollButtonGroupView = {
        let view = HorizontalScrollButtonGroupView(frame: .zero)
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

    var selectedButton: UIButton?

    func setup() {
        view.backgroundColor = .white
        view.addSubview(horizontalScrollButtonGroupView)

        NSLayoutConstraint.activate([
            horizontalScrollButtonGroupView.topAnchor.constraint(equalTo: view.compatibleTopAnchor, constant: .mediumLargeSpacing),
            horizontalScrollButtonGroupView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            horizontalScrollButtonGroupView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            horizontalScrollButtonGroupView.heightAnchor.constraint(equalToConstant: HorizontalScrollButtonGroupView.defaultButtonHeight),
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
        guard let selectedIndex = horizontalScrollButtonGroupView.indexesForSelectedButtons.first else {
            return
        }

        horizontalScrollButtonGroupView.setButton(at: selectedIndex, selected: false)
    }
}

extension PopoverDemoViewController: HorizontalScrollButtonGroupViewDataSource {
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

    func horizontalScrollButtonGroupView(_ horizontalScrollButtonGroupView: HorizontalScrollButtonGroupView, titleForButtonAtIndex index: Int) -> String? {
        return PopoverDemoViewController.preferenceFilters[index].name
    }

    func numberOfButtons(_ horizontalScrollButtonGroup: HorizontalScrollButtonGroupView) -> Int {
        return PopoverDemoViewController.preferenceFilters.count
    }
}

extension PopoverDemoViewController: HorizontalScrollButtonGroupViewDelegate {
    func horizontalScrollButtonGroupView(_ horizontalScrollButtonGroupView: HorizontalScrollButtonGroupView, didTapButton button: UIButton, atIndex index: Int) {
        print("Button at index \(index) with title \(HorizontalScrollButtonGroupViewDemoView.titles[index]) was tapped")
        horizontalScrollButtonGroupView.setButton(at: index, selected: !button.isSelected)
        selectedButton = button

        let preferenceFilter = PopoverDemoViewController.preferenceFilters[index]
        let listItems = preferenceFilter.values.map(PopoverDemoListItem.init)
        let popover = ListViewController(title: preferenceFilter.name, items: listItems)
        popover.preferredContentSize = CGSize(width: view.frame.size.width, height: 144)
        popover.modalPresentationStyle = .custom
        popoverPresentationTransitioningDelegate.sourceView = button
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
