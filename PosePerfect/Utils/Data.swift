//
//  Data.swift
//  PosePerfect
//
//  Created by Han Chubo on 2023/7/10.
//

import Foundation
import Vision
import CoreMotion

// Create a new pose: let pose = Pose(time: currentTime, bodyParts: poseEstimator.bodyParts)
struct Pose {
    var time: Float
    
    // 面部
    var nose: CGPoint
    var rightEye: CGPoint
    var leftEye: CGPoint
    var rightEar: CGPoint
    var leftEar: CGPoint
    
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
    var AirPodsMotion: CMDeviceMotion?
    
    init(time: Float, bodyParts: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint], AirPodsMotion: CMDeviceMotion?) {
        self.time = time
        
        // 面部
        self.nose = bodyParts[.nose]?.location ?? CGPoint.zero
        self.rightEye = bodyParts[.rightEye]?.location ?? CGPoint.zero
        self.leftEye = bodyParts[.leftEye]?.location ?? CGPoint.zero
        self.rightEar = bodyParts[.rightEar]?.location ?? CGPoint.zero
        self.leftEar = bodyParts[.leftEar]?.location ?? CGPoint.zero
        
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
        self.AirPodsMotion = AirPodsMotion
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
func AirPodsPoseDifference(pose1Motion: CMDeviceMotion, pose2Motion: CMDeviceMotion) -> AirPodsInfo
{
    // 获取两个姿态的四元数
    let quaternion1 = pose1Motion.attitude.quaternion
    let quaternion2 = pose2Motion.attitude.quaternion
    
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

        let angleInfo = AngleInfo(score: Double(score), angleDifference: Double(angleDifference))

        switch group {
        case .leftArm:
            bodyInfo.leftArm = angleInfo
        case .rightArm:
            bodyInfo.rightArm = angleInfo
        case .leftLeg:
            bodyInfo.leftLeg = angleInfo
        case .rightLeg:
            bodyInfo.rightLeg = angleInfo
        case .leftBodyAngle:
            bodyInfo.leftBodyAngle = angleInfo
        case .rightBodyAngle:
            bodyInfo.rightBodyAngle = angleInfo
        case .hipAngle:
            bodyInfo.hipAngle = angleInfo
        case .leftUpperLimb:
            bodyInfo.leftUpperLimb = angleInfo
        case .rightUpperLimb:
            bodyInfo.rightUpperLimb = angleInfo
        }
    }
    
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
