//  Created by Maksim Kalik on 3/19/23.

import UIKit

final class DigitLayer: CATextLayer {
    
    private let digit: Int
    private let height: CGFloat
    private let width: CGFloat
    
    init(digit: Int, width: CGFloat, height: CGFloat) {
        self.digit = digit
        self.width = width
        self.height = height
        
        super.init()
        setupCommon()
    }
    
    override init(layer: Any) {
        self.digit = 0
        self.width = 0
        self.height = 0
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Placing text in the middle of the CALaler context
    override func draw(in ctx: CGContext) {
        let height = bounds.size.height
        let yDiff = (height - fontSize) / 2 - fontSize / 10

        ctx.saveGState()
        ctx.translateBy(x: 0, y: yDiff)
        
        super.draw(in: ctx)
        ctx.restoreGState()
    }
    
    private func setupCommon() {
        frame = CGRect(
            x: 0,
            y: height * CGFloat(digit),
            width: width,
            height: height
        )
        string = String(digit % 10)
        alignmentMode = .center
        isWrapped = true

		shouldRasterize = false
		contentsScale = UIScreen.main.scale
    }
}
