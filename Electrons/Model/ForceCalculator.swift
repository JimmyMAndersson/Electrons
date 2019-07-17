import Metal
import Foundation
import UIKit

final class ForceCalculator {
  private let device: MTLDevice
  private let diffFunction: MTLFunction
  private let updateFunction: MTLFunction
  private let diffPipelineState: MTLComputePipelineState
  private let updatePipelineState: MTLComputePipelineState
  private let commandQueue: MTLCommandQueue
  private let bufferManager: BufferManager
  private let initialDiffs: [SIMD2<Electron.DataType>]
  private var info: Info
  private var gridSize = MTLSize(width: 1, height: 1, depth: 1)
  private var threadGroupSize = MTLSize(width: 1, height: 1, depth: 1)
  
  init?(bufferCapacity: Int, device: MTLDevice) {
    self.device = device
    
    self.info = Info(capacity: 0, maxX: Float(UIScreen.main.bounds.maxX), maxY: Float(UIScreen.main.bounds.maxY))
    self.initialDiffs = .init(repeating: .init(x: 0, y: 0), count: bufferCapacity)
    
    guard
      let library = device.makeDefaultLibrary(),
      let diffFunction = library.makeFunction(name: "calculate_differentials"),
      let updateFunction = library.makeFunction(name: "update_electrons")
      else { print("\(#file): \(#line)"); return nil }
    
    self.diffFunction = diffFunction
    self.updateFunction = updateFunction
    
    guard
      let diffState = try? device.makeComputePipelineState(function: self.diffFunction),
      let updateState = try? device.makeComputePipelineState(function: self.updateFunction)
      else { print("\(#file): \(#line)"); return nil }
    
    self.diffPipelineState = diffState
    self.updatePipelineState = updateState
    
    guard let commandQueue = device.makeCommandQueue() else { return nil }
    self.commandQueue = commandQueue
    
    guard let bufferManager = BufferManager(device: self.device, info: info, capacity: bufferCapacity) else { return nil }
    self.bufferManager = bufferManager
  }
  
  func update(electrons: [Electron], completion: @escaping ([Electron]) -> ()) {
    bufferManager.electronSemaphore.wait()
    
    let diffBuffer = bufferManager.retrieveDiffBuffer()
    let electronBuffer = bufferManager.retrieveElectronBuffer()
    
    if Int(info.capacity) != electrons.count {
      electronBuffer.contents().copyMemory(from: electrons, byteCount: electrons.count * MemoryLayout<Electron>.stride)
      info.capacity = UInt32(electrons.count)
      gridSize.width = electrons.count
    }
    
    diffBuffer.contents().copyMemory(from: initialDiffs, byteCount: Int(info.capacity) * MemoryLayout<SIMD2<Electron.DataType>>.stride)
    
    if let commandBuffer = commandQueue.makeCommandBuffer(),
      let diffEncoder = commandBuffer.makeComputeCommandEncoder()
    {
      diffEncoder.setComputePipelineState(self.diffPipelineState)
      diffEncoder.setBuffer(diffBuffer, offset: 0, index: 0)
      diffEncoder.setBuffer(electronBuffer, offset: 0, index: 1)
      diffEncoder.setBytes(&info, length: MemoryLayout<Info>.stride, index: 2)
      diffEncoder.dispatchThreadgroups(gridSize, threadsPerThreadgroup: threadGroupSize)
      diffEncoder.endEncoding()
      
      guard let updateEncoder = commandBuffer.makeComputeCommandEncoder() else { return }
      updateEncoder.setComputePipelineState(self.updatePipelineState)
      updateEncoder.setBuffer(diffBuffer, offset: 0, index: 0)
      updateEncoder.setBuffer(electronBuffer, offset: 0, index: 1)
      updateEncoder.setBytes(&info, length: MemoryLayout<Info>.stride, index: 2)
      updateEncoder.dispatchThreadgroups(gridSize, threadsPerThreadgroup: threadGroupSize)
      updateEncoder.endEncoding()
      
      commandBuffer.addCompletedHandler { [weak self] (_) in
        guard let `self` = self else { return }
        DispatchQueue.main.async {
          let boundPointer = electronBuffer.contents().bindMemory(to: Electron.self, capacity: Int(self.info.capacity))
          let bufferPointer = UnsafeMutableBufferPointer(start: boundPointer, count: Int(self.info.capacity))
          let newArray = Array(bufferPointer)
          completion(newArray)
        }
        self.bufferManager.electronSemaphore.signal()
      }
      
      commandBuffer.commit()
    }
  }
}
