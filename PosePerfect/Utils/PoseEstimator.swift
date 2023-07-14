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
import CoreMotion

class PoseEstimator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    let sequenceHandler = VNSequenceRequestHandler()
    @Published var bodyParts = [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]()

    // 用于判断标准的姿势
    @Published var standardPose: Pose?
   
    
    // 耳机数据
    let APP = CMHeadphoneMotionManager()
    @Published var motionData: CMDeviceMotion?
    @Published var AirPodsStatus: Int = 0
    //  0: 正在寻找 AirPods
    //  1: 状态录制中
    // -1: 不支持此设备
    //  2: 停止
    
    // 计算分数    
    @Published var poseInfo: BodyInfo?
    
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
        // 如果没有数据不执行
        if !bodyParts.isEmpty && AirPodsStatus == 1 {
            let currentPose = Pose(time: 0, bodyParts: bodyParts, AirPodsMotion: motionData)
            // 如果数据不对，返回和自己的对比，理论上应该是 100 分
            poseInfo = calculatePoseScore(pose1: currentPose, pose2: standardPose ?? currentPose)
        }
       
    }
    
    // 耳机开始探测
    func startAirPodsUpdates() {
        guard APP.isDeviceMotionAvailable else {
            AirPodsStatus = -1
            return
        }
        
        APP.startDeviceMotionUpdates(to: OperationQueue.current!) { [weak self] (motion, error) in
            guard let motion = motion, error == nil
                else { return }
            self?.motionData = motion
            self?.AirPodsStatus = 1
        }
    }
    
    // 耳机停止探测
    func stopAirPodsUpdates() {
        APP.stopDeviceMotionUpdates()
    }
    
    

}
