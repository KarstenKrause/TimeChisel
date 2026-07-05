//
//  ActivityRingsView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 18.02.24.
//

import SwiftUI
import SwiftData

struct ActivityRingsView: View {
    private var totalWorkTime: Int
    private var pauseTimeSeconds: Int
    private var workingHours: Double
    private var pauseMinutes: Int

    private let secondsWorked: Int
    private let secondsPaused: Int

    init(workingHours: Double, pauseMinutes: Int, secondsWorked: Int, secondsPaused: Int) {
        self.secondsWorked = secondsWorked
        self.secondsPaused = secondsPaused
        self.workingHours = workingHours
        self.pauseMinutes = pauseMinutes
        self.totalWorkTime = Int(self.workingHours * 3600)
        self.pauseTimeSeconds = pauseMinutes * 60

    }
    
    private var timeProgress: CGFloat {
        // Ohne Tagessoll (z. B. Arbeit an einem freien Tag) bleibt der Ring leer.
        guard totalWorkTime > 0 else { return 0 }
        return CGFloat(secondsWorked) / CGFloat(totalWorkTime)
    }

    private var pauseTimeProgress: CGFloat {
        guard pauseTimeSeconds > 0 else { return 0 }
        return CGFloat(secondsPaused) / CGFloat(pauseTimeSeconds)
    }
    
    
    var body: some View {
        ZStack {
            ActivityRingView(icon: "clock",
                             bg: "testCustomColor",
                             WHeight: 300,
                             completionRate: timeProgress,
                             ringThickness: 30,
                             baseColor: .green,
                             colorGradient: Gradient(colors: [.green, .yellow])
            )
            
            ActivityRingView(icon: "pause.circle",
                             bg: "testCustomColor",
                             WHeight: 230,
                             completionRate: pauseTimeProgress,
                             ringThickness: 30,
                             baseColor: .blue,
                             colorGradient: Gradient(colors: [.blue, .purple])
            )
        }
    }
}

//#Preview {
//    @State var dummySeconds = 3600
//    return ActivityRingsView(secondsWorked: $dummySeconds, secondsPaused: $dummySeconds)
//}
