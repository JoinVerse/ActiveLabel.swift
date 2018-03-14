//
//  ActiveLabel.swift
//  ActiveLabel
//
//  Created by Johannes Schickling on 9/4/15.
//  Copyright © 2015 Optonaut. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable open class ActiveLabel: UILabel {

    private var customizing: Bool = true
    private var heightCorrection: CGFloat = 0
    private lazy var layoutManager = NSLayoutManager()
    private lazy var textContainer = NSTextContainer()
    let textStorage = NSTextStorage()
    public var tapHandler: ((String) -> Void)?

    public var highlightedRange: NSRange? {
        didSet {
            guard highlightedRange != oldValue else { return }
            setNeedsDisplay()
        }
    }

    override open var text: String? {
        didSet {
            attributedText = text.map(NSAttributedString.init(string:))
        }
    }

    override open var attributedText: NSAttributedString? {
        didSet { updateTextStorage() }
    }

    public var activeElements = [String: NSRange]() {
        didSet { updateTextStorage() }
    }

    override open var font: UIFont! {
        didSet { updateTextStorage() }
    }
    
    override open var textColor: UIColor! {
        didSet { updateTextStorage() }
    }
    
    override open var textAlignment: NSTextAlignment {
        didSet { updateTextStorage()}
    }

    open override var numberOfLines: Int {
        didSet { textContainer.maximumNumberOfLines = numberOfLines }
    }

    open override var lineBreakMode: NSLineBreakMode {
        didSet { textContainer.lineBreakMode = lineBreakMode }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        customizing = false
        setupLabel()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customizing = false
        setupLabel()
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        updateTextStorage()
    }

    override open func drawText(in rect: CGRect) {
        drawHighlightIfNeeded(in: rect)

        let range = NSRange(location: 0, length: textStorage.length)
        textContainer.size = rect.size
        let newOrigin = textOrigin(inRect: rect)

        layoutManager.drawBackground(forGlyphRange: range, at: newOrigin)
        layoutManager.drawGlyphs(forGlyphRange: range, at: newOrigin)
    }

    private func drawHighlightIfNeeded(in rect: CGRect) {
        guard let highlightedRange = highlightedRange, let highlightedTextColor = highlightedTextColor else { return }

        highlightedTextColor.setFill()

        layoutManager.enumerateEnclosingRects(forGlyphRange: highlightedRange, withinSelectedGlyphRange: highlightedRange, in: textContainer) { (selectionRect, _) in
            let path = UIBezierPath(roundedRect: selectionRect.insetBy(dx: -1, dy: 0).intersection(rect), cornerRadius: 2)
            path.fill()
        }
    }

    // MARK: - Customzation

    public func customize(_ block: () -> Void) {
        customizing = true
        block()
        customizing = false
        updateTextStorage()
    }

    // MARK: - Helpers

    private func setupLabel() {
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines
        isUserInteractionEnabled = true
    }

    private func updateTextStorage() {
        if customizing { return }
        // clean up previous active elements
        guard let attributedText = attributedText, attributedText.length > 0 else {
            textStorage.setAttributedString(NSAttributedString())
            setNeedsDisplay()
            return
        }

        let finalAttributedText = addDefaultAttributes(attributedText)
        textStorage.setAttributedString(finalAttributedText)

        customizing = true
        self.attributedText = finalAttributedText
        customizing = false
        setNeedsDisplay()
    }

    private func textOrigin(inRect rect: CGRect) -> CGPoint {
        let usedRect = layoutManager.usedRect(for: textContainer)
        heightCorrection = (rect.height - usedRect.height) / 2
        let glyphOriginY = heightCorrection > 0 ? rect.origin.y + heightCorrection : rect.origin.y
        return CGPoint(x: rect.origin.x, y: glyphOriginY)
    }

    private func addDefaultAttributes(_ attributedString: NSAttributedString) -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment

        let attributes: [NSAttributedStringKey: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: font,
            .foregroundColor: textColor
        ]

        let mutableAttributedString = NSMutableAttributedString(string: attributedString.string, attributes: attributes)
        attributedString.enumerateAttributes(in: NSRange(location: 0, length: attributedString.length), options: []) { (attributes, range, _) in
            mutableAttributedString.addAttributes(attributes, range: range)
        }

        return mutableAttributedString
    }

    private func element(at location: CGPoint) -> (key: String, range: NSRange)? {
        guard textStorage.length > 0 else {
            return nil
        }

        var correctLocation = location
        correctLocation.y -= heightCorrection
        let boundingRect = layoutManager.boundingRect(forGlyphRange: NSRange(location: 0, length: textStorage.length), in: textContainer)
        guard boundingRect.contains(correctLocation) else {
            return nil
        }

        let index = layoutManager.glyphIndex(for: correctLocation, in: textContainer)
        
        for (key, range) in activeElements {
            if index >= range.location && index <= range.location + range.length {
                return (key: key, range: range)
            }
        }

        return nil
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        highlightedRange = nil
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if let element = element(at: location) {
            tapHandler?(element.key)
            super.touchesCancelled(touches, with: event)
        } else {
            super.touchesEnded(touches, with: event)
        }
    }

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if let element = element(at: location) {
            highlightedRange = element.range
        }

        super.touchesBegan(touches, with: event)
    }
}

extension ActiveLabel: UIGestureRecognizerDelegate {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
