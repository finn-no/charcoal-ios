//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let label = UILabel(frame: view.bounds)
        label.text = "Hello World"
        view.addSubview(label)
    }
}
