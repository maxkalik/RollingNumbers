//  Created by Maksim Kalik on 3/19/23.

import UIKit

public final class RollingNumbersView: UIView {

    // MARK: - Public
    
    /// Animation that affect on numbers
    public enum AnimationType {
        /// All numbers roll if even only one number change
        case allNumbers
        
        /// Only changed numbers roll
        case onlyChangedNumbers
        
        /// All numbers roll after first changed number
        case allAfterFirstChangedNumber
        
        /// Numbers change without animation
        case noAnimation
    }
    
    /// Rolling animation direction
    public enum RollingDirection {
        
        /// Rolling animation direction from up to down
        case down
        
        /// Rolling animation direction from down to up
        case up
    }

    /// Numbers alignemnt
    public enum Alignment {
        
        /// Numbers aligned at the center of the view
        case center
        
        /// Numbers aligned by the left side of the view
        case left
        
        /// Numbers aligned by the right side of the view
        case right
    }
    
    /// Rolling Animation Configuration
    public struct AnimationConfiguration {
        
        /// Rolling animation duration `CFTimeInterval`
        /// Default value: `1`
        public var duration: CFTimeInterval
        
        /// Rolling animation speed `Float`
        /// Default value: `0.3`
        public var speed: Float
        
        /// Rolling animation damping `CGFloat`
        /// Default value: `17`
        public var damping: CGFloat
        
        /// Rolling animation initialVelocity `CGFloat`
        /// Default initialVelocity: `1`
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
    
    /// Rolling Animation Configuration of type `AnimationConfiguration` (check `RollingNumbersView.AnimationConfiguration`)
    /// - Default value: `AnimationConfiguration()`
    public var animationConfiguration: AnimationConfiguration = AnimationConfiguration()
    
    /// Animation that affect on numbers. Default value `.allAfterFirstChangedNumber`
    public var animationType: AnimationType? = .allAfterFirstChangedNumber
    
    /// Rolling animation direction
    public var rollingDirection: RollingDirection?
    
    /// Numbers alignemnt  of type `Alignment` (check `RollingNumbersView.Alignment`.
    /// - Default value: `.left`
    public var alignment: Alignment = .left
    
    /// Character spacing  of type `CGFloat`
    /// - Default value: `1`
    public var characterSpacing: CGFloat = 1
    
    /// Numbers font  of type `UIFont`.
    /// - Default value `.systemFont(ofSize: 24, weight: .bold)`
    public var font = UIFont.systemFont(ofSize: 24, weight: .bold)
    
    /// Text color of type `UIColor`.
    /// - Default value: `.black`
    public var textColor: UIColor = .black
    
    /// User Number Formatter to configure numbers
    public var formatter: NumberFormatter?
    
    /// Set text color.
    /// - Parameters:
    ///     - textColor: Text color of type `UIColor`
    ///     - withAnimationDuration: Optional transition duration between existing color and future one. Type `CFTimeInterval`. Default value: `nil`, means without duration.
    public func setTextColor(_ textColor: UIColor, withAnimationDuration duration: CFTimeInterval? = nil) {
        self.textColor = textColor
        self.setForegroundColor(textColor, withAnimationDuration: duration)
    }
    
    /// Set number without animation
    /// - Parameters:
    ///     - double: Number as `Double`
    public func setNumber(_ double: Double) {
        self.number = double
        prepareColumns(rollingDirection: rollingDirection)
        updateColumns(animationType: .noAnimation)
    }

    /// Set number with rolling animation
    /// - Parameters:
    ///     - double: Number as `Double`
    ///     - animationType: check AnimatonType. Default value: `
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
            completion: completion
        )
    }

    /// Text representation of the number
    /// - Note: Read only
    public var text: String {
        prepareText(from: number)
    }

    /// Initialization with frame when default number will be `0`
    public override init(frame: CGRect) {
        self.number = 0
        super.init(frame: frame)
        
        setupCommon()
    }
    
    /// Initialization with number.
    /// - Parameter:
    ///     - number: `Double`
    public init(number: Double = 0) {
        self.number = number
        super.init(frame: .zero)
        
        setupCommon()
    }
    
    /// Calculated with of all number elements
    /// - Note: Read only
    public var width: CGFloat {
        text.reduce(into: Double()) { partialResult, char in
            partialResult += prepareWidthOfChar(char)
        }
    }
    
    /// Height of the number element
    /// - Note: Read only
    public var height: CGFloat {
        frame.height
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        prepareColumns()
        isInitialColumnsPrepared = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
                case .onlyChangedNumbers:
                    if prevDigits.indices.contains(index), prevDigits[index] == columnLayer.digit {
                        columnLayer.setToDigit()
                    } else {
                        columnLayer.setToDigit(isAnimated: true, config: animationConfiguration) {
                            self.setFinishAnimationIfNeeded(&isAnimationFinished, completion: completion)
                        }
                    }
                case .allAfterFirstChangedNumber:
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
                case .allNumbers:
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
