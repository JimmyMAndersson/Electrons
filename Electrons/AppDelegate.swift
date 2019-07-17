import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    guard let device = MTLCreateSystemDefaultDevice() else { fatalError("Could not create Metal device.") }
    
    self.window = UIWindow(frame: UIScreen.main.bounds)
    self.window?.makeKeyAndVisible()
    let model = ElectronsModel(capacity: 2500, device: device)
    self.window?.rootViewController = ElectronsViewController(model: model)
    return true
  }
}

