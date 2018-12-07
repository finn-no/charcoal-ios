//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class Segment: UIControl {

    // MARK: - Public properties

    public var selectedItems: [Int] = [] {
        didSet {
            updateSelectedItems()
        }
    }

    public var isMultiSelect = true

    // MARK: - Private properties

    private let isExpandable: Bool
    private let titles: [String]
    private var buttons: [SegmentButton] = []
    private var splitLines: [UIView] = []

    // MARK: - Setup

    public init(titles: [String], isExpandable: Bool = false) {
        self.titles = titles
        self.isExpandable = isExpandable
        super.init(frame: .zero)
        setup(isExpandable: isExpandable)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private methods

private extension Segment {
    func setup(isExpandable: Bool) {
        addButtons(isExpandable: isExpandable)
        addSplitLines()
        layoutButtonsAndLines()
    }

    func updateSelectedItems() {
        buttons.forEach { $0.isSelected = false }
        selectedItems.forEach { buttons[$0].isSelected = true }
    }

    @objc func handleButton(sender: SegmentButton) {
        if isExpandable {
            sender.isSelected = !isSelected
            sendActions(for: .touchUpInside)
            return
        }
        guard let index = buttons.firstIndex(of: sender) else {
            return
        }
        sender.isSelected = !sender.isSelected
        setSelected(sender.isSelected, atIndex: index)
        // Notfify target of event
        sendActions(for: .valueChanged)
        // Hide split lines based on whether the two surrounding buttons are selected or not
        buttons.enumerated().forEach { index, button in
            let isPreviousButtonSelected = buttons[safe: index - 1]?.isSelected ?? false
            let hideLine = isPreviousButtonSelected != button.isSelected
            splitLines[safe: index - 1]?.isHidden = hideLine
        }
    }

    func setSelected(_ isSelected: Bool, atIndex index: Int) {
        if isMultiSelect {
            if isSelected {
                selectedItems.append(index)
            } else {
                selectedItems.removeAll { $0 == index }
            }
        } else {
            selectedItems.removeAll()
            selectedItems.append(index)
            updateSelectedItems()
        }
    }

    func addButtons(isExpandable: Bool) {
        for title in titles {
            let button = SegmentButton(title: title)
            button.isExpandable = isExpandable
            button.addTarget(self, action: #selector(handleButton(sender:)), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            addSubview(button)
            buttons.append(button)
        }
        // Set positions of the button to draw correct borders
        buttons.first?.borderStyle = .first
        buttons.last?.borderStyle = buttons.count == 1 ? .single : .last
    }

    func addSplitLines() {
        guard buttons.count > 0 else {
            return
        }
        for _ in 1 ..< buttons.count {
            let splitLine = UIView(frame: .zero)
            splitLine.backgroundColor = SegmentButton.borderColor
            splitLine.translatesAutoresizingMaskIntoConstraints = false
            addSubview(splitLine)
            splitLines.append(splitLine)
        }
    }

    func layoutButtonsAndLines() {
        var previousLeadingAnchor = leadingAnchor
        // Going to look like: b|b|b
        buttons.enumerated().forEach { index, button in
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: topAnchor),
                button.leadingAnchor.constraint(equalTo: previousLeadingAnchor),
                button.heightAnchor.constraint(equalTo: heightAnchor),
            ])
            previousLeadingAnchor = button.trailingAnchor
            // layout split line
            guard let line = splitLines[safe: index] else {
                return
            }
            NSLayoutConstraint.activate([
                line.topAnchor.constraint(equalTo: topAnchor),
                line.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: SegmentButton.borderWidth / 2),
                line.heightAnchor.constraint(equalTo: heightAnchor),
                line.widthAnchor.constraint(equalToConstant: SegmentButton.borderWidth),
            ])
        }
        // Need this constraint for the segments frame to be fully defined
        guard let last = buttons.last else {
            return
        }
        last.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
}
