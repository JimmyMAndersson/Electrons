import Foundation
import CoreGraphics
import UIKit

final class ElectronsModel {
  internal var touch: CGPoint?
  private let forceCalculator: ForceCalculator
  private var electrons: [Electron]
  private var timer = Timer()
  internal let capacity: Int
  private var diffVectors: [SIMD2<Electron.DataType>]
  internal var onUpdate: (([Electron]) -> ())
  
  init(capacity: Int, device: MTLDevice) {
    guard let forceCalculator = ForceCalculator(bufferCapacity: capacity, device: device) else { fatalError("Could not initialize force calculator.") }
    self.forceCalculator = forceCalculator
    self.onUpdate = { (electrons) in return }
    self.electrons = Array<Electron>()
    self.diffVectors = [SIMD2<Electron.DataType>](repeating: .init(x: 0, y: 0), count: capacity)
    self.capacity = capacity
  }
  
  @discardableResult
  public func addElectron(at point: CGPoint) -> Bool {
    guard electrons.count < capacity else { return false }
    let electron = Electron(x: Electron.DataType(point.x), y: Electron.DataType(point.y))
    electrons.append(electron)
    return true
  }
  
  internal func start() {
    self.timer.invalidate()
    self.timer = Timer(timeInterval: 1/60, repeats: true, block: { (_) in
      self.updateModel()
    })
    RunLoop.current.add(self.timer, forMode: .common)
    RunLoop.current.run()
  }
  
  private func updateModel() {
    self.forceCalculator.update(electrons: self.electrons) { (newElectrons) in
      self.electrons = newElectrons
      self.onUpdate(newElectrons)
    }
  }
}
