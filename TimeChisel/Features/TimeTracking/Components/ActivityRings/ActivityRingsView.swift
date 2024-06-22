//
//  ActivityRingsView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 18.02.24.
//

import SwiftUI

struct ActivityRingsView: View {
    
    // TODO: Replace this with computed prop and workingHoursPerDay and PauseTime data from local storage!"
    let totalWorkTime = 40
    let totalPauseTime = 40
    
    @Binding var secondsWorked: Int
    @Binding var secondsPaused: Int
    
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

#Preview {
    @State var dummySeconds = 3600
    return ActivityRingsView(secondsWorked: $dummySeconds, secondsPaused: $dummySeconds)
}
