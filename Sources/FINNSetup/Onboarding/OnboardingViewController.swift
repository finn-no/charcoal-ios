//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal
import FinniversKit

class OnboardingViewController: UIViewController {

    // MARK: - Private properties

    private lazy var content = [
        OnboardingCellViewModel(imageName: "group", attributedString: highlightedText(forKey: "onboarding.pages.0")),
        OnboardingCellViewModel(imageName: "group", attributedString: highlightedText(forKey: "onboarding.pages.1")),
        OnboardingCellViewModel(imageName: "group", attributedString: highlightedText(forKey: "onboarding.pages.2")),
    ]

    private lazy var previousButton: UIButton = {
        let button = Button(style: .flat)
        button.setTitle("onboarding.button.previous.title".localized(), for: .normal)
        button.addTarget(self, action: #selector(previousButtonPressed(sender:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var nextButton: UIButton = {
        let button = Button(style: .flat)
        button.setTitle("onboarding.button.next.title".localized(), for: .normal)
        button.addTarget(self, action: #selector(nextButtonPressed(sender:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(OnboardingCell.self)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private var currentIndex = 0

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

        previousButton.alpha = 0
        previousButton.isEnabled = false
    }

    // MARK: - Actions

    @objc private func previousButtonPressed(sender: UIButton) {
        guard currentIndex > 0 else { return }
        currentIndex -= 1

        let indexPath = IndexPath(item: currentIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }

    @objc private func nextButtonPressed(sender: UIButton) {
        guard currentIndex < content.count - 1 else { return }
        currentIndex += 1

        let indexPath = IndexPath(item: currentIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
}

extension OnboardingViewController: UICollectionViewDelegateFlowLayout {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let previousButtonAlphaValue = scrollView.contentOffset.x / scrollView.frame.width
        previousButton.alpha = previousButtonAlphaValue
        previousButton.isEnabled = previousButtonAlphaValue > 0
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

extension OnboardingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return content.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(OnboardingCell.self, for: indexPath)
        cell.configure(with: content[indexPath.item])
        return cell
    }
}

private extension OnboardingViewController {
    func highlightedText(forKey key: String) -> NSAttributedString {
        let text = (key + ".text").localized()

        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.minimumLineHeight = 22

        let attrString = NSMutableAttributedString(string: text,
                                                   attributes: [.font: UIFont.regularBody, .foregroundColor: UIColor.licorice, .kern: 0.3, .paragraphStyle: style])

        for highlighted in highlights(forKey: key) {
            if let range = text.range(of: highlighted) {
                attrString.addAttribute(.font, value: UIFont.boldBody, range: NSRange(range, in: text))
            }
        }

        return attrString
    }

    func highlights(forKey key: String) -> [String] {
        let value = "notFound"
        var highlights = [String]()

        var index = 0
        while true {
            let string = NSLocalizedString(key + ".highlights.\(index)", bundle: Bundle.finnSetup, value: value, comment: "")

            if string != value {
                highlights.append(string)
                index += 1
            } else {
                break
            }
        }

        return highlights
    }

    func setup() {
        view.addSubview(collectionView)
        view.addSubview(previousButton)
        view.addSubview(nextButton)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: previousButton.topAnchor, constant: -.mediumLargeSpacing),

            previousButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .mediumSpacing),
            previousButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -.mediumSpacing),

            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.mediumSpacing),
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -.mediumSpacing),
        ])
    }
}
