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
        Row(title: "Område i kart", type: MapFilterDemoViewController.self),
        Row(title: "Onboarding", type: OnboardingViewController.self, usingBottomSheet: true),
    ]

    private let markets = [
        Row(title: "Torget", setup: .bap, usingBottomSheet: true),
        Row(title: "Bil", setup: .car, usingBottomSheet: true),
        Row(title: "Eiendom", setup: .realestate, usingBottomSheet: true),
        Row(title: "Jobb", setup: .job, usingBottomSheet: true),
        Row(title: "Båt", setup: .boat, usingBottomSheet: true),
        Row(title: "MC", setup: .mc, usingBottomSheet: true),
        Row(title: "Nyttekjøretøy", setup: .b2b, usingBottomSheet: true),
    ]

    private lazy var sections = [
        Section(title: "Components", data: components),
        Section(title: "Markets", data: markets),
    ]

    // MARK: - Methods

    func row(at indexPath: IndexPath) -> Row {
        return sections[indexPath.section].data[indexPath.row]
    }
}

// MARK: - UITableViewDataSource

extension DataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(DemoTableViewCell.self, for: indexPath)
        cell.textLabel?.text = sections[indexPath.section].data[indexPath.item].title
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}
