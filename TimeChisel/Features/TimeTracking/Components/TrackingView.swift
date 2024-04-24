//
//  TrackingView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 24.04.24.
//

import SwiftUI

struct TrackingView: View {
    @State private var secondsWorked: Int = 7200 // 2h
    @State private var secondsPaused: Int = 900 // 0.5h
    @State private var isPauseTimerRunning: Bool = false
    @State private var timeTrackingCanceled: Bool = false
    @Binding var isWorkingTimerRunning: Bool
    
    var body: some View {
        VStack {
            ActivityRingsView(secondsWorked: $secondsWorked, secondsPaused: $secondsPaused)
            HStack {
                // TODO: change button background colors
                Button(action: {
                    self.isWorkingTimerRunning = true
                }, label: {
                    Text("Pause")
                        .font(.footnote)
                        .frame(width: 80, height: 80, alignment: .center)
                        .background(Color.blue)
                        .foregroundColor(.primary)
                        .cornerRadius(100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 100)
                                .stroke(Color.black, lineWidth: 1.5)
                                .padding(4)
                        )
                })
                Spacer()
                Button(action: {
                    self.timeTrackingCanceled = true
                    self.isWorkingTimerRunning = false
                }, label: {
                    Text("Beenden")
                        .font(.footnote)
                        .frame(width: 80, height: 80, alignment: .center)
                        .background(Color.gray)
                        .foregroundColor(.primary)
                        .cornerRadius(100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 100)
                            // TODO: create custom background color for light-/darkmode
                                .stroke(Color.black, lineWidth: 1.5)
                                .padding(4)
                        )
                })
            }
            .padding()
        }
    }
}

#Preview {
    @State var isWorkingTimerRunning: Bool = false
    return TrackingView(isWorkingTimerRunning: $isWorkingTimerRunning)
}
