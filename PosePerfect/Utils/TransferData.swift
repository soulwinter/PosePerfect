//
//  TransferData.swift
//  PosePerfect
//
//  Created by Han Chubo on 2023/7/12.
//

import Foundation

struct BodyInfo: Codable {
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

struct AngleInfo: Codable {
    var score: Double
    var angleDifference: Double
}

struct AirPodsInfo: Codable {
    
    var directionX: Double
    var directionY: Double
    var directionZ: Double
    
    var accelerationDifference: Double
    
}

func bodyInfoToJSON(bodyInfo: BodyInfo) -> String {
    let encoder = JSONEncoder()
//    encoder.outputFormatting = .prettyPrinted

    do {
        let jsonData = try encoder.encode(bodyInfo)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
    } catch {
        print("Error encoding BodyInfo: \(error)")
    }

    return "" // or you may want to return nil or throw the error
}
