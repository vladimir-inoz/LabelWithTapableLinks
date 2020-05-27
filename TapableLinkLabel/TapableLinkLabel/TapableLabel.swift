//
//  TapableLabel.swift
//  TapableLabel
//
//  Created by Vladimir Inozemtsev on 24.04.2020.
//  Copyright © 2020 Vladimir Inozemtsev. All rights reserved.
//

import UIKit

// Implementation from https://stackoverflow.com/q/1256887/7019874

public protocol TapableLabelDelegate: AnyObject {
    func tapableLabel(_ label: TapableLabel, detectedLinkTap: String)
}

public class TapableLabel: UILabel {
    
    private var layoutManager: NSLayoutManager!
    private var textContainer: NSTextContainer!
    private var textStorage: NSTextStorage!
    public weak var delegate: TapableLabelDelegate?
    public var isDebug = false {
        didSet {
            debugLayer.isHidden = isDebug == false
        }
    }
    
    private var debugLayer: CAShapeLayer!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    public override var attributedText: NSAttributedString? {
        didSet {
            guard let attributedString = attributedText else { return }
            textStorage.setAttributedString(attributedString)
        }
    }
    
    public override var lineBreakMode: NSLineBreakMode {
        didSet {
            textContainer.lineBreakMode = lineBreakMode
        }
    }
    
    public override var numberOfLines: Int {
        didSet {
            textContainer.maximumNumberOfLines = numberOfLines
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        textContainer.size = bounds.size

        if isDebug {
            let combinedPath = CGMutablePath()

            glyphs().forEach {
                combinedPath.addPath(CGPath(rect: $0, transform: nil))
            }

            debugLayer.path = combinedPath
        }
    }
    
    private func setupUI() {
        layoutManager = NSLayoutManager()
        
        textContainer = NSTextContainer(size: .zero)
        textContainer.lineFragmentPadding = 0.0
        
        textStorage = NSTextStorage()

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
    
        isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapActionHandler))
        addGestureRecognizer(tapGestureRecognizer)
        
        debugLayer = CAShapeLayer()
        debugLayer.fillColor = UIColor(displayP3Red: 1, green: 0, blue: 0, alpha: 0.5).cgColor
        debugLayer.strokeColor = UIColor.red.cgColor
        layer.addSublayer(debugLayer)
    }
    
    @objc private func tapActionHandler(sender: UITapGestureRecognizer) {
        guard let attributedText = self.attributedText else { return }
        let point = sender.location(in: self)
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttributes(in: range, options: []) { [weak self] attributes, range, _ in

            guard let self = self,
                let link = attributes[.link],
                doesPoint(withCoordinates: point, intersectsTextInRange: range) else { return }
            
            if let urlLink = link as? URL {
                self.delegate?.tapableLabel(self, detectedLinkTap: urlLink.absoluteString)
            } else if let stringLink = link as? String {
                self.delegate?.tapableLabel(self, detectedLinkTap: stringLink)
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
    
    private func doesPoint(withCoordinates point: CGPoint, intersectsTextInRange targetRange: NSRange) -> Bool {
        // Find the tapped character location and compare it to the specified range
        let offset = textContainerOffset(forAlignment: textAlignment)
        let locationOfTouchInTextContainer = CGPoint(x: point.x - offset.x, y: point.y - offset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer,
                                                            in: textContainer,
                                                            fractionOfDistanceBetweenInsertionPoints: nil)

        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}

// MARK: - Debug

private extension TapableLabel {
    private func glyphs() -> [CGRect] {
        return (0..<layoutManager.numberOfGlyphs).map { index in
            let range = NSRange(location: index, length: 1)
            let sourceRect = layoutManager.boundingRect(forGlyphRange: range, in: textContainer)
            let offset = textContainerOffset(forAlignment: textAlignment)
            return sourceRect.offsetBy(dx: offset.x, dy: offset.y)
        }
    }
}
