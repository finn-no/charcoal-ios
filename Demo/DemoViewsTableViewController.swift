//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit
import UIKit

// MARK: - DemoViewsTableViewController

class DemoViewsTableViewController: UITableViewController {
    var bottomsheetTransitioningDelegate: BottomSheetTransitioningDelegate?

    init() {
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("") }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let indexPath = Sections.lastSelectedIndexPath, let viewController = Sections.viewController(for: indexPath) {
            let transitionStyle = Sections.transitionStyle(for: indexPath)
            presentViewControllerWithPossibleDismissGesture(viewController, transitionStyle: transitionStyle)
        }
    }

    private func setup() {
        tableView.register(UITableViewCell.self)
        tableView.backgroundColor = UIColor.secondaryBlue
        tableView.delegate = self
        tableView.separatorStyle = .none
    }
}

// MARK: - UITableViewDelegate

extension DemoViewsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.all.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = Sections.all[safe: section]
        return section?.numberOfItems ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(UITableViewCell.self, for: indexPath)
        cell.textLabel?.text = Sections.formattedName(for: indexPath)
        cell.textLabel?.font = UIFont.title3
        cell.textLabel?.textColor = UIColor.milk
        cell.selectionStyle = .none
        cell.backgroundColor = .clear

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Sections.lastSelectedIndexPath = indexPath
        if let viewController = Sections.viewController(for: indexPath) {
            let transitionStyle = Sections.transitionStyle(for: indexPath)
            presentViewControllerWithPossibleDismissGesture(viewController, transitionStyle: transitionStyle)
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Sections.formattedName(for: section)
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        Sections.lastSelectedIndexPath = nil
        super.dismiss(animated: flag, completion: completion)
    }
}

extension DemoViewsTableViewController {
    func presentViewControllerWithPossibleDismissGesture(_ viewController: UIViewController, transitionStyle: TransitionStyle) {
        switch transitionStyle {
        case .bottomSheet:
            bottomsheetTransitioningDelegate = BottomSheetTransitioningDelegate(for: self)
            viewController.transitioningDelegate = bottomsheetTransitioningDelegate
            viewController.modalPresentationStyle = .custom
        default:
            break
        }

        present(viewController, animated: true) {
            if transitionStyle != .bottomSheet {
                let dismissGesture = UITapGestureRecognizer(target: self, action: #selector(self.closeCurrentlyPresentedViewController))
                dismissGesture.numberOfTapsRequired = 2
                viewController.view.addGestureRecognizer(dismissGesture)
            }
        }
    }

    @objc func closeCurrentlyPresentedViewController() {
        dismiss(animated: true)
    }
}
