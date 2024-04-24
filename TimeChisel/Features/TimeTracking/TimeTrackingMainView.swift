//
//  TimeTrackingView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 02.02.24.
//

import SwiftUI

struct TimeTrackingMainView: View {
    @State private var isWorkingTimerRunning: Bool = false
    @State private var isPauseTimerRunning: Bool = false
    @State private var timeTrackingCanceled: Bool = false
    
    var body: some View {
        VStack {
            if (!isWorkingTimerRunning) {
                Spacer()
                Button(action: {
                    self.isWorkingTimerRunning.toggle()
                }, label: {
                    Text("Starten")
                        .font(.footnote)
                        .frame(width: 80, height: 80, alignment: .center)
                        .background(Color.green)
                        .foregroundColor(.primary)
                        .cornerRadius(100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 100)
                                .stroke(Color.black, lineWidth: 1.5)
                                .padding(4)
                        )
                })
                Spacer()
            } else {
                TrackingView(isWorkingTimerRunning: $isWorkingTimerRunning)
            }
        }
    }
}

#Preview {
    TimeTrackingMainView()
}
