//
//  TransferData.swift
//  PosePerfect
//
//  Created by Han Chubo on 2023/7/12.
//

import Foundation

struct BodyInfo {
    var totalScore: Double //总得分

    var leftArm: AngleInfo
    var rightArm: AngleInfo
    var leftLeg: AngleInfo
    var rightLeg: AngleInfo
    var leftBodyAngle: AngleInfo
    var rightBodyAngle: AngleInfo
    var hipAngle: AngleInfo
    var leftUpperLimb: AngleInfo
    var rightUpperLimb: AngleInfo
    
    var airPodsInfo: AirPodsInfo

}

struct AngleInfo {
    var score: Double
    var standardAngle: Double
    var currentAngle: Double
}

struct AirPodsInfo {
    
    var directionX: Double
    var directionY: Double
    var directionZ: Double
    
    var accelerationDifference: Double
    
}

