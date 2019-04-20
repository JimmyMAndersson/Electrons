import UIKit
import SpriteKit

class ElectronsViewController: UIViewController {  
  private let model: ElectronsModel
  
  init(model: ElectronsModel) {
    self.model = model
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  var typedView: ElectronsView {
    return self.view as! ElectronsView
  }
  
  override func loadView() {
    let view = ElectronsView()
    self.view = view
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.typedView.touchDelegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    /*
     Fill the view with as many electrons that can fit the screen or
     with the number of electrons specified in AppDelegate, whichever one is
     larger.
     */
    for y in stride(from: 10, to: typedView.bounds.maxY - 10, by: 20) {
      for x in stride(from: 10, to: typedView.bounds.maxX - 10, by: 20) {
        guard let electronLayer = model.addElectron(at: .init(x: x, y: y)) else { return }
        self.typedView.layer.addSublayer(electronLayer)
      }
    }
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
}

extension ElectronsViewController: ElectronsViewTouchDelegate {
  func touch(at point: CGPoint?) {
    self.model.touch = point
  }
}
