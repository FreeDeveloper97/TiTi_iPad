import UIKit

let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
let bounds = view.bounds
let frame = view.frame

func drawCircle(view: UIView, startingAngle: CGFloat, endAngle: CGFloat) -> CAShapeLayer {
    let path = UIBezierPath(arcCenter: view.center, radius: CGFloat((view.bounds.size.height/2)-10), startAngle: startingAngle, endAngle: endAngle, clockwise: true)
    
    let shapeLayer = CAShapeLayer()
    shapeLayer.path = path.cgPath
    
    shapeLayer.strokeColor = UIColor.black.cgColor
    shapeLayer.lineWidth = 10.0
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.lineCap = .round
    view.layer.addSublayer(shapeLayer)
    return shapeLayer
}

let layer = drawCircle(view: view, startingAngle: CGFloat(0), endAngle: CGFloat(M_PI*3/2))

view
