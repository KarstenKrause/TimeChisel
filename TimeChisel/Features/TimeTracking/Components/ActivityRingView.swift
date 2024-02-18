//
//  ActivityRings.swift
//  TimeChisel
//
//  Created by Karsten Krause on 17.02.24.
//

import SwiftUI

struct ActivityRingView: View {
    var icon: String
    var bg: String
    var WHeight: CGFloat
    var completionRate: Double
    var ringThickness: CGFloat
    var baseColor: Color
    var colorGradient: Gradient
    
    private var rotationDegree: Angle {
        .degrees(-90)
    }
    
    private var endAngle: Angle {
        .degrees(completionRate * 360 - 90)
    }
    
    private var strokeStyle: StrokeStyle {
        StrokeStyle(lineWidth: ringThickness, lineCap: .round)
    }
    
    private var gradientEffect: AngularGradient {
        AngularGradient(gradient: colorGradient, center: .center, startAngle: rotationDegree, endAngle: endAngle)
    }
    
    private var gradientEndColor: Color {
        colorGradient.stops.indices.contains(1) ? colorGradient.stops[1].color : Color.clear
    }
    
    private var circleShadow: Color {
        .black.opacity(0.9)
    }
    
    private var overlayPostition: (_ width: CGFloat, _ height: CGFloat) -> CGPoint {
        return { width, height in
            CGPoint(x: width / 2, y: height / 2)
        }
    }
    
    private var overlayOffset: (_ width: CGFloat, _ height: CGFloat) -> CGFloat {
        return { width, height in
            min(width, height) / 2
        }
    }
    
    private var overlayRotation: Angle {
        .degrees(completionRate * 360 - 90)
    }
    
    private var clippedCircleRotation: Angle {
        .degrees(-90 + completionRate * 360)
    }
    
    var body: some View {
        ZStack {
            Circle().stroke(lineWidth: 30).foregroundColor(baseColor.opacity(0.2))
            Circle().rotation(rotationDegree)
                .trim(from: 0, to: CGFloat(completionRate))
                .stroke(gradientEffect, style: strokeStyle)
                .overlay(overlayCircle)
                .opacity(completionRate == 0.0 ? 0.0 : 1)
        }
        .frame(width: WHeight, height: WHeight)
        .overlay(alignment: .top) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .bold()
                .offset(y: -12)
                .foregroundColor(.black)
                .opacity(completionRate == 0.0 ? 0.65 : 1)
        }
    }
    
    var overlayCircle: some View {
        GeometryReader { geo in
            Circle().fill(gradientEndColor)
                .frame(width: ringThickness, height: ringThickness)
                .position(overlayPostition(geo.size.width, geo.size.height))
                .offset(x: overlayOffset(geo.size.width, geo.size.height))
                .rotationEffect(overlayRotation)
                .shadow(color: circleShadow, radius: ringThickness / 5)
        }
        .clipShape(
            Circle().rotation(clippedCircleRotation).trim(from: 0, to: 0.1)
                .stroke(style: strokeStyle)
        )
    }
}

#Preview {
    ActivityRingView(icon: "clock", bg: "testCustomColor", WHeight: 300, completionRate: 0.0, ringThickness: 30, baseColor: .red ,colorGradient: Gradient(colors: [.red, .pink]))
}
