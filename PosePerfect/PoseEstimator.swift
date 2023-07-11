//
//  PoseEstimator.swift
//  PosePerfect
//
//  Created by Han Chubo on 2023/7/10.
//

import Foundation
import AVFoundation
import Vision
import Combine

class PoseEstimator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    let sequenceHandler = VNSequenceRequestHandler()
    @Published var bodyParts = [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]()
    var wasInBottomPosition = false

    @Published var isGoodPosture = true
    @Published var poseAngleDifferences: [ConnectedJoints : CGFloat] = [:]
    @Published var poseScore: CGFloat = 0
    
    // 用于判断标准的姿势
    @Published var standardPose: Pose?
    
    var subscriptions = Set<AnyCancellable>()
    
    override init() {
        super.init()
        $bodyParts
            .combineLatest($standardPose) // 当 bodyParts 和 standardPose 都有值时触发
            .filter { _, standardPose in standardPose != nil } // 忽略当 standardPose 为 nil 的情况
            .sink(receiveValue: { bodyParts, _ in self.estimateDance(bodyParts: bodyParts)}) // 使用 estimateDance 方法
            .store(in: &subscriptions)
}
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let humanBodyRequest = VNDetectHumanBodyPoseRequest(completionHandler: detectedBodyPose)
        do {
            try sequenceHandler.perform(
              [humanBodyRequest],
              on: sampleBuffer,
                orientation: .right)
        } catch {
          print(error.localizedDescription)
        }
    }
    func detectedBodyPose(request: VNRequest, error: Error?) {
        guard let bodyPoseResults = request.results as? [VNHumanBodyPoseObservation]
          else { return }
        guard let bodyParts = try? bodyPoseResults.first?.recognizedPoints(.all) else { return }
        DispatchQueue.main.async {
            self.bodyParts = bodyParts
        }
    }
    
    func estimateDance(bodyParts: [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]) {
        
        let currentPose = Pose(time: 0, bodyParts: bodyParts)
        // poseAngleDifferences = calculateAngleDifferences(pose1: currentPose, pose2: standardPose ?? currentPose)
        // 此版本计算的是分数，但是还有诸多问题
        poseAngleDifferences = calculatePoseScore(pose1: currentPose, pose2: standardPose ?? currentPose)
        var total: CGFloat = 0
        for (_, value) in poseAngleDifferences {
            total += value
        }
        poseScore = total / CGFloat(poseAngleDifferences.count)
    
        
    }

}
