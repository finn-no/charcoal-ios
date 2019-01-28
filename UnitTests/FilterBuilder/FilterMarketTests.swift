//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import XCTest

class FilterMarketTests: NSObject {
    func testFilterMarketAllCasesMustBeExhaustive() {
        let results = verifyAllCasesIsExhaustive(filterMarket: .bap(.bap))
        XCTAssertTrue(results, "If it compiles the test works...")
    }
}

extension FilterMarketTests {
    func verifyAllCasesIsExhaustive(filterMarket: FilterMarket) -> Bool {
        switch filterMarket {
        case .bap(.bap),
             .realestate(.homes),
             .car(.norway), .car(.abroad),
             .mc(.mc), .mc(.mopedScooter), .mc(.snowmobile), .mc(.atv),
             .job(.fullTime), .job(.partTime), .job(.management),
             .boat(.boatSale), .boat(.boatUsedWanted), .boat(.boatRent), .boat(.boatMotor), .boat(.boatParts), .boat(.boatPartsMotorWanted), .boat(.boatDock), .boat(.boatDockWanted):
            break
        }
        return true
    }
}
