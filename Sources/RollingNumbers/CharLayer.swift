//  Created by Maksim Kalik on 3/19/23.

import UIKit

final class CharLayer: CATextLayer {
    
    private let char: Character

    init(char: Character) {
        self.char = char
        super.init()
        setupCommon()
    }

    override init(layer: Any) {
        self.char = "."
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(in ctx: CGContext) {
        let height = bounds.size.height
        let yDiff = (height - fontSize) / 2 - fontSize / 10

        ctx.saveGState()
        ctx.translateBy(x: 0, y: yDiff)
        
        super.draw(in: ctx)
        ctx.restoreGState()
    }
    
    private func setupCommon() {
 
        string = String(char)
        alignmentMode = .center
        isWrapped = true
//        truncationMode = .middle

//        borderColor = UIColor.red.cgColor
//        borderWidth = 1
        
        // It’s perfect for objects that animate around the screen but don’t change in appearance
        shouldRasterize = true
    }
}
