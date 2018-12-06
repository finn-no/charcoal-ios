//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class Segment: UIControl {
    var selectedItems: [Int] = [] {
        didSet {
            updateSelected()
        }
    }

    private let isExpandable: Bool
    private let titles: [String]
    private var buttons: [SegmentButton] = []
    private var splitLines: [UIView] = []

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

private extension Segment {
    func setup(isExpandable: Bool) {
        addButtons(isExpandable: isExpandable)
        addSplitLines()
        layoutButtonsAndLines()
    }

    func updateSelected() {
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
        // Update the selected values
        if sender.isSelected {
            selectedItems.append(index)
        } else {
            selectedItems.removeAll { $0 == index }
        }
        // Notfify target of event
        sendActions(for: .valueChanged)
        // Hide split lines based on whether the two surrounding buttons are selected or not
        for i in buttons.startIndex ..< buttons.endIndex - 1 {
            if (buttons[i].isSelected && buttons[i + 1].isSelected) ||
                (!buttons[i].isSelected && !buttons[i + 1].isSelected) {
                splitLines[i].isHidden = false
            } else {
                splitLines[i].isHidden = true
            }
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
        buttons.first?.position = .first
        buttons.last?.position = buttons.count == 1 ? .none : .last
    }

    func addSplitLines() {
        guard buttons.count > 0 else { return }
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
        var currentIndex = splitLines.startIndex

        for button in buttons {
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: topAnchor),
                button.leadingAnchor.constraint(equalTo: previousLeadingAnchor),
                button.heightAnchor.constraint(equalTo: heightAnchor),
            ])
            previousLeadingAnchor = button.trailingAnchor
            // layout split line
            guard currentIndex != splitLines.endIndex else { continue }
            let line = splitLines[currentIndex]
            currentIndex = splitLines.index(after: currentIndex)

            NSLayoutConstraint.activate([
                line.topAnchor.constraint(equalTo: topAnchor),
                line.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: SegmentButton.borderWidth / 2),
                line.heightAnchor.constraint(equalTo: heightAnchor),
                line.widthAnchor.constraint(equalToConstant: SegmentButton.borderWidth),
            ])
        }
        // Need this constraint to for the segments frame to be fully defined
        guard let last = buttons.last else { return }
        last.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
}
