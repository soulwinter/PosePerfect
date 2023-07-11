//
//  Data.swift
//  PosePerfect
//
//  Created by Han Chubo on 2023/7/10.
//

import Foundation
import Vision


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

    init(time: Float, bodyParts: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
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

// angleDifference 函数计算两个角度的差，它使用的是在圆上测量角度的方法，考虑到了角度可能超过 360 度的情况
func angleDifference(angle1: CGFloat, angle2: CGFloat) -> CGFloat {
    return atan2(sin(angle2 - angle1), cos(angle2 - angle1))
}

func calculatePoseScore(pose1: Pose, pose2: Pose) -> [ConnectedJoints : CGFloat] {
    var differences = [ConnectedJoints : CGFloat]()
    for group in connectedJointsGroups {
        let points1 = group.points(for: pose1)
        let points2 = group.points(for: pose2)
        
        
        let angle1 = angleBetweenThreePoints(center: points1.1, point1: points1.0, point2: points1.2)
        let angle2 = angleBetweenThreePoints(center: points2.1, point1: points2.0, point2: points2.2)
        
        differences[group] = (3.1415926 - abs(angleDifference(angle1: angle1, angle2: angle2))) / (3.1415926)
    }
    return differences
        
}
    

func calculateAngleDifferences(pose1: Pose, pose2: Pose) -> [ConnectedJoints : CGFloat] {
    var differences = [ConnectedJoints : CGFloat]()
    for group in connectedJointsGroups {
        let points1 = group.points(for: pose1)
        let points2 = group.points(for: pose2)
        
        
        let angle1 = angleBetweenThreePoints(center: points1.1, point1: points1.0, point2: points1.2)
        let angle2 = angleBetweenThreePoints(center: points2.1, point1: points2.0, point2: points2.2)
        differences[group] = angleDifference(angle1: angle1, angle2: angle2)
        
//        if group == .bodyAngle {
//            print(points1)
//            print(points2)
//            print(angle1)
//            print(angle2)
//            print(differences[group])
//        }
        
        
    }
    return differences
}
