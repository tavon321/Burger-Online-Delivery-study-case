//
//  BurgerListCell.swift
//  BurgerList-iOS
//
//  Created by Gustavo on 3/08/21.
//

import UIKit

class BurgerListCell: UITableViewCell {
    @IBOutlet private(set) var imageContainer: UIView!
    @IBOutlet private(set) var burgerImageView: UIImageView!
    @IBOutlet private(set) var titleLabel: UILabel!
    @IBOutlet private(set) var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        burgerImageView.alpha = 0
        imageContainer.startShimmering()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        burgerImageView.alpha = 0
        imageContainer.startShimmering()
    }
    
    func fadeIn(_ image: UIImage?) {
        burgerImageView.image = image
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0.3,
            usingSpringWithDamping: 0.25,
            initialSpringVelocity: 1.25,
            options: [],
            animations: {
                self.burgerImageView.alpha = 1
            }, completion: { completed in
                if completed {
                    self.imageContainer.stopShimmering()
                }
            })
    }
}

private extension UIView {
    private var shimmerAnimationKey: String {
        return "shimmer"
    }
    
    func startShimmering() {
        let white = UIColor.white.cgColor
        let alpha = UIColor.white.withAlphaComponent(0.7).cgColor
        let width = bounds.width
        let height = bounds.height
        
        let gradient = CAGradientLayer()
        gradient.colors = [alpha, white, alpha]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.4)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.6)
        gradient.locations = [0.4, 0.5, 0.6]
        gradient.frame = CGRect(x: -width, y: 0, width: width*3, height: height)
        layer.mask = gradient
        
        let animation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 1
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: shimmerAnimationKey)
    }
    
    func stopShimmering() {
        layer.mask = nil
    }
}
