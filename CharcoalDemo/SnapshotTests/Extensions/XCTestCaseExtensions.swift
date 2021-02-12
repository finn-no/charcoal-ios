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
        var snapshotting: Snapshotting = .image(on: device.testDevice)
        if let delay = delay {
            snapshotting = .wait(for: delay, on: snapshotting)
        }

        let userInterfaceStyles: [SnapshotUserInterfaceStyle] = [.lightMode, .darkMode]
        for style in userInterfaceStyles {
            viewController.setUserInterfaceStyle(style)

            let name = "\(device.rawValue)_\(style.rawValue)"
            assertSnapshot(
                matching: viewController, as: snapshotting, named: name,
                record: recording, file: file, testName: testName, line: line
            )
        }
    }

    func elementWithoutTests<T>(
        for caseIterable: T.Type,
        testMethodPrefix: String = "test"
    ) -> [T] where T: CaseIterable, T: RawRepresentable, T.RawValue == String {
        let testMethodPrefix = testMethodPrefix.lowercased()
        var methodCount: UInt32 = 0

        guard let methodList = class_copyMethodList(type(of: self), &methodCount) else {
            return []
        }

        let testMethods = (0..<Int(methodCount))
            .map({ index -> String in
                let selName = sel_getName(method_getName(methodList[index]))
                return String(cString: selName, encoding: .utf8)!.lowercased()
            })
            .filter({ $0.starts(with: testMethodPrefix) })

        return caseIterable.allCases.filter({
            !testMethods.contains("\(testMethodPrefix)\($0.rawValue)".lowercased())
        })
    }

    func assertSnapshots(matching filterContainer: FilterContainer, includeIPad: Bool = true, delay: TimeInterval? = nil, record recording: Bool = false, testName: String = #function) {
        let viewController = getViewController(for: filterContainer)
        assertSnapshots(matching: viewController, device: .iPhone, delay: delay, record: recording, testName: testName)

        if includeIPad {
            assertSnapshots(matching: viewController, device: .iPad, delay: delay, record: recording, testName: testName)
        }
    }

    private func getViewController(for filterContainer: FilterContainer) -> UIViewController {
        let viewController = CharcoalViewController()
        viewController.filterContainer = filterContainer
        return viewController
    }
}
