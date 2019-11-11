//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit

final class ListFilterImageView: UIView {
    enum State: Int {
        case normal
        case disabled
    }

    var isEnabled = true {
        didSet {
            updateImageView()
        }
    }

    private var stateImages = [State: UIImage]()

    private lazy var imageView: UIImageView = {
        let view = UIImageView(withAutoLayout: true)
        view.backgroundColor = Theme.mainBackground
        return view
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    func setImage(_ image: UIImage?, for states: State...) {
        for state in states {
            stateImages[state] = image
        }
    }

    private func setup() {
        backgroundColor = Theme.mainBackground

        addSubview(imageView)
        imageView.fillInSuperview()
        updateImageView()
    }

    private func updateImageView() {
        let state: State = isEnabled ? .normal : .disabled
        imageView.image = stateImages[state]
        isHidden = imageView.image == nil
    }
}
