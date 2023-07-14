//
//  DetectionView.swift
//  PosePerfect
//
//  Created by Han Chubo on 2023/7/8.
//

import SwiftUI
import AVKit

struct DetectionView: View {
    
    // 跳舞
    var id: Int64
    
    @StateObject var poseEstimator = PoseEstimator()
    @StateObject var webSocketService = WebSocketService()
    
    
    @State var detectedPose: Pose?
    @State var detected = false
    
    // TODO: 保存的动作，还需要进一步修改
    @AppStorage("QiCaiYangGuang") var poseQCYG = ""
    // 总动作的序列
    @State var poseSequence: [Pose] = []
    // 做到了第几个动作
    @State var poseOrder = 0
    
    @State private var timer: Timer? = nil
    @State private var time: Float = 0.0
    @State var recordStarted = false
    
    
    // 每 0.05 秒进行一次姿势的判断：10FPS
    let detectionTimer =  Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    // 每次判断的最高分，以这个作为数据传输
    @State var bestScore: Double = -1
    // 传输最好的姿势
    @State var bestBodyInfo: BodyInfo?
    
    // 视频
    private var player: AVPlayer?
    @State private var playVideo = false
    
    var metadata: String
    
    
    init(id: Int64) {
        self.id = id
        if id == 1 {
            // 加载本地视频
            guard let url = Bundle.main.url(forResource: "七彩阳光", withExtension: "mp4") else {
                fatalError("Video not found")
            }
            self.player = AVPlayer(url: url)
        }
        self.metadata = DatabaseManager.shared.getMetadata(id: id)!
        
    }
    
    var body: some View {
        ZStack {
            
            // 绘制摄像机和线条
            GeometryReader { geo in
                CameraViewWrapper(poseEstimator: poseEstimator)
                StickFigureView(poseEstimator: poseEstimator, size: geo.size)
            }
            .ignoresSafeArea()
            // 只有 1 个视频
            if id == 1 {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        VideoPlayer(player: player)
                            .onAppear() {
                                if playVideo {
                                    player?.play()
                                } else {
                                    player?.pause()
                                }
                            }
                            .onDisappear() {
                                player?.pause()
                            }
                            .frame(width: 852*0.3, height: 480*0.3)
                        
                    }
                    Spacer()
                        .frame(height: 60)
                    
                    
                }
            }
            
            
            
            VStack {
                
                ZStack {
                    VStack(alignment: .leading) {
                        // , \(String(format: "%.1f", time))/\(String(format: "%.1f", poseSequence[poseOrder].time))
                        Text("关键动作： \(poseOrder + 1) / \(poseSequence.count)")
                            .bold()
                            .font(.title2)
                        // 如果探测到人，就开始显示数据
                        if poseEstimator.poseInfo != nil {
                            
                            
                            
                            Text("\(poseEstimator.poseInfo!.totalScore)")
                                .bold()
                                .font(.largeTitle)
                            Spacer()
                            
                            //                            Group {
                            //                                Text("Left Arm: \(poseEstimator.poseInfo!.leftArm.score)")
                            //                                Text("Right Arm: \(poseEstimator.poseInfo!.rightArm.score)")
                            //                                Text("Left Leg: \(poseEstimator.poseInfo!.leftLeg.score)")
                            //                                Text("Right Leg: \(poseEstimator.poseInfo!.rightLeg.score)")
                            //                                Text("Left Body Angle: \(poseEstimator.poseInfo!.leftBodyAngle.score)")
                            //                                Text("Right Body Angle: \(poseEstimator.poseInfo!.rightBodyAngle.score)")
                            //                                Text("Hip Angle: \(poseEstimator.poseInfo!.hipAngle.score)")
                            //                                Text("Left Upper Limb: \(poseEstimator.poseInfo!.leftUpperLimb.score)")
                            //                                Text("Right Upper Limb: \(poseEstimator.poseInfo!.rightUpperLimb.score)")
                            //                            }
                            //
                            //
                            //
                            //                            Text("AirPods Acceleration: \(poseEstimator.poseInfo!.airPodsInfo.accelerationDifference)")
                            //                            Text("X:\(poseEstimator.poseInfo!.airPodsInfo.directionX) Y:\(poseEstimator.poseInfo!.airPodsInfo.directionY) Z:\(poseEstimator.poseInfo!.airPodsInfo.directionZ)")
                            
                        }
                           
                        
                    }
                    
                }
                
                .onAppear {
                    poseEstimator.startAirPodsUpdates()
                    
                    
                    // 强制转换，不确定行不行
                    poseSequence = poseArraysFromJSON(json: metadata)!
                    poseEstimator.standardPose = poseSequence[0]
                }
                
                .onReceive(detectionTimer) { _ in
                    
                    // 在后台线程上执行任务
                    // 如果开始探测，则首先需要进行时间判断，做到第几个动作了
                    if recordStarted {
                        
                        // 前后一秒内做的动作都有效
                        if poseEstimator.poseInfo != nil && abs(time - poseSequence[poseOrder].time) < 1 {
                            if poseEstimator.poseInfo!.totalScore > bestScore {
                                bestBodyInfo = poseEstimator.poseInfo
                                bestScore = poseEstimator.poseInfo!.totalScore
                            }
                        }
                        
                        
                        // 时间超过了要做的动作
                        if time > poseSequence[poseOrder].time + 1 && poseOrder < poseSequence.count - 1 && poseEstimator.poseInfo != nil {
                            poseOrder += 1
                            poseEstimator.standardPose = poseSequence[poseOrder]
                            
                            if bestBodyInfo != nil {
                                let sendString = bodyInfoToJSON(bodyInfo: bestBodyInfo!)
                                print(sendString)
                                webSocketService.sendMessage(sendString)
                            }
                            
                            bestBodyInfo = nil
                            bestScore = 0
                            
                        }
                        
                        // 做完了自动断开
                        if time > poseSequence[poseSequence.count - 1].time {
                            webSocketService.disconnect()
                        }
                        
                    }
                }
                
                Spacer()
                Button(action: {
                    
                    if !recordStarted {
                        self.timer?.invalidate() // 制止任何已存在的计时器
                        if poseEstimator.bodyParts.isEmpty {
                            return
                        }
                        if (poseEstimator.AirPodsStatus != 1) {
                            return
                        }
                        if (id == 1) {
                            player?.play()
                        }
                        
                        recordStarted = true
                        // 连接
                        webSocketService.connect()
                        // 开始新的计时器
                        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                            time += 0.1
                        }
                    }
                    
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10.0)
                            .foregroundColor(Color(hex: 0x807AE4))
                        Text("开始")
                            .foregroundColor(Color.white)
                            .bold()
                    }
                    .padding(.horizontal)
                    .frame(height: 50)
                    
                }
                
            }
        }
        
        
    }
    
}



