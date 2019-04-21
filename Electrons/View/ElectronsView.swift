import UIKit

protocol ElectronsViewTouchDelegate: class {
  func touch(at point: CGPoint?) -> Void
}

class ElectronsView: UIView {
  private let fillColors: [CGColor] = [UIColor.blue.cgColor,
                                       UIColor.red.cgColor,
                                       UIColor.green.cgColor,
                                       UIColor.purple.cgColor,
                                       UIColor.yellow.cgColor,
                                       UIColor.cyan.cgColor,
                                       UIColor.black.cgColor,
                                       UIColor.brown.cgColor,
                                       UIColor.orange.cgColor]
  
  weak var touchDelegate: ElectronsViewTouchDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = .lightGray
  }
  
  required init?(coder aDecoder: NSCoder) {
    // Not really needed, but required by UIKit
    fatalError("init(coder:) has not been implemented")
  }
  
  internal func createNewElectronLayer(for id: Int) -> CALayer {
    let layer = CAShapeLayer()
    layer.bounds = CGRect(x: 0, y: 0, width: Electron.radius * 2, height: Electron.radius * 2)
    layer.fillColor = self.fillColors[id % self.fillColors.count]
    let path = UIBezierPath(arcCenter: .init(x: layer.bounds.midX, y: layer.bounds.midY), radius: Electron.radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
    layer.path = path.cgPath
    self.layer.addSublayer(layer)
    return layer
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first?.location(in: self) {
      touchDelegate?.touch(at: touch)
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first?.location(in: self) {
      touchDelegate?.touch(at: touch)
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    touchDelegate?.touch(at: nil)
  }
}

extension CALayer: VisualUpdaterDelegate {
  func positionWasUpdated(_ position: CGPoint) {
    self.position = position
  }
}
