import Foundation
import CoreGraphics
import UIKit

class ElectronsModel {
  internal var touch: CGPoint?
  private var electrons: [Electron]
  private var timer = Timer()
  private let capacity: Int
  
  // Walls will apply forces to electrons starting at a distance of (wallDistance) dots
  private let wallDistance: Double = 30
  // Forces will start kicking in at sqrt(electronDistanceSquared) dots distance
  private let electronDistanceSquared: Double = 8100
  private let touchDistanceSquared: Double = 62500
  
  private var diffVectors: [SIMD2<Double>]
  
  init(capacity: Int) {
    self.electrons = Array<Electron>()
    self.electrons.reserveCapacity(capacity)
    self.diffVectors = [SIMD2<Double>](repeating: .zero, count: capacity)
    self.capacity = capacity
  }
  
  internal func start() {
    self.timer.invalidate()
    self.timer = Timer(timeInterval: 1/60, repeats: true, block: { (_) in
      self.updateModel()
    })
    DispatchQueue.global(qos: .userInitiated).async {
      RunLoop.current.add(self.timer, forMode: .common)
      RunLoop.current.run()
    }
  }
  
  @discardableResult
  internal func addElectron(at point: CGPoint) -> CALayer? {
    guard self.electrons.count < self.capacity else { return nil }
    let newElectron = Electron(at: point, id: self.electrons.count + 1)
    self.electrons.append(newElectron)
    return newElectron.layer
  }
  
  private func updateModel() {
    calculateForces()
  }
  
  private func calculateForces() {
    // Reset the differential vectors for a new update pass
    for i in 0..<self.diffVectors.count {
      diffVectors[i].x = 0
      diffVectors[i].y = 0
    }
    
    for current in 0..<self.electrons.count {
      let firstElectron = self.electrons[current]
      
      /*
       We can cut time from our O(n^2) algorithm by realizing that we only need to compare "forwards".
       This means that if we compare the first electron to all others and update both differential vectors as we make comparisons,
       we won't have to revisit the first electron for further comparisons once we're done with the first iteration.
       
       The sum of all comparisons will be (n - 1)*(n - 2)* ... *(1) = n*(n - 1) / 2
       */
      
      if self.electrons.count > 1 {
        for comparison in current + 1..<self.electrons.count {
          let secondElectron = self.electrons[comparison]
          
          let xComponent = firstElectron.position.x - secondElectron.position.x
          let yComponent = firstElectron.position.y - secondElectron.position.y
          
          let distanceSquared = (xComponent * xComponent) + (yComponent * yComponent)
          
          // Calculate force vectors only if two electrons are sufficiently close to each other
          if distanceSquared < electronDistanceSquared {
            
            // Calculate the angle at which the force will be applied
            let angle = atan2(secondElectron.position.y - firstElectron.position.y, secondElectron.position.x - firstElectron.position.x)
            
            var force = SIMD2<Double>.init(x: (36 * cos(angle) / distanceSquared), y: (36 * sin(angle) / distanceSquared))
            
            diffVectors[comparison] += force
            
            // Flip the force vector to apply the exact opposite force to the first electron
            force *= -1
            diffVectors[current] += force
          }
        }
      }
      
      // Calculate forces from walls if electron is sufficiently close to one
      if firstElectron.position.x < wallDistance {
        let d = firstElectron.position.x - 10
        let d2 = d * d
        diffVectors[current] += SIMD2<Double>.init(x: 50 / d2, y: 0)
      } else if firstElectron.position.x > Double(UIScreen.main.bounds.width) - wallDistance {
        let d = Double(UIScreen.main.bounds.width) - firstElectron.position.x - 10
        let d2 = d * d
        diffVectors[current] += SIMD2<Double>.init(x: -50 / d2, y: 0)
      }
      
      if firstElectron.position.y < wallDistance {
        let d = firstElectron.position.y - 10
        let d2 = d * d
        diffVectors[current] += SIMD2<Double>.init(x: 0, y: 50 / d2)
      } else if firstElectron.position.y > Double(UIScreen.main.bounds.height) - wallDistance {
        let d = Double(UIScreen.main.bounds.height) - firstElectron.position.y - 10
        let d2 = d * d
        diffVectors[current] += SIMD2<Double>.init(x: 0, y: -50 / d2)
      }
      
      if let touch = self.touch {
        let xComponent = firstElectron.position.x - Double(touch.x)
        let yComponent = firstElectron.position.y - Double(touch.y)
        
        let distanceSquared = (xComponent * xComponent) + (yComponent * yComponent)
        
        // Calculate force vectors only if the current electron is close to the touch site
        if distanceSquared < touchDistanceSquared {
          
          // Calculate the angle at which the force will be applied
          let angle = atan2(Double(touch.y) - firstElectron.position.y, Double(touch.x) - firstElectron.position.x)
          
          var force = SIMD2<Double>.init(x: (1000 * cos(angle) / distanceSquared), y: (1000 * sin(angle) / distanceSquared))
          force *= -1
          diffVectors[current] += force
        }
      }
      
      /*
       All calculations are done for the current electron,
       so we take the opportunity to update its velocity vector and
       position while it's still available in the hardware cache.
       */
      firstElectron.velocity += diffVectors[current]
      firstElectron.update()
    }
  }
}
