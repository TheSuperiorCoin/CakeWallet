import UIKit

extension UIView {
    func applyGradient(colours: [UIColor]) -> Void {
        self.applyGradient(colours: colours, locations: nil)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.cornerRadius = frame.size.height * 0.25
        self.layer.insertSublayer(gradient, at: 0)
    }
}

final class PrimaryButton: Button {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.applySketchShadow(color: UIColor(hex: 0xdfd0ff), alpha: 0.34, x: 0, y: 11, blur: 20, spread: -6)
        self.applyGradient(colours: [UIColor(red: 161, green: 96, blue: 222), UIColor(red: 90, green: 71, blue: 255)])
    }
}
