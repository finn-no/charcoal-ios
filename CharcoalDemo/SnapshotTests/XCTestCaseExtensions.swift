@testable import CharcoalDemo
import Charcoal
import SnapshotTesting
import XCTest

extension XCTestCase {
    func assertSnapshots(
        matching viewController: UIViewController,
        device: SnapshotDeviceFamily,
        delay: TimeInterval? = nil,
        record recording: Bool = false,
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) {
        for style in SnapshotUserInterfaceStyle.allCases {
            var snapshotting = Snapshotting.image(on: device.testDevice, interfaceStyle: style)
            if let delay = delay {
                snapshotting = .wait(for: delay, on: snapshotting)
            }

            let name = "\(device.rawValue)_\(style.rawValue)"
            assertSnapshot(
                matching: viewController, as: snapshotting, named: name,
                record: recording, file: file, testName: testName, line: line
            )
        }
    }

    func assertSnapshots(
        matching filterContainer: FilterContainer,
        includeIPad: Bool = true,
        delay: TimeInterval? = nil,
        record recording: Bool = false,
        file: StaticString = #file,
        testName: String = #function
    ) {
        let viewController = getViewController(for: filterContainer)
        assertSnapshots(
            matching: viewController,
            device: .iPhone,
            delay: delay,
            record: recording,
            file: file,
            testName: testName
        )

        if includeIPad {
            assertSnapshots(
                matching: viewController,
                device: .iPad,
                delay: delay,
                record: recording,
                file: file,
                testName: testName
            )
        }
    }

    private func getViewController(for filterContainer: FilterContainer) -> UIViewController {
        let viewController = CharcoalViewController()
        viewController.filterContainer = filterContainer
        return viewController
    }
}

// MARK: - Private extension

private extension Snapshotting where Value == UIViewController, Format == UIImage {
    /// Setting `perceptualPrecision` to avoids failing tests due to imperceivable differences in anti-aliasing, shadows, and blurs
    private static var defaultPerceptualPrecision: Float {
        0.98
    }

    static func image(
        on config: ViewImageConfig,
        interfaceStyle: SnapshotUserInterfaceStyle
    ) -> Snapshotting {
        let style: UIUserInterfaceStyle

        switch interfaceStyle {
        case .lightMode:
            style = .light
        case .darkMode:
            style = .dark
        }
        return image(on: config, perceptualPrecision: defaultPerceptualPrecision, traits: UITraitCollection(userInterfaceStyle: style))
    }
}
