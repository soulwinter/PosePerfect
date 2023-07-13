//
//  DetectionView.swift
//  PosePerfect
//
//  Created by Han Chubo on 2023/7/8.
//

import SwiftUI

struct DetectionView: View {
    
    @StateObject var poseEstimator = PoseEstimator()
    @StateObject var webSocketService = WebSocketService()
    
    
    @State var detectedPose: Pose?
    @State var detected = false
    @State private var time: Float = 0.0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect() // 每秒触发一次
    
    var body: some View {
        VStack {
                        
            ZStack {
                // 绘制摄像机和线条
                GeometryReader { geo in
                    CameraViewWrapper(poseEstimator: poseEstimator)
                    StickFigureView(poseEstimator: poseEstimator, size: geo.size)
                }
               
               

//                 如果探测到人，就开始显示数据
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
            
            .onAppear {
                poseEstimator.startAirPodsUpdates()
                webSocketService.connect()
            }
            
            Button(action: {
                if !poseEstimator.bodyParts.isEmpty && (poseEstimator.AirPodsStatus == 1) {
                    poseEstimator.standardPose = Pose(time: time, bodyParts: poseEstimator.bodyParts, AirPodsMotion: poseEstimator.motionData)
                    detected = true
                }

            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10.0)
                    Text("记录")
                        .foregroundColor(Color.white)
                        .bold()
                }
                .frame(height: 50)
               
            }
            
            Button(action: {
                webSocketService.sendMessage(bodyInfoToJSON(bodyInfo: poseEstimator.poseInfo!))

            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10.0)
                    Text("发送")
                        .foregroundColor(Color.white)
                        .bold()
                }
                .frame(height: 50)
               
            }
        }
        .onReceive(timer) { _ in // 使用 onReceive 接收 timer 事件
            time += 1.0 // 每秒增加 1.0
        }
    }
    
}


struct DetectionView_Previews: PreviewProvider {
    static var previews: some View {
        DetectionView()
    }
}
