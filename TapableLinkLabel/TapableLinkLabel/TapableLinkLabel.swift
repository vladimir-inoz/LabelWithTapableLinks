//
//  TapableLinkLabel.swift
//  TapableLinkLabel
//
//  Created by Vladimir Inozemtsev on 24.04.2020.
//  Copyright © 2020 Vladimir Inozemtsev. All rights reserved.
//

import UIKit

// Implementation from https://stackoverflow.com/q/1256887/7019874

public protocol TapableLinkLabelDelegate: AnyObject {
    func tapableLinkLabel(_ label: TapableLinkLabel, openString: String)
    func tapableLinkLabel(_ label: TapableLinkLabel, openURL: URL)
}

public class TapableLinkLabel: UILabel {
    
    private var layoutManager: NSLayoutManager!
    private var textContainer: NSTextContainer!
    private var textStorage: NSTextStorage!
    public weak var delegate: TapableLinkLabelDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapActionHandler))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func makeLayoutManager(string: NSAttributedString) {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        layoutManager = NSLayoutManager()
        textContainer = NSTextContainer(size: .zero)
        textStorage = NSTextStorage(attributedString: string)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        
        textStorage.addLayoutManager(layoutManager)
        if let validFont = font {
            textStorage.addAttribute(.font, value: validFont, range: NSRange(location: 0, length: string.length))
        }

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines
        textContainer.size = bounds.size
    }
    
    @objc private func tapActionHandler(sender: UITapGestureRecognizer) {
        guard let attributedText = self.attributedText else { return }
        makeLayoutManager(string: attributedText)
        let point = sender.location(in: self)
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttributes(in: range, options: []) { [weak self] attributes, range, _ in

            guard let self = self,
                let link = attributes[.link],
                didTapTextInLabel(locationOfTouch: point, inRange: range) else { return }
            
            if let urlLink = link as? URL {
                self.delegate?.tapableLinkLabel(self, openURL: urlLink)
            } else if let stringLink = link as? String {
                self.delegate?.tapableLinkLabel(self, openString: stringLink)
            }
        }
    }
    
    private func textContainerOffset(forAlignment alignment: NSTextAlignment) -> CGPoint {
        let ratio: CGFloat
        
        switch alignment {
        case .left:
            ratio = 0
        case .center:
            ratio = 0.5
        case .right:
            ratio = 1
        default:
            ratio = 0
        }
        
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffsetX = (bounds.size.width - textBoundingBox.size.width) * ratio - textBoundingBox.origin.x
        let textContainerOffsetY = (bounds.size.height - textBoundingBox.size.height) * ratio - textBoundingBox.origin.y
        let textContainerOffset = CGPoint(x: textContainerOffsetX, y: textContainerOffsetY)
        return textContainerOffset
    }
    
    private func didTapTextInLabel(locationOfTouch: CGPoint, inRange targetRange: NSRange) -> Bool {
        // Find the tapped character location and compare it to the specified range
        let offset = textContainerOffset(forAlignment: textAlignment)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouch.x - offset.x,
                                                     y: locationOfTouch.y - offset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer,
                                                            in: textContainer,
                                                            fractionOfDistanceBetweenInsertionPoints: nil)

        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}
