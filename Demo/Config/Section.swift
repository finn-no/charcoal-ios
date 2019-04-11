//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class Section: NSObject, UITableViewDataSource {

    // MARK: - Internal properties

    let title: String
    let data: [Row]

    // MARK: - Init

    init(title: String, data: [Row]) {
        self.title = title
        self.data = data
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(DemoTableViewCell.self, for: indexPath)
        cell.textLabel?.text = data[indexPath.item].title
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return title
    }
}
