//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit

final class LoadingViewController: UIViewController {
    private let backgroundColor: UIColor
    private var presentationDelay = 0.5
    private let loadingIndicatorSize: CGFloat = 40

    private lazy var loadingIndicatorView: LoadingIndicatorView = {
        let activityIndicator = LoadingIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()

    // MARK: - Init

    init(backgroundColor: UIColor = UIColor.bgPrimary.withAlphaComponent(0.8), presentationDelay: Double = 0.5) {
        self.backgroundColor = backgroundColor
        self.presentationDelay = presentationDelay
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = backgroundColor
        view.addSubview(loadingIndicatorView)

        NSLayoutConstraint.activate([
            loadingIndicatorView.widthAnchor.constraint(equalToConstant: loadingIndicatorSize),
            loadingIndicatorView.heightAnchor.constraint(equalToConstant: loadingIndicatorSize),
            loadingIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -.spacingS),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadingIndicatorView.stopAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + presentationDelay) { [weak self] in
            self?.loadingIndicatorView.startAnimating()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        loadingIndicatorView.stopAnimating()
    }
}
