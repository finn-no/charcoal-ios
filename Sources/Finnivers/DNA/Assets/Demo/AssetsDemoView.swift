//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit

public class AssetsDemoView: UIView {
    let images = ImageAsset.imageNames

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    public required init?(coder aDecoder: NSCoder) { fatalError() }

    lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .milk
        return view
    }()

    private func setup() {
        addSubview(tableView)
        tableView.fillInSuperview()
        tableView.dataSource = self
        tableView.register(UITableViewCell.self)
    }
}

extension AssetsDemoView: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(UITableViewCell.self, for: indexPath)
        let image = images[indexPath.row]
        cell.imageView?.image = UIImage(named: image)
        cell.textLabel?.text = image.rawValue
        cell.textLabel?.font = .body
        return cell
    }
}
