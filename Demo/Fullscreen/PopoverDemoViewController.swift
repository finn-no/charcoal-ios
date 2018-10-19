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
            tableView.register(UITableViewCell.self)
        }

        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filters.count
        }

        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeue(UITableViewCell.self, for: indexPath)
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
    func preferenceSelectionView(_ preferenceSelectionView: PreferenceSelectionView, preferenceAtIndex index: Int) -> PreferenceInfoType? {
        return PopoverDemoViewController.preferenceFilters[safe: index]
    }

    static var preferenceFilters: [PreferenceInfoDemo] {
        return [
            PreferenceInfoDemo(preferenceName: "Type søk", values:
                [
                    PreferenceValueTypeDemo(title: "Til salgs", value: "1", results: 1),
                    PreferenceValueTypeDemo(title: "Gis bort", value: "2", results: 1),
                    PreferenceValueTypeDemo(title: "Ønskes kjøpt", value: "3", results: 1),
            ], isMultiSelect: true, title: "Type søk"),
            PreferenceInfoDemo(preferenceName: "Tilstand", values:
                [
                    PreferenceValueTypeDemo(title: "Alle", value: "0", results: 1),
                    PreferenceValueTypeDemo(title: "Brukt", value: "2", results: 1),
                    PreferenceValueTypeDemo(title: "Nytt", value: "3", results: 1),
            ], isMultiSelect: false, title: "Tilstand"),
            PreferenceInfoDemo(preferenceName: "Selger", values:
                [
                    PreferenceValueTypeDemo(title: "Alle", value: "0", results: 1),
                    PreferenceValueTypeDemo(title: "Forhandler", value: "2", results: 1),
                    PreferenceValueTypeDemo(title: "Privat", value: "3", results: 1),
            ], isMultiSelect: false, title: "Selger"),
            PreferenceInfoDemo(preferenceName: "Publisert", values:
                [PreferenceValueTypeDemo(title: "Nye i dag", value: "1", results: 1)], isMultiSelect: false, title: "Publisert"),
        ]
    }

    func preferenceSelectionView(_ preferenceSelectionView: PreferenceSelectionView, titleForPreferenceAtIndex index: Int) -> String {
        return PopoverDemoViewController.preferenceFilters[index].title
    }

    func numberOfPreferences(_ preferenceSelectionView: PreferenceSelectionView) -> Int {
        return PopoverDemoViewController.preferenceFilters.count
    }
}

extension PopoverDemoViewController: PreferenceSelectionViewDelegate {
    func preferenceSelectionView(_ preferenceSelectionView: PreferenceSelectionView, didTapPreferenceAtIndex index: Int) {
        print("Button at index \(index) with title \(PopoverDemoViewController.preferenceFilters[index].title) was tapped")

        let isSelected = preferenceSelectionView.isPreferenceSelected(at: index)
        preferenceSelectionView.setPreference(at: index, selected: !isSelected)
        selectedPreferenceView = preferenceSelectionView.viewForPreference(at: index)

        let preferenceFilter = PopoverDemoViewController.preferenceFilters[index]
        let listItems = preferenceFilter.values
        let popover = ListViewController(title: preferenceFilter.title, items: listItems)
        popover.preferredContentSize = CGSize(width: view.frame.size.width, height: 144)
        popover.modalPresentationStyle = .custom
        popoverPresentationTransitioningDelegate.sourceView = selectedPreferenceView
        popover.transitioningDelegate = popoverPresentationTransitioningDelegate

        present(popover, animated: true, completion: nil)
    }
}

struct PreferenceInfoDemo: PreferenceInfoType {
    var preferenceName: String
    var values: [PreferenceValueType]
    var isMultiSelect: Bool
    var title: String
}

struct PreferenceValueTypeDemo: PreferenceValueType {
    var title: String
    var value: String
    var results: Int
}
