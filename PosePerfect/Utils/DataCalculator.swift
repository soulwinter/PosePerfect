//
//  DataCalculator.swift
//  PosePerfect
//
//  Created by Han Chubo on 2023/7/12.
//

import Foundation
import CoreMotion

// angleDifference 函数计算两个角度的差，它使用的是在圆上测量角度的方法，考虑到了角度可能超过 360 度的情况
func angleDifference(angle1: CGFloat, angle2: CGFloat) -> CGFloat {
    return atan2(sin(angle2 - angle1), cos(angle2 - angle1))
}


// 计算两个四元数之间的角度差异
func quaternionAngleDifference(_ q1: CodableQuaternion, _ q2: CodableQuaternion) -> Double {
    // 计算点积
    let dotProduct = q1.w * q2.w + q1.x * q2.x + q1.y * q2.y + q1.z * q2.z
    // 计算旋转角度（弧度）
    let angleRad = acos(dotProduct) * 2

    return angleRad
}

// 计算两个四元数之间的余弦相似度
func cosineSimilarityBetween(_ quaternion1: CodableQuaternion, _ quaternion2: CodableQuaternion) -> Double {
    // 计算四元数向量的点积
    let dotProduct = quaternion1.w * quaternion2.w + quaternion1.x * quaternion2.x + quaternion1.y * quaternion2.y + quaternion1.z * quaternion2.z

    // 计算四元数向量的模长
    let magnitude1 = sqrt(quaternion1.w * quaternion1.w + quaternion1.x * quaternion1.x + quaternion1.y * quaternion1.y + quaternion1.z * quaternion1.z)
    let magnitude2 = sqrt(quaternion2.w * quaternion2.w + quaternion2.x * quaternion2.x + quaternion2.y * quaternion2.y + quaternion2.z * quaternion2.z)

    // 计算并返回余弦相似度
    let cosineSimilarity = dotProduct / (magnitude1 * magnitude2)
    return cosineSimilarity
}


// 从 quaternion1 旋转到 quaternion2 需要的旋转。
// 旋转轴可以通过四元数的 x, y, z 值获取，旋转角度可以通过 2 * acos(w) 计算。具体的方向取决于旋转轴的方向。
func quaternionBetween(_ quaternion1: CodableQuaternion, _ quaternion2: CodableQuaternion) -> CodableQuaternion {
    // 计算 quaternion1 的逆
    let inverseQuaternion1 = CodableQuaternion(x: -quaternion1.x, y: -quaternion1.y, z: -quaternion1.z, w: quaternion1.w)

    // 计算两个四元数之间的旋转
    let rotationQuaternion = CodableQuaternion(
        x: inverseQuaternion1.w * quaternion2.x + inverseQuaternion1.x * quaternion2.w + inverseQuaternion1.y * quaternion2.z - inverseQuaternion1.z * quaternion2.y,
        y: inverseQuaternion1.w * quaternion2.y - inverseQuaternion1.x * quaternion2.z + inverseQuaternion1.y * quaternion2.w + inverseQuaternion1.z * quaternion2.x,
        z: inverseQuaternion1.w * quaternion2.z + inverseQuaternion1.x * quaternion2.y - inverseQuaternion1.y * quaternion2.x + inverseQuaternion1.z * quaternion2.w,
        w: inverseQuaternion1.w * quaternion2.w - inverseQuaternion1.x * quaternion2.x - inverseQuaternion1.y * quaternion2.y - inverseQuaternion1.z * quaternion2.z)

    return rotationQuaternion
}

// 将四元数改为欧拉角
// 滚动角(Roll): 描述的是物体围绕其前后（或X轴）的旋转，就像飞机翻滚一样。比如，想象一辆前进的自行车，当自行车左右摇晃时，我们就称自行车正在滚动。
// 俯仰角(Pitch): 描述的是物体围绕其左右轴（或Y轴）的旋转，就像飞机抬头或俯冲一样。继续上面的自行车例子，当自行车的前轮抬起或压下，我们就称自行车在做俯仰动作。
// 偏航角(Yaw): 描述的是物体围绕其垂直轴（或Z轴）的旋转，就像飞机左右转弯一样。还是那个自行车，当你转动把手左右转弯时，这就是偏航动作。
func quaternionToEulerAngles(quaternion: CodableQuaternion) -> (Double, Double, Double) {
    let qw = quaternion.w
    let qx = quaternion.x
    let qy = quaternion.y
    let qz = quaternion.z

    let roll = atan2(2.0*(qw*qx + qy*qz), 1.0 - 2.0*(qx*qx + qy*qy))
    let pitch = asin(2.0*(qw*qy - qz*qx))
    let yaw = atan2(2.0*(qw*qz + qx*qy), 1.0 - 2.0*(qy*qy + qz*qz))
    
    return (roll, pitch, yaw)
}


// 计算3D角的差异
func differenceAcceleration(vector1: CodableAcceleration, vector2: CodableAcceleration) -> Double {
    let magnitude1 = sqrt(pow(vector1.x, 2) + pow(vector1.y, 2) + pow(vector1.z, 2))
    let magnitude2 = sqrt(pow(vector2.x, 2) + pow(vector2.y, 2) + pow(vector2.z, 2))

    return magnitude1 - magnitude2
}


func formatTime(time: Float) -> String {
    let totalSeconds = Int(time)
    let minutes = totalSeconds / 60
    let seconds = totalSeconds % 60
    let fractionOfSecond = Int((time - Float(totalSeconds)) * 10)

    return String(format: "%02d:%02d.%d", minutes, seconds, fractionOfSecond)
}
