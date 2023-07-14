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
    
    
    // 创建2个State属性以保存用户输入的值
    @State private var name: String = ""
    @State private var difficulty: String = ""
    @State private var isSaving = false
    
    // 控制弹窗是否显示
    @State private var showingAlert = false
    
    
    // TODO: 需要改为 Core Data
    @AppStorage("QiCaiYangGuang") var poseQCYG: String = ""
    
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                CameraViewWrapper(poseEstimator: poseEstimator)
                StickFigureView(poseEstimator: poseEstimator, size: geo.size)
            }
            .ignoresSafeArea()
            VStack {
                
                ZStack {
                    // 绘制摄像机和线条
                    
                    
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
                
                Spacer()
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
                        Text(poseSequence.count == 0 ? "开始记录" : "记录关键点")
                            .foregroundColor(Color.white)
                            .bold()
                    }
                    .frame(height: 40)
                    .padding(.horizontal)
                    
                }
                
                Button("停止并保存") {
                    isSaving.toggle()
                }
                .alert("请输入名称和难度", isPresented: $isSaving) {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.never)
                    TextField("Difficulty", text: $difficulty)
                    Button("OK", action: saveData)
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("请输入动作的名称和难度等级。")
                }
                
                
                
            }
        }
        
        
    }
    
    func saveData() {
        self.timer?.invalidate()
        self.recordStarted = false
        let d = DatabaseManager.shared.deleteAllData()
        if let json = poseArraysToJSON(poses: self.poseSequence) {
            let difficultyInt = Int(difficulty) ?? 1
            let id = DatabaseManager.shared.insertData(name: self.name, metadata: json, difficulty: difficultyInt, length: Int(self.time))
            print(id ?? -1)
            
            // TODO: 请求云端加入
        }
        self.isSaving = false // 关闭弹窗
    }
}



struct DanceMapping_Previews: PreviewProvider {
    static var previews: some View {
        DanceMapping()
    }
}
