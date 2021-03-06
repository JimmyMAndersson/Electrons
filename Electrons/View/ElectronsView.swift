import UIKit

protocol ElectronViewTouchDelegate: class {
  func touch(at point: CGPoint?)
}

final class ElectronsView: UIView {
  private let fillColors: [CGColor] = [UIColor.blue.cgColor,
                                       UIColor.red.cgColor,
                                       UIColor.purple.cgColor,
                                       UIColor.black.cgColor,]
  
  private var electronLayers = [CALayer]()
  weak var touchDelegate: ElectronViewTouchDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = UIColor.white.withAlphaComponent(0.95)
  }
  
  required init?(coder aDecoder: NSCoder) {
    // Not really needed, but required by UIKit
    fatalError("init(coder:) has not been implemented")
  }
  
  internal func update(using electrons: [Electron]) {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    for index in 0 ..< electrons.count {
      self.electronLayers[index].position = .init(x: CGFloat(electrons[index].position.x), y: CGFloat(electrons[index].position.y))
    }
    CATransaction.commit()
  }
  
  internal func createNewElectronLayer() {
    let layer = CAShapeLayer()
    layer.bounds = CGRect(x: 0, y: 0, width: Electron.radius * 2, height: Electron.radius * 2)
    layer.strokeColor = self.fillColors[Int.random(in: 0..<self.fillColors.count)]
    layer.fillColor = .none
    layer.lineWidth = 1.5
    let path = UIBezierPath(arcCenter: .init(x: layer.bounds.midX, y: layer.bounds.midY), radius: Electron.radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
    layer.path = path.cgPath
    self.layer.addSublayer(layer)
    electronLayers.append(layer)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let point = touches.first?.location(in: self) else { return }
    touchDelegate?.touch(at: point)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let point = touches.first?.location(in: self) else { return }
    touchDelegate?.touch(at: point)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    touchDelegate?.touch(at: .none)
  }
}
