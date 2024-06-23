//
//  TrackingViewModel.swift
//  TimeChisel
//
//  Created by Karsten Krause on 21.06.24.
//

import SwiftUI
import Observation
import Combine

@Observable
class TrackingViewModel {
    var secondsWorked: Int = 0
    var secondsPaused: Int = 0
    var workedTimer: AnyCancellable?
    var pausedTimer: AnyCancellable?
    
    func startWorkedTimer() {
        workedTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { _ in
//            withAnimation {
//                self.secondsWorked += 1
//            }
            self.secondsWorked += 1
        }
    }
    
    func stopWorkedTimer() {
        workedTimer?.cancel()
    }
    
    func startPausedTimer() {
        pausedTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { _ in
//            withAnimation {
//                self.secondsPaused += 1
//            }
            self.secondsPaused += 1
            
        }
    }
    
    func stopPausedTimer() {
        pausedTimer?.cancel()
    }
    
    func endAll() {
        stopWorkedTimer()
        stopPausedTimer()
        
        self.secondsWorked = 0
        self.secondsPaused = 0
    }
}
