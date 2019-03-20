//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal
import FinniversKit

public protocol OnboardingViewControllerDelegate: AnyObject {
    func onboardingViewController(_ viewController: OnboardingViewController, didFinishWithStatus complete: Bool)
}

public class OnboardingViewController: UIViewController {

    // MARK: - Public properties

    public weak var delegate: OnboardingViewControllerDelegate?

    // MARK: - Private properties

    private lazy var content = [
        OnboardingCellViewModel(imageName: "group", attributedString: highlightedText(forKey: "onboarding.content.0")),
        OnboardingCellViewModel(imageName: "group", attributedString: highlightedText(forKey: "onboarding.content.1")),
        OnboardingCellViewModel(imageName: "group", attributedString: highlightedText(forKey: "onboarding.content.2")),
    ]

    // Used to animate alpha and position
    private let nextButtonKeyFrames: [CGFloat] = [1, 1, 0]
    private let previousButtonKeyFrames: [CGFloat] = [0, 1, 0]
    private let doneButtonKeyFrames: [CGFloat] = [0, 0, 1]

    private lazy var doneButtonBottomConstraint = doneButton.topAnchor.constraint(equalTo: view.bottomAnchor)

    private lazy var previousButton: Button = {
        let button = Button(style: .flat)
        button.setTitle("onboarding.button.previous".localized(), for: .normal)
        button.addTarget(self, action: #selector(previousButtonPressed(sender:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var nextButton: Button = {
        let button = Button(style: .flat)
        button.setTitle("onboarding.button.next".localized(), for: .normal)
        button.addTarget(self, action: #selector(nextButtonPressed(sender:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var doneButton: Button = {
        let button = Button(style: .callToAction)
        button.setTitle("onboarding.button.done".localized(), for: .normal)
        button.addTarget(self, action: #selector(doneButtonPressed(sender:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var skipButton: Button = {
        let button = Button(style: .flat)
        button.setTitle("onboarding.button.skip".localized(), for: .normal)
        button.addTarget(self, action: #selector(skipButtonPressed(sender:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl(withAutoLayout: true)
        pageControl.numberOfPages = content.count
        pageControl.pageIndicatorTintColor = .sardine
        pageControl.currentPageIndicatorTintColor = .primaryBlue
        return pageControl
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
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

    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        previousButton.alpha = 0
        doneButtonBottomConstraint.constant = 36
    }

    // MARK: - Actions

    @objc private func skipButtonPressed(sender: UIButton) {
        delegate?.onboardingViewController(self, didFinishWithStatus: false)
    }

    @objc private func doneButtonPressed(sender: UIButton) {
        delegate?.onboardingViewController(self, didFinishWithStatus: true)
    }

    @objc private func previousButtonPressed(sender: UIButton) {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        pageControl.currentPage = currentIndex

        let indexPath = IndexPath(item: currentIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }

    @objc private func nextButtonPressed(sender: UIButton) {
        guard currentIndex < content.count - 1 else { return }
        currentIndex += 1
        pageControl.currentPage = currentIndex

        let indexPath = IndexPath(item: currentIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
}

extension OnboardingViewController: UICollectionViewDelegateFlowLayout {
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        currentIndex = Int(targetContentOffset.pointee.x / scrollView.frame.width)
        pageControl.currentPage = currentIndex
        enableButtons(true)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        enableButtons(false)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let animationPosition = scrollView.contentOffset.x / scrollView.frame.width
        let previousButtonValue = animationValue(forKeyFrames: previousButtonKeyFrames, atPosition: animationPosition)
        previousButton.alpha = pow(previousButtonValue, 2)

        let nextButtonValue = animationValue(forKeyFrames: nextButtonKeyFrames, atPosition: animationPosition)
        nextButton.alpha = pow(nextButtonValue, 2)

        let doneButtonValue = animationValue(forKeyFrames: doneButtonKeyFrames, atPosition: animationPosition)
        doneButton.alpha = pow(doneButtonValue, 2)
        doneButtonBottomConstraint.constant = -(44 + 36) * doneButtonValue + 36
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

extension OnboardingViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return content.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(OnboardingCell.self, for: indexPath)
        cell.configure(with: content[indexPath.item])
        return cell
    }
}

private extension OnboardingViewController {
    func enableButtons(_ enable: Bool) {
        nextButton.isUserInteractionEnabled = enable
        previousButton.isUserInteractionEnabled = enable
        doneButton.isUserInteractionEnabled = enable
    }

    func animationValue(forKeyFrames frames: [CGFloat], atPosition position: CGFloat) -> CGFloat {
        let frame = Int(position)

        if frame < frames.startIndex {
            return frames.first ?? 0
        }

        if frame + 1 >= frames.endIndex {
            return frames.last ?? 0
        }

        let change = frames[frame + 1] - frames[frame]
        let percentage = position - CGFloat(frame)

        return change * percentage + frames[frame]
    }

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
        view.addSubview(skipButton)
        view.addSubview(pageControl)
        view.addSubview(previousButton)
        view.addSubview(nextButton)
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: previousButton.topAnchor, constant: -.largeSpacing),

            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.mediumSpacing),
            skipButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),

            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.centerYAnchor.constraint(equalTo: collectionView.bottomAnchor),

            previousButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .mediumSpacing),
            previousButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -.mediumSpacing),

            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.mediumSpacing),
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -.mediumSpacing),

            doneButtonBottomConstraint,
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .mediumLargeSpacing),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.mediumLargeSpacing),
        ])
    }
}
