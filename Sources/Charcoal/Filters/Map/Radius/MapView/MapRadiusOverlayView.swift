//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit

final class MapRadiusOverlayView: UIView {
    var radius: CGFloat = 5 {
        didSet {
            widthConstraint.constant = radius * 2
        }
    }

    private lazy var centerPointView: UIView = {
        let view = UIView(withAutoLayout: true)
        view.backgroundColor = MapRadiusOverlayView.overlayColor
        return view
    }()

    private lazy var radiusView: UIView = {
        let view = UIView(withAutoLayout: true)
        view.backgroundColor = MapRadiusOverlayView.overlayColor.withAlphaComponent(0.1)
        view.layer.borderColor = MapRadiusOverlayView.overlayColor.cgColor
        view.layer.borderWidth = 3
        return view
    }()

    private lazy var widthConstraint = radiusView.widthAnchor.constraint(equalToConstant: radius * 2)

    static let overlayColor: UIColor = .accentSecondaryBlue

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override func layoutSubviews() {
        super.layoutSubviews()
        centerPointView.layer.cornerRadius = centerPointView.bounds.size.width / 2
        radiusView.layer.cornerRadius = radiusView.bounds.size.width / 2
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .clear
        clipsToBounds = true
        isUserInteractionEnabled = false

        addSubview(radiusView)
        addSubview(centerPointView)

        NSLayoutConstraint.activate([
            radiusView.centerXAnchor.constraint(equalTo: centerXAnchor),
            radiusView.centerYAnchor.constraint(equalTo: centerYAnchor),
            radiusView.heightAnchor.constraint(equalTo: radiusView.widthAnchor),
            widthConstraint,

            centerPointView.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerPointView.centerYAnchor.constraint(equalTo: centerYAnchor),
            centerPointView.widthAnchor.constraint(equalToConstant: 6),
            centerPointView.heightAnchor.constraint(equalTo: centerPointView.widthAnchor),
        ])
    }
}
