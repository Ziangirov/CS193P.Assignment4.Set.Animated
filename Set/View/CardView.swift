//
//  CardView.swift
//  Set
//
//  Created by Evgeniy Ziangirov on 22/06/2018.
//  Copyright © 2018 Evgeniy Ziangirov. All rights reserved.
//

import UIKit

class CardView: UIView {
    
    var number: Card.Number = .two { didSet { setNeedsDisplay(); setNeedsLayout() }}
    var symbol: Card.Symbol = .square { didSet { setNeedsDisplay(); setNeedsLayout() }}
    var color: Card.Color = .red { didSet { setNeedsDisplay(); setNeedsLayout() }}
    var shade: Card.Shade = .striped { didSet { setNeedsDisplay(); setNeedsLayout() }}
    
    var state: SelectionState = .unselected { didSet { setNeedsDisplay(); setNeedsLayout() } }
    var isFaceUp: Bool = true { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    private var boarderColor: UIColor { return state.boarderColor }
    private var pathColor: UIColor { return color.pathColor }
    private var pathRects: [CGRect] { return number.pathRects?(bounds) ?? [CGRect()] }
    
    private var path: UIBezierPath {
        let path = UIBezierPath()
        pathRects.forEach { path.append(symbol.drawPathIn?($0) ?? UIBezierPath()) }
        path.addClip()
        return path }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func drawPips() {
        pathColor.setFill()
        pathColor.setStroke()
        shade.shadingPath(path, bounds)
    }
    
    private func drawCardBack() {
        if let cardBackImage = UIImage(named: "cardback") {
            cardBackImage.draw(in: bounds)
        }
    }
    
    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: bounds,
                                       cornerRadius: cornerRadius)
        boarderColor.setStroke()
        SelectionState.unselected.boarderColor.setFill()
        roundedRect.addClip()
        roundedRect.lineWidth = borderLineWidth
        roundedRect.fill()
        roundedRect.stroke()
        
        isFaceUp ? drawPips() : drawCardBack()
    }
    
    private func setup() {
        backgroundColor = .clear
        contentMode = .redraw
        isOpaque = false
        alpha = 0
        isFaceUp = false
        state = .unselected
    }
    
    func copyCardView() -> CardView {
        let copyCardView = CardView()
        copyCardView.number = number
        copyCardView.symbol = symbol
        copyCardView.color = color
        copyCardView.shade = shade
        copyCardView.state = .unselected
        copyCardView.isFaceUp = true
        
        copyCardView.bounds = bounds
        copyCardView.frame = frame
        copyCardView.alpha = 1
        return copyCardView
    }
    
    func animateDealFrom(_ deckCenter: CGPoint, with delay: TimeInterval) {
        let currentCenter = center
        let currentBounds = bounds
        
        center = deckCenter
        alpha = 1
        bounds = CGRect(x: 0.0, y: 0.0,
                        width: bounds.width * 0.6,
                        height: bounds.height * 0.6)
        isFaceUp = false
        
        UIViewPropertyAnimator
            .runningPropertyAnimator(
                withDuration: 1,
                delay: delay,
                options: [],
                animations: {
                    self.center = currentCenter
                    self.bounds = currentBounds
            },
                completion: { position in
                    UIView
                        .transition(
                            with: self,
                            duration: 0.5,
                            options: {
                                let animationOptions = [UIView.AnimationOptions
                                    .transitionFlipFromBottom,
                                                        .transitionFlipFromTop,
                                                        .transitionFlipFromLeft,
                                                        .transitionFlipFromRight
                                ]
                                return animationOptions[animationOptions.count.arc4random]
                        }(),
                            animations: {
                                self.isFaceUp = true
                        })
            })
    }
}

private extension Card.Symbol {
    var drawPathIn: ((_ rect: CGRect) -> UIBezierPath)? {
        switch self {
        case .triangle:
            return {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: $0.midX, y: $0.minY))
                path.addLine(to: CGPoint(x: $0.maxX, y: $0.maxY))
                path.addLine(to: CGPoint(x: $0.minX, y: $0.maxY))
                path.close()
                return path }
        case .circle:
            return { UIBezierPath(arcCenter: CGPoint(x: $0.midX, y: $0.midY),
                                  radius: $0.height / 2,
                                  startAngle: 0,
                                  endAngle: CGFloat.pi * 2,
                                  clockwise: true) }
        case .square:
            return { UIBezierPath(rect: CGRect(x: $0.origin.x, y: $0.origin.y,
                                               width: $0.width, height: $0.height))
            }
        }
    }
}

private extension Card.Shade {
    var shadingPath: (_ path: UIBezierPath,_ inRect: CGRect) -> () {
        switch self {
        case .filled:
            return {
                _ = $1
                $0.fill()
            }
        case .striped:
            return {
                let rect = $1
                let stripe = UIBezierPath()
                stripe.setLineDash([1, 3], count: [1, 3].count, phase: 0.0)
                stripe.lineWidth = $1.size.width * 2
                stripe.lineCapStyle = .butt
                stripe.move(to: CGPoint(x: rect.maxX, y: rect.minY))
                stripe.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
                stripe.stroke()
                $0.stroke()
            }
        case .outlined:
            return {
                _ = $1
                $0.lineWidth = CardView.Constants.borderWidth
                $0.stroke()
            }
        }
    }
}

private extension Card.Number {
    var pathRects: ((_ rect: CGRect) -> [CGRect])? {
        switch self {
        case .one:
            return { [$0.middleThirdCentered] }
        case .two:
            return { [$0.leftHalfCentered, $0.rightHalfCentered] }
        case .three:
            return { [$0.leftThirdCentered, $0.middleThirdCentered, $0.rightThirdCentered] }
        }
    }
}

extension CardView {
    private struct SizeRatio {
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
        static let cornerOffsetToCornerRadius: CGFloat = 0.33
        static let borderLineWidthToBoundsHeight: CGFloat = 0.1
    }
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    private var lineWidthOutlined: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    private var cornerOffset: CGFloat {
        return cornerRadius * SizeRatio.cornerOffsetToCornerRadius
    }
    fileprivate var borderLineWidth: CGFloat {
        return bounds.size.height * SizeRatio.borderLineWidthToBoundsHeight
    }
    struct Constants {
        static let borderWidth: CGFloat = 3.0
    }
    
    enum SelectionState {
        case hinted
        case selected
        case unselected
    }
}

extension UIColor {
    static let customBackgroud = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
    static let maraschino = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
    static let clover = #colorLiteral(red: 0, green: 0.5603182912, blue: 0, alpha: 1)
    static let maroon = #colorLiteral(red: 0.5808190107, green: 0.0884276256, blue: 0.3186392188, alpha: 1)
}

private extension Card.Color {
    var pathColor: UIColor {
        switch self {
        case .red: return .maraschino
        case .green: return .clover
        case .purple: return .maroon
        }
    }
}

private extension CardView.SelectionState {
    var boarderColor: UIColor {
        switch self {
        case .hinted: return .cyan
        case .selected: return .orange
        case .unselected: return .customBackgroud
        }
    }
}

private extension CGRect {
    var leftThirdCentered: CGRect {
        return CGRect(origin: CGPoint(x: (width / 3 - height / 3), y: maxY / 3),
                      size: CGSize(width: height / 3, height: height / 3))
    }
    var middleThirdCentered: CGRect {
        return leftThirdCentered.offsetBy(dx: (width / 3 - height / 3) / 2 + height / 3, dy: 0.0)
    }
    var rightThirdCentered: CGRect {
        return middleThirdCentered.offsetBy(dx: (width / 3 - height / 3) / 2 + height / 3, dy: 0.0)
    }
    var leftHalfCentered: CGRect {
        return CGRect(origin: CGPoint(x: width / 3 - height / 3 / 2, y: maxY / 3),
                      size: CGSize(width: height / 3, height: height / 3))
    }
    var rightHalfCentered: CGRect {
        return leftHalfCentered.offsetBy(dx: width / 3, dy: 0.0)
    }
    var leftHalf: CGRect {
        return CGRect(x: minX, y: minY, width: width / 2, height: height)
    }
    var reightHalf: CGRect {
        return CGRect(x: midX, y: minY, width: width / 2, height: height)
    }
    
    func inset(by size: CGSize) -> CGRect {
        return insetBy(dx: size.width, dy: size.height)
    }
    
    func sized(to size: CGSize) -> CGRect {
        return CGRect(origin: origin, size: size)
    }
    
    func zoom(by scale: CGFloat) -> CGRect {
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth) / 2, dy: (height - newHeight) / 2)
    }
}

private extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x + dx, y: y + dy)
    }
}
