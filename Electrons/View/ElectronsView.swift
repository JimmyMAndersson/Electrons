import UIKit

protocol ElectronsViewTouchDelegate: class {
  func touch(at point: CGPoint?) -> Void
}

class ElectronsView: UIView {
  weak var touchDelegate: ElectronsViewTouchDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = .lightGray
  }
  
  required init?(coder aDecoder: NSCoder) {
    // Not really needed, but required by UIKit
    fatalError("init(coder:) has not been implemented")
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
