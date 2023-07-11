//
//  CameraView.swift
//  PosePerfect
//
//  Created by Han Chubo on 2023/7/10.
//

import AVFoundation
import UIKit

final class CameraView: UIView {
    
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
      }
}
