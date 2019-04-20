import UIKit

class ElectronsView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = .lightGray
  }
  
  required init?(coder aDecoder: NSCoder) {
    // Not really needed, but required by UIKit
    fatalError("init(coder:) has not been implemented")
  }
}
