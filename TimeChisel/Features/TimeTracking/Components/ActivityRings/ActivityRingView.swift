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
    
    private var strokeStyle: StrokeStyle {
        StrokeStyle(lineWidth: ringThickness, lineCap: .round)
    }

    private var gradientEffect: AngularGradient {
        let steps = 16
        let stops = (0...steps).map { step in
            let fraction = Double(step) / Double(steps)
            return Gradient.Stop(
                color: Self.interpolate(from: gradientStartColor, to: gradientEndColor, fraction: fraction),
                location: fraction
            )
        }
        return AngularGradient(gradient: Gradient(stops: stops), center: .center, startAngle: rotationDegree, endAngle: .degrees(270))
    }

    private var gradientStartColor: Color {
        colorGradient.stops.first?.color ?? .clear
    }

    private var gradientEndColor: Color {
        colorGradient.stops.last?.color ?? .clear
    }

    private var currentProgressColor: Color {
        let fraction = min(max(completionRate, 0), 1)
        return Self.interpolate(from: gradientStartColor, to: gradientEndColor, fraction: fraction)
    }

    private static func interpolate(from: Color, to: Color, fraction: Double) -> Color {
        var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        UIColor(from).getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        UIColor(to).getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        let t = CGFloat(fraction)
        return Color(
            red: r1 + (r2 - r1) * t,
            green: g1 + (g2 - g1) * t,
            blue: b1 + (b2 - b1) * t,
            opacity: a1 + (a2 - a1) * t
        )
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
                .trim(from: 0, to: min(CGFloat(completionRate), 1))
                .stroke(gradientEffect, style: StrokeStyle(lineWidth: ringThickness, lineCap: .butt))
                .overlay(startCapCircle)
                .overlay(overshootArc)
                .overlay(overlayCircle)
                .opacity(completionRate == 0.0 ? 0.0 : 1)
        }
        .frame(width: WHeight, height: WHeight)
        .overlay(alignment: .top) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .bold()
                .offset(y: -12)
                .foregroundColor(Color("customBW"))
                .opacity(completionRate == 0.0 ? 0.65 : 1)
        }
    }
    
    var startCapCircle: some View {
        GeometryReader { geo in
            Circle().fill(gradientStartColor)
                .frame(width: ringThickness, height: ringThickness)
                .position(overlayPostition(geo.size.width, geo.size.height))
                .offset(x: overlayOffset(geo.size.width, geo.size.height))
                .rotationEffect(rotationDegree)
        }
    }

    @ViewBuilder
    var overshootArc: some View {
        if completionRate > 1 {
            Circle().rotation(rotationDegree)
                .trim(from: 0, to: min(CGFloat(completionRate - 1), 1))
                .stroke(gradientEndColor, style: strokeStyle)
        }
    }

    var overlayCircle: some View {
        GeometryReader { geo in
            Circle().fill(currentProgressColor)
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
    VStack(spacing: 50) {
        ActivityRingView(icon: "clock", bg: "testCustomColor", WHeight: 150, completionRate: 0.02, ringThickness: 30, baseColor: .green, colorGradient: Gradient(colors: [.green, .yellow]))
        ActivityRingView(icon: "clock", bg: "testCustomColor", WHeight: 150, completionRate: 0.5, ringThickness: 30, baseColor: .green, colorGradient: Gradient(colors: [.green, .yellow]))
        ActivityRingView(icon: "clock", bg: "testCustomColor", WHeight: 150, completionRate: 1.5, ringThickness: 30, baseColor: .green, colorGradient: Gradient(colors: [.green, .yellow]))
    }
}
