//
//  Data.swift
//  PosePerfect
//
//  Created by Han Chubo on 2023/7/10.
//

import Foundation
import Vision
import CoreMotion

struct CodableQuaternion: Codable {
    let x: Double
    let y: Double
    let z: Double
    let w: Double
    
    init(quaternion: CMQuaternion) {
        self.x = quaternion.x
        self.y = quaternion.y
        self.z = quaternion.z
        self.w = quaternion.w
    }
    
    init(x: Double, y: Double, z: Double, w: Double) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }
}

struct CodableAcceleration: Codable {
    let x: Double
    let y: Double
    let z: Double
    
    init(acceleration: CMAcceleration) {
        self.x = acceleration.x
        self.y = acceleration.y
        self.z = acceleration.z
    }
    init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
}

struct CodableDeviceMotion: Codable {
    let quaternion: CodableQuaternion
    let userAcceleration: CodableAcceleration
    
    init(_ newDM: CMDeviceMotion) {
        self.quaternion = CodableQuaternion(quaternion: newDM.attitude.quaternion)
        self.userAcceleration = CodableAcceleration(acceleration: newDM.userAcceleration)
    }
    
    init() {
        self.quaternion = CodableQuaternion(x: -1, y: -1, z: -1, w: -1)
        self.userAcceleration = CodableAcceleration(x: -1, y: -1, z: -1)
    }
}


// Create a new pose: let pose = Pose(time: currentTime, bodyParts: poseEstimator.bodyParts)
struct Pose: Codable {
    var time: Float
    
    // 中间
    var neck: CGPoint
    var root: CGPoint
    
    // 右边
    var rightElbow: CGPoint
    var rightWrist: CGPoint
    var rightShoulder: CGPoint
    var rightHip: CGPoint
    var rightKnee: CGPoint
    var rightAnkle: CGPoint
    
    // 左边
    var leftElbow: CGPoint
    var leftWrist: CGPoint
    var leftShoulder: CGPoint
    var leftHip: CGPoint
    var leftKnee: CGPoint
    var leftAnkle: CGPoint
    
    // 耳机数据
    var AirPodsAvailable: Bool
    var AirPodsMotion: CodableDeviceMotion?
    
    
    init(time: Float, bodyParts: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint], AirPodsMotion: CMDeviceMotion?) {
        self.time = time
        
        // 中间
        self.neck = bodyParts[.neck]?.location ?? CGPoint.zero
        self.root = bodyParts[.root]?.location ?? CGPoint.zero
        
        // 右边
        self.rightElbow = bodyParts[.rightElbow]?.location ?? CGPoint.zero
        self.rightWrist = bodyParts[.rightWrist]?.location ?? CGPoint.zero
        self.rightShoulder = bodyParts[.rightShoulder]?.location ?? CGPoint.zero
        self.rightHip = bodyParts[.rightHip]?.location ?? CGPoint.zero
        self.rightKnee = bodyParts[.rightKnee]?.location ?? CGPoint.zero
        self.rightAnkle = bodyParts[.rightAnkle]?.location ?? CGPoint.zero
        
        // 左边
        self.leftElbow = bodyParts[.leftElbow]?.location ?? CGPoint.zero
        self.leftWrist = bodyParts[.leftWrist]?.location ?? CGPoint.zero
        self.leftShoulder = bodyParts[.leftShoulder]?.location ?? CGPoint.zero
        self.leftHip = bodyParts[.leftHip]?.location ?? CGPoint.zero
        self.leftKnee = bodyParts[.leftKnee]?.location ?? CGPoint.zero
        self.leftAnkle = bodyParts[.leftAnkle]?.location ?? CGPoint.zero
        
        self.AirPodsAvailable = (AirPodsMotion != nil) ? true : false
        
        if self.AirPodsAvailable {
            self.AirPodsMotion = CodableDeviceMotion(AirPodsMotion!)
        }
        
    }
    
}


enum ConnectedJoints: CaseIterable {
    case leftArm, rightArm, leftLeg, rightLeg, leftBodyAngle, rightBodyAngle, hipAngle, leftUpperLimb, rightUpperLimb
    
    func points(for pose: Pose) -> (CGPoint, CGPoint, CGPoint) {
        switch self {
        case .leftArm:
            return (pose.leftShoulder, pose.leftElbow, pose.leftWrist)
        case .rightArm:
            return (pose.rightShoulder, pose.rightElbow, pose.rightWrist)
        case .leftLeg:
            return (pose.leftHip, pose.leftKnee, pose.leftAnkle)
        case .rightLeg:
            return (pose.rightHip, pose.rightKnee, pose.rightAnkle)
        case .leftBodyAngle:
            return (pose.leftShoulder, pose.leftHip, pose.leftKnee)
        case .rightBodyAngle:
            return (pose.rightShoulder, pose.rightHip, pose.rightKnee)
        case .hipAngle:
            return(pose.rightKnee, pose.root, pose.leftKnee)
        case .leftUpperLimb:
            return(pose.leftElbow, pose.leftShoulder, pose.leftHip)
        case .rightUpperLimb:
            return(pose.rightElbow, pose.rightShoulder, pose.rightHip)
            
        }
        
    }
}

let connectedJointsGroups: [ConnectedJoints] = [.leftArm, .rightArm, .leftLeg, .rightLeg, .leftBodyAngle, .rightBodyAngle, .hipAngle, .leftUpperLimb, .rightUpperLimb]


// 计算这两个向量的点积和叉积，使用 atan2 函数来计算角度
func angleBetweenThreePoints(center: CGPoint, point1: CGPoint, point2: CGPoint) -> CGFloat {
    let vector1 = CGPoint(x: point1.x - center.x, y: point1.y - center.y)
    let vector2 = CGPoint(x: point2.x - center.x, y: point2.y - center.y)
    let dotProduct = vector1.x * vector2.x + vector1.y * vector2.y
    let crossProduct = vector1.x * vector2.y - vector1.y * vector2.x
    return atan2(crossProduct, dotProduct)
}





// 计算耳机的姿态角度
func AirPodsPoseDifference(pose1Motion: CodableDeviceMotion, pose2Motion: CodableDeviceMotion) -> AirPodsInfo
{
    // 获取两个姿态的四元数
    let quaternion1 = pose1Motion.quaternion
    let quaternion2 = pose2Motion.quaternion
    
    // 计算两个四元数之间的角度差异
    //    let angleDifference = cosineSimilarityBetween(quaternion1, quaternion2)
    let directionDifference = quaternionToEulerAngles(quaternion: quaternionBetween(quaternion1, quaternion2)) // 从 pose 1 到 2 需要的角度转变
    
    let userAccelerationDifference = differenceAcceleration(vector1: pose1Motion.userAcceleration, vector2: pose2Motion.userAcceleration)
    
    
    return AirPodsInfo(directionX: directionDifference.0,
                       directionY: directionDifference.1,
                       directionZ: directionDifference.2,
                       accelerationDifference: userAccelerationDifference)
}




//// 计算姿态的评分，目前默认耳机必须使用，否则不会开始
//func calculatePoseScore(pose1: Pose, pose2: Pose) -> ([ConnectedJoints : CGFloat], AirPodsInfo) {
//    var differences = [ConnectedJoints : CGFloat]()
//    for group in connectedJointsGroups {
//        let points1 = group.points(for: pose1)
//        let points2 = group.points(for: pose2)
//
//
//        let angle1 = angleBetweenThreePoints(center: points1.1, point1: points1.0, point2: points1.2)
//        let angle2 = angleBetweenThreePoints(center: points2.1, point1: points2.0, point2: points2.2)
//
//
//
//        differences[group] = (.pi - abs(angleDifference(angle1: angle1, angle2: angle2))) / .pi
//
//        if pose1.AirPodsAvailable && pose2.AirPodsAvailable {
//            // 如果耳机可用，则进行判断
//
//        }
//    }
//    return (differences, AirPodsPoseDifference(pose1Motion: pose1.AirPodsMotion!, pose2Motion: pose2.AirPodsMotion!))
//
//}

// 计算姿态的评分，目前默认耳机必须使用，否则不会开始
func calculatePoseScore(pose1: Pose, pose2: Pose) -> BodyInfo {
    var totalScore: Double = 0
    // TODO: 总分还没写
    var bodyInfo = BodyInfo(totalScore: 100,
                            leftArm: AngleInfo(score: 0, angleDifference: 0),
                            rightArm: AngleInfo(score: 0, angleDifference: 0),
                            leftLeg: AngleInfo(score: 0, angleDifference: 0),
                            rightLeg: AngleInfo(score: 0, angleDifference: 0),
                            leftBodyAngle: AngleInfo(score: 0, angleDifference: 0),
                            rightBodyAngle: AngleInfo(score: 0, angleDifference: 0),
                            hipAngle: AngleInfo(score: 0, angleDifference: 0),
                            leftUpperLimb: AngleInfo(score: 0, angleDifference: 0),
                            rightUpperLimb: AngleInfo(score: 0, angleDifference: 0),
                            airPodsInfo: AirPodsPoseDifference(pose1Motion: pose1.AirPodsMotion!, pose2Motion: pose2.AirPodsMotion!))
    
    for group in connectedJointsGroups {
        let points1 = group.points(for: pose1)
        let points2 = group.points(for: pose2)
        
        let angle1 = angleBetweenThreePoints(center: points1.1, point1: points1.0, point2: points1.2)
        let angle2 = angleBetweenThreePoints(center: points2.1, point1: points2.0, point2: points2.2)
        
        let angleDifference = angleDifference(angle1: angle1, angle2: angle2)
        let score = (.pi - abs(angleDifference)) / .pi
        
        // 加权计算分数
        let angleInfo = AngleInfo(score: Double(score), angleDifference: Double(angleDifference))
        
        switch group {
        case .leftArm:
            bodyInfo.leftArm = angleInfo
            totalScore += score
        case .rightArm:
            bodyInfo.rightArm = angleInfo
            totalScore += score
        case .leftLeg:
            bodyInfo.leftLeg = angleInfo
            totalScore += score
        case .rightLeg:
            bodyInfo.rightLeg = angleInfo
            totalScore += score
        case .leftBodyAngle:
            bodyInfo.leftBodyAngle = angleInfo
            totalScore += score * 2
        case .rightBodyAngle:
            bodyInfo.rightBodyAngle = angleInfo
            totalScore += score * 2
        case .hipAngle:
            bodyInfo.hipAngle = angleInfo
            totalScore += score * 2
        case .leftUpperLimb:
            bodyInfo.leftUpperLimb = angleInfo
            totalScore += score * 2
        case .rightUpperLimb:
            bodyInfo.rightUpperLimb = angleInfo
            totalScore += score * 2
        }
    }
    totalScore /= 1 + 1 + 1 + 1 + 2 + 2 + 2 + 2 + 2
    totalScore -= abs(bodyInfo.airPodsInfo.accelerationDifference) / 10
    
    // 计算平方和
    let squaredSum = bodyInfo.airPodsInfo.directionX * bodyInfo.airPodsInfo.directionX +
    bodyInfo.airPodsInfo.directionY * bodyInfo.airPodsInfo.directionY +
    bodyInfo.airPodsInfo.directionZ * bodyInfo.airPodsInfo.directionZ
    totalScore -= squaredSum / 10
    if totalScore < 0 {
        totalScore = 0
    }
    
    bodyInfo.totalScore = totalScore
    
    return bodyInfo
}



// 计算角度的差异
func calculateAngleDifferences(pose1: Pose, pose2: Pose) -> [ConnectedJoints : CGFloat] {
    var differences = [ConnectedJoints : CGFloat]()
    for group in connectedJointsGroups {
        let points1 = group.points(for: pose1)
        let points2 = group.points(for: pose2)
        
        
        let angle1 = angleBetweenThreePoints(center: points1.1, point1: points1.0, point2: points1.2)
        let angle2 = angleBetweenThreePoints(center: points2.1, point1: points2.0, point2: points2.2)
        differences[group] = angleDifference(angle1: angle1, angle2: angle2)
        
    }
    return differences
}


// JSON转化方法
func poseArraysToJSON(poses: [Pose]) -> String? {
    let encoder = JSONEncoder()
    do {
        let data = try encoder.encode(poses)
        return String(data: data, encoding: .utf8)
    } catch {
        print("Error encoding poses: \(error)")
        return nil
    }
}

// JSON转化回来的方法
func poseArraysFromJSON(json: String) -> [Pose]? {
    let decoder = JSONDecoder()
    do {
        if let data = json.data(using: .utf8) {
            let poses = try decoder.decode([Pose].self, from: data)
            return poses
        }
    } catch {
        print("Error decoding poses: \(error)")
    }
    return nil
}
