import Metal

final class BufferManager {
  private let electronBuffer: MTLBuffer
  private let diffBuffer: MTLBuffer
  internal let electronSemaphore: DispatchSemaphore
  
  init?(device: MTLDevice, info: Info, capacity: Int) {
    guard
      let dataBuffer = device.makeBuffer(length: capacity * MemoryLayout<Electron>.stride, options: .storageModeShared)
      else { print("\(#file): \(#line)"); return nil }
    
    guard
      let vectorBuffer = device.makeBuffer(length: capacity * MemoryLayout<SIMD2<Electron.DataType>>.stride, options: .storageModeShared)
      else { print("\(#file): \(#line)"); return nil }
    
    self.electronBuffer = dataBuffer
    self.diffBuffer = vectorBuffer
    self.electronSemaphore = DispatchSemaphore(value: 1)
  }
  
  func retrieveElectronBuffer() -> MTLBuffer {
    return electronBuffer
  }
  
  func retrieveDiffBuffer() -> MTLBuffer {
    return diffBuffer
  }
}
