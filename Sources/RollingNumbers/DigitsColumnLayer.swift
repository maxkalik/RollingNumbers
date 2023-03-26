//  Created by Maksim Kalik on 3/19/23.

import UIKit

final class DigitsColumnLayer: CALayer {
    
    let digit: Int
    private let digits = (0...19)
    private let font: UIFont
    private let digitWidth: CGFloat
    private let digitHeight: CGFloat
    private let rollingDirection: RollingNumbersView.RollingDirection
    let foregroundColor: CGColor
    
    init(
        digit: Int,
        font: UIFont,
        digitWidth: CGFloat,
        digitHeight: CGFloat,
        rollingDirection: RollingNumbersView.RollingDirection,
        foregroundColor: CGColor
    ) {
        self.digit = digit
        self.font = font
        self.digitWidth = digitWidth
        self.digitHeight = digitHeight
        self.rollingDirection = rollingDirection
        self.foregroundColor = foregroundColor

        super.init()

        setupCommon()
    }
    
    // We need to have this init because animation involves making a copy of a layer
    // to act as the presentation layer
    override init(layer: Any) {
        self.digit = 0
        self.font = .systemFont(ofSize: 24)
        self.digitWidth = 0
        self.digitHeight = 0
        self.rollingDirection = .up
        self.foregroundColor = UIColor.black.cgColor
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCommon() {

        digits.forEach { digit in
            let textLayer = makeDigitLayer(digit: digit)
            addSublayer(textLayer)
        }
    }
    
    private func makeDigitLayer(digit: Int) -> DigitLayer {
        let layer = DigitLayer(
            digit: digit,
            width: digitWidth,
            height: digitHeight
        )
        layer.foregroundColor = foregroundColor
        layer.fontSize = font.pointSize
        layer.font = font
        return layer
    }
    
    func prepareInitialYPositionForDigit() {
        switch rollingDirection {
        case .down:
            position.y = downstairsPosition
        case .up:
            position.y = upstairsPosition
        }
    }
    
    func setToDigit(isAnimated: Bool = false,
                    config: RollingNumbersView.AnimationConfiguration? = nil,
                    _ completion: (() -> Void)? = nil) {
        if isAnimated, let config = config {
            animate(config: config, completion: completion)
        } else {
            position.y = moveToDigit()
        }
    }
    
    func setForegroundColor(_ color: UIColor, withAnimationDuration duration: CFTimeInterval? = nil) {
        sublayers?.forEach({ layer in
            if let layer = layer as? DigitLayer {
                layer.setForegroundColor(color, withAnimationDuration: duration)
            }
        })
    }
    
    private func moveToDigit() -> CGFloat {
        switch rollingDirection {
        case .down:
            return upstairsPosition
        case .up:
            return downstairsPosition
        }
    }
    
    private var upstairsPosition: CGFloat {
        frame.height / 2 - digitHeight * CGFloat(digit)
    }
    
    private var downstairsPosition: CGFloat {
        digitHeight * CGFloat(digit) * -1
    }
    
    private var isFinished: Bool = false
    
    private func animate(config: RollingNumbersView.AnimationConfiguration,
                         completion: (() -> Void)? = nil) {
        
        CATransaction.begin()
        
        let animation: CASpringAnimation = CASpringAnimation(keyPath: "position.y")
        let fromValue: CGFloat = position.y
        let toValue: CGFloat = moveToDigit()

        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = config.duration
        animation.speed = config.speed
        animation.damping = config.damping
        animation.initialVelocity = config.initialVelocity
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        
        CATransaction.setCompletionBlock {
            completion?()
        }
        
        add(animation, forKey: nil)
        
        CATransaction.commit()
    }
}

