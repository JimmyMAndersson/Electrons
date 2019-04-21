import CoreGraphics
import Foundation
import UIKit

class Electron {
  private static let fillColors: [CGColor] = [UIColor.blue.cgColor, UIColor.red.cgColor, UIColor.green.cgColor, UIColor.purple.cgColor, UIColor.yellow.cgColor]
  internal static let radius: CGFloat = 2
  internal static let maxVelocity: Double = 3
  private static let maxVelocitySquared: Double = Electron.maxVelocity * Electron.maxVelocity
  
  internal private(set) var position: SIMD2<Double>
  private let id: Int
  private let path: UIBezierPath
  
  internal private(set) var layer: CAShapeLayer = {
    let layer = CAShapeLayer()
    return layer
  }()
  
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
    self.layer.fillColor = Electron.fillColors[id % Electron.fillColors.count]
    self.path = UIBezierPath(arcCenter: .init(x: position.x, y: position.y), radius: Electron.radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
    self.layer.path = path.cgPath
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
    // Update the Bezier path to reflect the electrons new position
    self.path.removeAllPoints()
    self.path.addArc(withCenter: .init(x: self.position.x, y: self.position.y), radius: Electron.radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
    self.layer.path = path.cgPath
  }
}
