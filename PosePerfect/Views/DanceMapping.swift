//
//  DanceMapping.swift
//  PosePerfect
//
//  Created by Han Chubo on 2023/7/14.
//

import SwiftUI

struct DanceMapping: View {
    
    @StateObject var poseEstimator = PoseEstimator()
    
    
    
    @State var detectedPose: Pose?
    @State var detected = false
    @State private var time: Float = 0.0
    @State var poseSequence: [Pose] = []
    @State var recordStarted = false
    @State private var timer: Timer? = nil
    
    
    // TODO: 需要改为 Core Data
    @AppStorage("QiCaiYangGuang") var poseQCYG: String = ""
    
    
    var body: some View {
        VStack {
            
            ZStack {
                // 绘制摄像机和线条
                GeometryReader { geo in
                    CameraViewWrapper(poseEstimator: poseEstimator)
                    StickFigureView(poseEstimator: poseEstimator, size: geo.size)
                }
                
                VStack(alignment: .leading) {
                    Text("Pose Number \(poseSequence.count) | \(time)")
                        .bold()
                        .font(.title3)
                        .foregroundColor(Color.white)
                
                // 如果探测到人，就开始显示数据
                if detected {
                    
                  
                        
                        VStack(alignment: .leading) {
                            Text("\(poseEstimator.poseInfo!.totalScore)")
                                .bold()
                                .font(.title2)
                            
                            Group {
                                Text("Left Arm: \(poseEstimator.poseInfo!.leftArm.angleDifference)")
                                Text("Right Arm: \(poseEstimator.poseInfo!.rightArm.angleDifference)")
                                Text("Left Leg: \(poseEstimator.poseInfo!.leftLeg.angleDifference)")
                                Text("Right Leg: \(poseEstimator.poseInfo!.rightLeg.angleDifference)")
                                Text("Left Body Angle: \(poseEstimator.poseInfo!.leftBodyAngle.angleDifference)")
                                Text("Right Body Angle: \(poseEstimator.poseInfo!.rightBodyAngle.angleDifference)")
                                Text("Hip Angle: \(poseEstimator.poseInfo!.hipAngle.angleDifference)")
                                Text("Left Upper Limb: \(poseEstimator.poseInfo!.leftUpperLimb.angleDifference)")
                                Text("Right Upper Limb: \(poseEstimator.poseInfo!.rightUpperLimb.angleDifference)")
                            }
                            
                            
                            
                            Text("AirPods Acceleration: \(poseEstimator.poseInfo!.airPodsInfo.accelerationDifference)")
                            Text("X:\(poseEstimator.poseInfo!.airPodsInfo.directionX) Y:\(poseEstimator.poseInfo!.airPodsInfo.directionY) Z:\(poseEstimator.poseInfo!.airPodsInfo.directionZ)")
                            
                        }
                        .padding()
                        
                    }
                }
                
            }
            .onAppear {
                poseEstimator.startAirPodsUpdates()
            }
            
            Button(action: {
                if !recordStarted {
                    self.timer?.invalidate() // 制止任何已存在的计时器
                    
                    recordStarted = true
                    // 开始新的计时器
                    self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                        time += 0.1
                    }
                    
                    
                    
                } else {
                    if !poseEstimator.bodyParts.isEmpty && (poseEstimator.AirPodsStatus == 1) {
                        let newPose = Pose(time: time, bodyParts: poseEstimator.bodyParts, AirPodsMotion: poseEstimator.motionData)
                        poseEstimator.standardPose = newPose
                        poseSequence.append(newPose)
                        detected = true
                    }
                    
                }
                
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10.0)
                    Text("记录")
                        .foregroundColor(Color.white)
                        .bold()
                }
                .frame(height: 40)
                
            }
            
            Button(action: {
                self.timer?.invalidate() // 制止任何已存在的计时器
                recordStarted = false
                if let json = poseArraysToJSON(poses: poseSequence) {
                    self.poseQCYG = json
                }
                
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10.0)
                    Text("停止并保存")
                        .foregroundColor(Color.white)
                        .bold()
                }
                .frame(height: 40)
                
            }
            
            
            
        }
        
    }
}
    
    
    struct DanceMapping_Previews: PreviewProvider {
        static var previews: some View {
            DanceMapping()
        }
    }
