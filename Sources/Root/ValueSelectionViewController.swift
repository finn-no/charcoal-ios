//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol ValueSelectionViewControllerDataSource {
    var count: Int { get }
    func nameForItem(at index: Int) -> String
}

class ValueSelectionViewController: UITableViewController {
    let valuesDataSource: ValueSelectionViewControllerDataSource

    init(valuesDataSource: ValueSelectionViewControllerDataSource) {
        self.valuesDataSource = valuesDataSource
        super.init(style: .plain)
        view.backgroundColor = .milk
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return valuesDataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.textLabel?.font = .body
        cell.textLabel?.textColor = .primaryBlue
        cell.textLabel?.text = valuesDataSource.nameForItem(at: indexPath.row)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
}
