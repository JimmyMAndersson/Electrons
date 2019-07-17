import UIKit

final class ElectronsViewController: UIViewController {  
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
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    typedView.touchDelegate = self
    
    model.onUpdate = { [weak self] (electrons) in
      self?.typedView.update(using: electrons)
    }
    
    let denominator = CGFloat(sqrt(Double(model.capacity)))
    let totalX = view.bounds.width - 20
    let totalY = view.bounds.height - 20
    
    outerLoop: for y in stride(from: 10, through: view.bounds.height - 10, by: totalY / denominator) {
      for x in stride(from: 10, through: view.bounds.width - 10, by: totalX / denominator) {
        if model.addElectron(at: .init(x: x, y: y)) {
          typedView.createNewElectronLayer()
        } else {
          break outerLoop
        }
      }
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.model.start()
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    switch UIDevice.current.userInterfaceIdiom {
    case .pad: return [.landscapeLeft, .landscapeRight, .landscape]
    case .phone: return .portrait
    default: return .portrait
    }
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
}

extension ElectronsViewController: ElectronViewTouchDelegate {
  func touch(at point: CGPoint?) {
    model.touch = point
  }
}
