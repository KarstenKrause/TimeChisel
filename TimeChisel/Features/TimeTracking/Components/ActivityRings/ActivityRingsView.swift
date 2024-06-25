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
        
        
        //TODO: Maybe find a better solution. Only indeces from the picker are stored in AddJobView and UpdateJobView.
        //TODO: Try to store the pause minutes directly to the local storage in order to get rid of this switch-statement.
        switch pauseMinutes {
            case 1 : self.totalPauseTime = 15 * 60 // Debug: self.totalPauseTime = 15
                break
            case 2 : self.totalPauseTime = 30 * 60 // Debug: self.totalPauseTime = 30
                break
            case 3 : self.totalPauseTime = 45 * 60 // Debug: self.totalPauseTime = 40
                break
            case 4 : self.totalPauseTime = 60 * 60 // Debug: self.totalPauseTime = 50
                break
            default:
                self.totalPauseTime = self.pauseMinutes // will never be a case -> find a better solution to store pause minutes!
        }

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
