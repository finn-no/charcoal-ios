//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal
import FinniversKit

class OnboardingViewController: UIViewController {

    // MARK: - Private properties

    private lazy var viewControllers: [UIViewController] = [
        OnboardingPage(imageName: "group", attributedString: highlightedText(forKey: "onboarding.pages.0")),
        OnboardingPage(imageName: "group", attributedString: highlightedText(forKey: "onboarding.pages.1")),
        OnboardingPage(imageName: "group", attributedString: highlightedText(forKey: "onboarding.pages.2")),
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

    private lazy var pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.setViewControllers([viewControllers.first!], direction: .forward, animated: false)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        return pageViewController
    }()

    private var currentIndex = 0

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - Actions

    @objc private func previousButtonPressed(sender: UIButton) {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        pageViewController.setViewControllers([viewControllers[currentIndex]], direction: .reverse, animated: true)
    }

    @objc private func nextButtonPressed(sender: UIButton) {
        guard currentIndex < viewControllers.count - 1 else { return }
        currentIndex += 1
        pageViewController.setViewControllers([viewControllers[currentIndex]], direction: .forward, animated: true)
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let viewController = pendingViewControllers.first else { return }
        guard let index = viewControllers.firstIndex(of: viewController) else { return }

        switch index {
        case viewControllers.startIndex:
            previousButton.isHidden = true
        case viewControllers.endIndex - 1:
            nextButton.isHidden = true
        default:
            previousButton.isHidden = false
            nextButton.isHidden = false
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }

        guard let viewController = pageViewController.viewControllers?.first else { return }
        guard let index = viewControllers.firstIndex(of: viewController) else { return }

        currentIndex = index
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let indexBefore = currentIndex - 1
        guard currentIndex > 0 else { return nil }
        return viewControllers[indexBefore]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let indexAfter = currentIndex + 1
        guard currentIndex < viewControllers.count - 1 else { return nil }
        return viewControllers[indexAfter]
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return viewControllers.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentIndex
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
        let pageController = UIPageControl.appearance()
        pageController.pageIndicatorTintColor = .sardine
        pageController.currentPageIndicatorTintColor = .primaryBlue

        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)

        view.addSubview(previousButton)
        view.addSubview(nextButton)

        NSLayoutConstraint.activate([
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .mediumLargeSpacing),
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: .mediumLargeSpacing),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.mediumLargeSpacing),
            pageViewController.view.bottomAnchor.constraint(equalTo: previousButton.topAnchor, constant: -.mediumLargeSpacing),

            previousButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .mediumSpacing),
            previousButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -.mediumSpacing),

            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.mediumSpacing),
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -.mediumSpacing),
        ])
    }
}
