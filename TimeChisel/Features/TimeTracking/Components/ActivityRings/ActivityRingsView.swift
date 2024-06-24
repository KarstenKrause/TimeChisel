//
//  ActivityRingsView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 18.02.24.
//

import SwiftUI
import SwiftData

struct ActivityRingsView: View {
    
    // TODO: Replace this with computed prop and workingHoursPerDay and PauseTime data from local storage!"

    private var totalWorkTime: Int
    private var totalPauseTime: Int
    
    private var workingHours: Int
    private var pauseMinutes: Int
    
    @Binding var secondsWorked: Int
    @Binding var secondsPaused: Int
    
    init(workingHours: Int, pauseMinutes: Int, secondsWorked: Binding<Int>, secondsPaused: Binding<Int>) {
        self._secondsWorked = secondsWorked
        self._secondsPaused = secondsPaused
        self.workingHours = workingHours
        self.pauseMinutes = pauseMinutes
        self.totalWorkTime = self.workingHours * 3600
        self.totalPauseTime = self.pauseMinutes * 60
        print(totalWorkTime)
        print(totalPauseTime)
    }
    
    private var timeProgress: CGFloat {
        let totalTime = CGFloat(totalWorkTime)
        let workedPercentage = CGFloat(secondsWorked) / totalTime
        
        return workedPercentage
    }
    
    private var pauseTimeProgress: CGFloat {
        let totalTime = CGFloat(totalPauseTime)
        let pausedTimePercentage = CGFloat(secondsPaused) / totalTime
        
        return pausedTimePercentage
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
