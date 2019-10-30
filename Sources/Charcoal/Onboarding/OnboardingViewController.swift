//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit

public protocol OnboardingViewControllerDelegate: AnyObject {
    func onboardingViewController(_ viewController: OnboardingViewController, didFinishWith status: OnboardingViewController.Status)
}

public class OnboardingViewController: UIViewController {
    public enum Status {
        case skip(Int)
        case done
    }

    // MARK: - Public properties

    public weak var delegate: OnboardingViewControllerDelegate?

    public var currentPage: Int {
        return pageControl.currentPage
    }

    // MARK: - Private properties

    private lazy var content = [
        OnboardingCellViewModel(imageAsset: .onboarding1, attributedString: highlightedText(forKey: "onboarding.content.0")),
        OnboardingCellViewModel(imageAsset: .onboarding2, attributedString: highlightedText(forKey: "onboarding.content.1")),
        OnboardingCellViewModel(imageAsset: .onboarding3, attributedString: highlightedText(forKey: "onboarding.content.2")),
    ]

    // Used to animate alpha and position
    private let skipButtonKeyFrames: [CGFloat] = [1, 1, 0]
    private let nextButtonKeyFrames: [CGFloat] = [1, 1, 0]
    private let previousButtonKeyFrames: [CGFloat] = [0, 1, 0]
    private let doneButtonKeyFrames: [CGFloat] = [0, 0, 1]

    private lazy var doneButtonBottomConstraint = doneButton.topAnchor.constraint(equalTo: view.bottomAnchor)

    private var doneButtonBottomInset: CGFloat {
        return UIScreen.main.bounds.height >= 812 ? 36 : 0
    }

    private lazy var previousButton: Button = {
        let button = Button(style: .flat)
        button.setTitle("back".localized(), for: .normal)
        button.addTarget(self, action: #selector(previousButtonPressed(sender:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var nextButton: Button = {
        let button = Button(style: .flat)
        button.setTitle("next".localized(), for: .normal)
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
        button.setTitle("skip".localized(), for: .normal)
        button.addTarget(self, action: #selector(skipButtonPressed(sender:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl(withAutoLayout: true)
        pageControl.numberOfPages = content.count
        pageControl.pageIndicatorTintColor = .sardine
        pageControl.currentPageIndicatorTintColor = .btnPrimary
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

    // MARK: - Life cycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        previousButton.alpha = 0
        doneButtonBottomConstraint.constant = doneButtonBottomInset
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

// MARK: - Actions

private extension OnboardingViewController {
    @objc func skipButtonPressed(sender: UIButton) {
        delegate?.onboardingViewController(self, didFinishWith: .skip(pageControl.currentPage))
    }

    @objc func doneButtonPressed(sender: UIButton) {
        delegate?.onboardingViewController(self, didFinishWith: .done)
    }

    @objc func previousButtonPressed(sender: UIButton) {
        guard pageControl.currentPage > 0 else { return }
        pageControl.currentPage -= 1

        let indexPath = IndexPath(item: pageControl.currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }

    @objc func nextButtonPressed(sender: UIButton) {
        guard pageControl.currentPage < content.count - 1 else { return }
        pageControl.currentPage += 1

        let indexPath = IndexPath(item: pageControl.currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension OnboardingViewController: UICollectionViewDelegateFlowLayout {
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        pageControl.currentPage = Int(targetContentOffset.pointee.x / scrollView.frame.width)
        enableButtons(true)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        enableButtons(false)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let animationPosition = scrollView.contentOffset.x / scrollView.frame.width

        let skipButtonValue = animationValue(forKeyFrames: skipButtonKeyFrames, atPosition: animationPosition)
        skipButton.alpha = pow(skipButtonValue, 2)

        let previousButtonValue = animationValue(forKeyFrames: previousButtonKeyFrames, atPosition: animationPosition)
        previousButton.alpha = pow(previousButtonValue, 2)

        let nextButtonValue = animationValue(forKeyFrames: nextButtonKeyFrames, atPosition: animationPosition)
        nextButton.alpha = pow(nextButtonValue, 2)

        let doneButtonValue = animationValue(forKeyFrames: doneButtonKeyFrames, atPosition: animationPosition)
        doneButton.alpha = pow(doneButtonValue, 2)
        doneButtonBottomConstraint.constant = -(60 + doneButtonBottomInset) * doneButtonValue + doneButtonBottomInset
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

// MARK: - UICollectionViewDataSource

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

// MARK: - Private methods

private extension OnboardingViewController {
    func enableButtons(_ enable: Bool) {
        skipButton.isUserInteractionEnabled = enable
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
                                                   attributes: [.font: UIFont.body, .foregroundColor: UIColor.licorice, .kern: 0.3, .paragraphStyle: style])

        let title = (key + ".title").localized()
        if let range = text.range(of: title) {
            attrString.addAttribute(.font, value: UIFont.title3, range: NSRange(range, in: text))
        }

        let highlight = (key + ".highlight").localized()
        if let range = text.range(of: highlight) {
            attrString.addAttribute(.font, value: UIFont.bodyStrong, range: NSRange(range, in: text))
        }

        return attrString
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
            skipButton.topAnchor.constraint(equalTo: view.topAnchor, constant: -.mediumSpacing),

            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.centerYAnchor.constraint(equalTo: collectionView.bottomAnchor),

            previousButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .mediumSpacing),
            previousButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -.mediumLargeSpacing),

            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.mediumSpacing),
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -.mediumLargeSpacing),

            doneButtonBottomConstraint,
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .mediumLargeSpacing),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.mediumLargeSpacing),
        ])
    }
}
