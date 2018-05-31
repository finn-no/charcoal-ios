//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit
import UIKit

final class CompactListFilterViewDemoView: UIView {
    static let items: [String] = {
        return (35 ... 48).map { "\($0)" }
    }()

    let compactListFilterView: CompactListFilterView = {
        let compactListFilterView = CompactListFilterView(values: items)
        compactListFilterView.addTarget(self, action: #selector(compactListFilterViewValueChanged(_:)), for: .valueChanged)
        return compactListFilterView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        addSubview(compactListFilterView)
        compactListFilterView.fillInSuperview(insets: UIEdgeInsets(top: .mediumLargeSpacing, left: 27, bottom: 0, right: -27))
    }

    @objc func compactListFilterViewValueChanged(_ sender: CompactListFilterView) {
        print("Selected values changed. Values:  \(sender.selectedValues ?? [])")
    }
}
