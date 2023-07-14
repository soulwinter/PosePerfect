//
//  Color.swift
//  PosePerfect
//
//  Created by Han Chubo on 2023/7/6.
//
import Foundation
import SwiftUI
import UIKit


// Use Color Hex extention
extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}


extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
}



struct Stick: Shape {
    var points: [CGPoint]
    var size: CGSize
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // 过滤识别为边缘的点
        let filteredPoints = points.filter { $0 != CGPoint(x: 0, y: 0) && $0 != CGPoint(x: 0, y: 1) && $0 != CGPoint(x: 1, y: 0) && $0 != CGPoint(x: 1, y: 1) }
        
        guard let firstPoint = filteredPoints.first else { return path }
        
        path.move(to: firstPoint)
        for point in filteredPoints.dropFirst() {
            path.addLine(to: point)
        }
        return path.applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))
            .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height))
    }
}

