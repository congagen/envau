import Foundation
import UIKit


class UIElementAppreneceTools {
    
    
    func addGradient(inputView: UIView, colorA: UIColor, colorB: UIColor) {
        let gradient = CAGradientLayer()
        gradient.frame = inputView.bounds
        gradient.colors = [colorB.cgColor, colorA.cgColor]
        gradient.startPoint = CGPoint(x:0, y:0)
        gradient.endPoint = CGPoint(x:0, y:1)
        inputView.layer.insertSublayer(gradient, at: 0)
    }
    
    
    func roundSpecificCorners(viewsToAlter: [UIView], radius: Double, corners: UIRectCorner) {
        
        for view in viewsToAlter {
            let maskPAth1 = UIBezierPath(roundedRect: view.bounds,
                                         byRoundingCorners: corners,
                                         cornerRadii:CGSize(width: radius, height: radius))
            
            let maskLayer1 = CAShapeLayer()
            maskLayer1.frame = view.bounds
            maskLayer1.path = maskPAth1.cgPath
            view.layer.mask = maskLayer1
        }
    }
    
    
    func squareToCircle(cView: UIView) {
        let viewSize = cView.frame.size.width

        cView.layer.masksToBounds = true
        cView.layer.cornerRadius = viewSize / 2
    }
    
    
    func roundCorners (cView: UIView, cornerRadius: Double) {
        cView.layer.masksToBounds = true
        cView.layer.cornerRadius = CGFloat(cornerRadius)
    }

    
    func addViewShadow(cView: UIView, shadowRadius: Double, shadowOpacity: Double, shadowColor: UIColor, offsets: [Int]) {
        cView.layer.masksToBounds = false
        cView.layer.shadowColor = UIColor.black.cgColor
        cView.layer.shadowOpacity = Float(shadowOpacity)
        cView.layer.shadowOffset = CGSize(width: offsets[0], height: offsets[1])
        cView.layer.shadowRadius = CGFloat(shadowOpacity)
        cView.layer.shadowPath = UIBezierPath(rect: cView.layer.bounds).cgPath
    }
    
    
    func styleBtn(uiBtn: UIButton, radiusDiv: CGFloat, bgColor: UIColor, borderColor: UIColor, borderWidth: CGFloat) {
        let btnSize = uiBtn.frame.size.height
        
        uiBtn.layer.masksToBounds = true
        uiBtn.layer.cornerRadius = btnSize / radiusDiv
        uiBtn.layer.backgroundColor = bgColor.cgColor
        uiBtn.layer.borderWidth = borderWidth
        uiBtn.layer.borderColor = borderColor.cgColor
    }
    
    
    func styleView_a(vi: UIStackView) {
        vi.layer.shadowOffset = CGSize(width: 10, height: 10)
        vi.layer.shadowColor = UIColor.black.cgColor
        vi.layer.shadowRadius = 10
        vi.layer.shadowOpacity = 1
    }
    
    
    func styleView_b(cView: UIView, radiusDiv: CGFloat, bgColor: UIColor, borderColor: UIColor, borderWidth: CGFloat) {
        let viewSize = cView.frame.size.width
        
        cView.layer.masksToBounds = true
        cView.layer.cornerRadius = viewSize / radiusDiv
        cView.layer.backgroundColor = bgColor.cgColor
        cView.layer.borderWidth = borderWidth
        cView.layer.borderColor = borderColor.cgColor
    }
    
    
}
