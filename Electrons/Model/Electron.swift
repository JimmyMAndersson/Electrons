import CoreGraphics
import Foundation
import UIKit

protocol VisualUpdaterDelegate: class {
  func positionWasUpdated(_ position: CGPoint) -> Void
}

class Electron {
  internal static let radius: CGFloat = 2
  internal static let maxVelocity: Double = 3
  private static let maxVelocitySquared: Double = Electron.maxVelocity * Electron.maxVelocity
  
  @objc internal private(set) var position: SIMD2<Double>
  internal let id: Int
  
  weak var visualDelegate: VisualUpdaterDelegate?

  internal var velocity: SIMD2<Double> {
    didSet {
      // Normalize the velocity vector in case the total velocity gained in one update is more than Electron.maxVelocity
      if self.velocity.x + self.velocity.y > Electron.maxVelocity {
        let speed = sqrt((self.velocity.x * self.velocity.x) + (self.velocity.y * self.velocity.y))
        if speed > Electron.maxVelocity {
          self.velocity *= (Electron.maxVelocity / speed)
        }
      }
    }
  }
  
  init(at point: CGPoint, id: Int) {
    self.position = SIMD2<Double>(x: Double(point.x), y: Double(point.y))
    self.velocity = SIMD2<Double>(x: Double.random(in: -Electron.maxVelocity...Electron.maxVelocity), y: Double.random(in: -Electron.maxVelocity...Electron.maxVelocity))
    self.id = id
  }
  
  internal func update() {
    // Update position
    self.position += self.velocity
    
    if self.position.x - Double(Electron.radius) < 0 {
      self.position.x = Double(Electron.radius)
    }
    if self.position.x + Double(Electron.radius) >= Double(UIScreen.main.bounds.width) {
      self.position.x = Double(UIScreen.main.bounds.width) - Double(Electron.radius)
    }
    if self.position.y - Double(Electron.radius) < 0 {
      self.position.y = Double(Electron.radius)
    }
    if self.position.y + Double(Electron.radius) >= Double(UIScreen.main.bounds.height) {
      self.position.y = Double(UIScreen.main.bounds.height) - Double(Electron.radius)
    }
    // Flip velocity vector components if the electron has reached an edge
    if self.position.x - Double(Electron.radius) <= 0 || self.position.x + Double(Electron.radius) >= Double(UIScreen.main.bounds.width) {
      self.velocity.x *= -1
    }
    
    if self.position.y - Double(Electron.radius) <= 0 || self.position.y + Double(Electron.radius) >= Double(UIScreen.main.bounds.height) {
      self.velocity.y *= -1
    }
    
    // Call back to the view to update the visual
    self.visualDelegate?.positionWasUpdated(.init(x: self.position.x, y: self.position.y))
  }
}
