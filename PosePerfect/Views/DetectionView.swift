//
//  DetectionView.swift
//  PosePerfect
//
//  Created by Han Chubo on 2023/7/8.
//

import SwiftUI

struct DetectionView: View {
    
    @StateObject var poseEstimator = PoseEstimator()
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

                // 如果探测到人，就开始显示数据
                if detected {
                   
                        VStack(alignment: .leading) {
                            Text("\(poseEstimator.poseScore)")
                                .bold()
                                .font(.title2)
                            ForEach(ConnectedJoints.allCases, id: \.self) { joint in
                                if let difference = poseEstimator.poseAngleDifferences[joint] {
                                    Text("\(joint.description): \(difference)")
                                }
                            }
                            if let airpodsInfo = poseEstimator.AirPodsDifferences {
                                Text("\(airpodsInfo.accelerationDifference)")
                                Text("X:\(airpodsInfo.directionX) Y:\(airpodsInfo.directionY) Z:\(airpodsInfo.directionZ)")
                            }
                        }
                        .padding()
                    
                    
                   
                }
            }
//            .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width * 1920 / 1080, alignment: .center)
            .onAppear {
                poseEstimator.startAirPodsUpdates()
            }
            
            
            Button(action: {
                if !poseEstimator.bodyParts.isEmpty && (poseEstimator.AirPodsStatus == 1) {
                    poseEstimator.standardPose = Pose(time: time, bodyParts: poseEstimator.bodyParts, AirPodsMotion: poseEstimator.motionData)
                    detected = true
                }
                
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10.0)
                        .frame(height: 50)
                    
                    Text("记录")
                        .foregroundColor(Color.white)
                        .bold()
                }
               
                
            }
            
           
            
        }
        .onReceive(timer) { _ in // 使用 onReceive 接收 timer 事件
            time += 1.0 // 每秒增加 1.0
        }
        
    }
    
}

// 为了输出名字的拓展
extension ConnectedJoints {
    var description: String {
        switch self {
        case .leftArm:
            return "Left Arm"
        case .rightArm:
            return "Right Arm"
        case .leftLeg:
            return "Left Leg"
        case .rightLeg:
            return "Right Leg"
        case .leftBodyAngle:
            return "Left Body Angle"
        case .rightBodyAngle:
            return "Right Body Angle"
        case .hipAngle:
            return "Hip Angle"
        case .leftUpperLimb:
            return "Left Upper Limb"
        case .rightUpperLimb:
            return "Right Upper Limb"
        }
    }
}

struct DetectionView_Previews: PreviewProvider {
    static var previews: some View {
        DetectionView()
    }
}
