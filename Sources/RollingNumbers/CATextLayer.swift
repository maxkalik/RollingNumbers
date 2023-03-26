//  Created by Maksim Kalik on 3/26/23.

import UIKit

extension CATextLayer {
    func setForegroundColor(_ color: UIColor, withAnimationDuration duration: CFTimeInterval? = nil) {

        if let duration = duration {
            let animation: CABasicAnimation = CABasicAnimation(keyPath: "foregroundColor")
            animation.fromValue = foregroundColor
            animation.toValue = color.cgColor
            animation.duration = duration
            foregroundColor = color.cgColor
            add(animation, forKey: "foregroundColor")
        } else {
            foregroundColor = color.cgColor
        }
    }
}
