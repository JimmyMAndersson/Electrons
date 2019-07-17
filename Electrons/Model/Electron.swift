import CoreGraphics

struct Electron {
  typealias DataType = Float
  static let radius: CGFloat = 2
  static let maxVelocity: Float = 1.5
  internal var position: SIMD2<DataType>
  internal var velocity: SIMD2<DataType>
  
  init(x: DataType = DataType(Float.random(in: 0...300)),
       y: DataType = DataType(Float.random(in: 0...300)),
       velX: DataType = DataType(Float.random(in: -Electron.maxVelocity...Electron.maxVelocity)),
       velY: DataType = DataType(Float.random(in: -Electron.maxVelocity...Electron.maxVelocity)))
  {
    self.position = SIMD2<DataType>(x: x, y: y)
    self.velocity = SIMD2<DataType>(x: velX, y: velY)
  }
}
