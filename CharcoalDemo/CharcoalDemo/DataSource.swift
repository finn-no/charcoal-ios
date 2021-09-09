//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal
import FinniversKit

class DataSource: NSObject, UITableViewDataSource {
    func row(at indexPath: IndexPath) -> Row {
        DemoSections.allCases[indexPath.section].rows[indexPath.row]
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        DemoSections.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        DemoSections.allCases[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(DemoTableViewCell.self, for: indexPath)
        let row = DemoSections.allCases[indexPath.section].rows[indexPath.row]
        cell.textLabel?.text = row.title
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        DemoSections.allCases[section].title
    }
}
