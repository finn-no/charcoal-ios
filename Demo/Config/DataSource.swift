//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit
import FINNSetup
import UIKit

class DataSource: NSObject {

    // MARK: - Private properties

    private let components = [
        Row(title: "Inline Filter", type: InlineFilterDemoViewController.self),
        Row(title: "Range Filter", type: RangeFilterDemoViewController.self),
        Row(title: "Stepper Filter", type: StepperFilterDemoViewController.self),
    ]

    private let markets = [
        Row(title: "Torget", setup: .bap),
        Row(title: "Bil", setup: .car),
        Row(title: "Eiendom", setup: .realestate),
        Row(title: "Jobb", setup: .job),
        Row(title: "Båt", setup: .boat),
        Row(title: "MC", setup: .mc),
        Row(title: "Nyttekjøretøy", setup: .b2b),
    ]

    private lazy var sections = [
        Section(title: "Components", data: components),
        Section(title: "Markets", data: markets),
    ]

    // MARK: - Methods

    func viewController(for indexPath: IndexPath) -> UIViewController {
        let row = sections[indexPath.section].data[indexPath.row]
        let viewController = row.type.init(nibName: nil, bundle: nil)

        if let charcoalViewController = viewController as? CharcoalViewController {
            charcoalViewController.filter = row.setup?.filter
        }

        return viewController
    }
}

// MARK: - UITableViewDataSource

extension DataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].tableView(tableView, numberOfRowsInSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return sections[indexPath.section].tableView(tableView, cellForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].tableView(tableView, titleForHeaderInSection: section)
    }
}
