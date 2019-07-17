struct Info {
  var capacity: UInt32
  let maxX: Float
  let maxY: Float
  let radius: Float = Float(Electron.radius)
  let maxVelocity: Float = Electron.maxVelocity
  let wallDistance: Float = 5.0
}
