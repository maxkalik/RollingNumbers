//  Created by Maksim Kalik on 3/19/23.

import UIKit

public final class RollingNumbersView: UIView {

    // MARK: - Public
    
    public enum AnimationType {
        case allDigits
        case onlyChangedDigits
        case allAfterFirstChangedDigit
        case noAnimation
    }
    
    public enum RollingDirection {
        case down
        case up
    }

    public enum Alignment {
        case center
        case left
        case right
    }
    
    public struct AnimationConfiguration {
        public var duration: CFTimeInterval
        public var speed: Float
        public var damping: CGFloat
        public var initialVelocity: CGFloat
        
        public init(
            duration: CFTimeInterval = 1,
            speed: Float = 0.3,
            damping: CGFloat = 17,
            initialVelocity: CGFloat = 1
        ) {
            self.duration = duration
            self.speed = speed
            self.damping = damping
            self.initialVelocity = initialVelocity
        }
    }
    
    public var animationConfiguration: AnimationConfiguration = AnimationConfiguration()
    public var animationType: AnimationType? = .allAfterFirstChangedDigit
    public var rollingDirection: RollingDirection?
    public var alignment: Alignment = .left
    public var digitsCompletion: (() -> Void)? = nil
    public var generateFeedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle?
    public var characterSpacing: CGFloat = 1
    public var font = UIFont.systemFont(ofSize: 24, weight: .bold)
    public var textColor: UIColor = .black
    public var formatter: NumberFormatter?
    
    public func setTextColor(_ textColor: UIColor, withAnimationDuration duration: CFTimeInterval? = nil) {
        self.textColor = textColor
        self.setForegroundColor(textColor, withAnimationDuration: duration)
    }
    
    public func setNumber(_ double: Double) {
        self.number = double
        prepareColumns(rollingDirection: rollingDirection)
        updateColumns(animationType: .noAnimation)
    }

    public func setNumberWithAnimation(
        _ double: Double,
        animationType: AnimationType? = nil,
        rollingDirection: RollingDirection? = nil,
        completion: (() -> Void)? = nil
    ) {
        self.presentedHeight = 0
        self.number = double
        
        prepareColumns(rollingDirection: rollingDirection)

        updateColumns(
            animationType: animationType,
            completion: { [weak self] in
                self?.digitsCompletion?()
                completion?()
            }
        )
    }

    public var text: String {
        prepareText(from: number)
    }

    public override init(frame: CGRect) {
        self.number = 0
        super.init(frame: frame)
        
        setupCommon()
    }
    
    public init(number: Double = 0) {
        self.number = number
        super.init(frame: .zero)
        
        setupCommon()
    }
    
    private var width: CGFloat {
        text.reduce(into: Double()) { partialResult, char in
            partialResult += prepareWidthOfChar(char)
        }
    }
    
    private var height: CGFloat {
        frame.height
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if !isInitialColumnsPrepared {
            prepareColumns()
            isInitialColumnsPrepared = true
        }
    }

    // MARK: - Private
    
    private lazy var currentRollingDirection: RollingDirection = defaultRollingDirection
    private var presentedHeight: Int = 0
    private var isInitialColumnsPrepared: Bool = false
    private var currDigits: [Int] = []
    private var prevDigits: [Int] = []
    private var isSubtraсted: Bool = false

    private(set) var number: Double {
        didSet(prev) {
            self.isSubtraсted = (number - prev).sign == .minus
        }
    }
    
    private var defaultRollingDirection: RollingDirection {
        isSubtraсted ? .down : .up
    }
    
    private func setupCommon() {
        clipsToBounds = true
    }
    
    private func setForegroundColor(_ color: UIColor, withAnimationDuration duration: CFTimeInterval? = nil) {
        layer.sublayers?
            .forEach({ sublayer in
                if let charLayer = sublayer as? CharLayer {
                    charLayer.setForegroundColor(color, withAnimationDuration: duration)
                }
                
                if let columnLayer = sublayer as? DigitsColumnLayer {
                    columnLayer.setForegroundColor(textColor, withAnimationDuration: duration)
                }
            })
    }

    private func prepareText(from number: Double) -> String {
        if let formatter = formatter {
            return formatter.string(from: NSNumber(value: number))!
        } else {
            return String(number)
        }
    }
    
    private func prepareWidthOfChar(_ char: Character) -> Double {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = String(char).size(withAttributes: fontAttributes as [NSAttributedString.Key : Any])
        return size.width * characterSpacing
    }
    
    private func clearColumns() {
        prevDigits = currDigits
        // Instead of this - just reset positions
        layer.sublayers?.forEach({ sublayer in
            sublayer.removeFromSuperlayer()
        })
        currDigits.removeAll()
    }

    private func prepareRollingDirection(_ direction: RollingDirection?) -> RollingDirection {
        let rollingDirection = direction ?? self.rollingDirection ?? defaultRollingDirection
        self.currentRollingDirection = rollingDirection
        return rollingDirection
    }
    
    private func prepareXPosition() -> CGFloat {
        switch alignment {
        case .center:
            return (frame.width - width) / 2
        case .left:
            return 0
        case .right:
            return frame.width - width
        }
    }
    
    private func prepareColumns(rollingDirection direction: RollingDirection? = nil) {

        clearColumns()
        
        var xPosition: CGFloat = prepareXPosition()
        let rollingDirection = prepareRollingDirection(direction)

        text.enumerated().forEach { index, char in

            let charWidth = prepareWidthOfChar(char)
            
            if let digit = Int(String(char)) {
                let columnLayer = DigitsColumnLayer(
                    digit: digit,
                    font: font,
                    digitWidth: charWidth,
                    digitHeight: height,
                    rollingDirection: rollingDirection,
                    foregroundColor: textColor.cgColor
                )

                columnLayer.frame = CGRect(
                    x: xPosition,
                    y: 0,
                    width: charWidth,
                    height: height * CGFloat(20)
                )
                
                layer.addSublayer(columnLayer)
                columnLayer.prepareInitialYPositionForDigit()
                currDigits.append(digit)
                
            } else {
                let charLayer = CharLayer(char: char)
                charLayer.fontSize = font.pointSize
                charLayer.font = font
                charLayer.frame = CGRect(
                    x: xPosition,
                    y: 0,
                    width: charWidth,
                    height: height
                )
                charLayer.foregroundColor = textColor.cgColor
                layer.addSublayer(charLayer)
            }
            
            xPosition += charWidth
        }
    }
    
    private func updateColumns(animationType: AnimationType?, completion: (() -> Void)? = nil) {

        var prevIndex: Int?
        var isAnimationFinished = false

        layer.sublayers?
            .compactMap({ $0 as? DigitsColumnLayer })
            .enumerated()
            .forEach({ index, columnLayer in
                switch animationType ?? self.animationType {
                case .onlyChangedDigits:
                    if prevDigits.indices.contains(index), prevDigits[index] == columnLayer.digit {
                        columnLayer.setToDigit()
                    } else {
                        columnLayer.setToDigit(isAnimated: true, config: animationConfiguration) {
                            self.setFinishAnimationIfNeeded(&isAnimationFinished, completion: completion)
                        }
                    }
                case .allAfterFirstChangedDigit:
                    if prevDigits.indices.contains(index), prevDigits[index] != columnLayer.digit {
                        prevIndex = index
                    }
                    
                    if let prevIndex = prevIndex, index >= prevIndex {
                        columnLayer.setToDigit(isAnimated: true, config: animationConfiguration) {
                            self.setFinishAnimationIfNeeded(&isAnimationFinished, completion: completion)
                        }
                    } else {
                        columnLayer.setToDigit()
                    }
                case .allDigits:
                    columnLayer.setToDigit(isAnimated: true, config: animationConfiguration) {
                        self.setFinishAnimationIfNeeded(&isAnimationFinished, completion: completion)
                    }
                default:
                    columnLayer.setToDigit()
                }
            })
    }

    private func setFinishAnimationIfNeeded(_ isAnimationFinished: inout Bool, completion: (() -> Void)?) {
        if isAnimationFinished == false {
            isAnimationFinished = true
            completion?()
        }
    }
}
