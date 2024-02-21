//
//  TimeTrackingView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 02.02.24.
//

import SwiftUI

struct TimeTrackingView: View {
    @State private var secondsWorked: Int = 7200 // 2h
    @State private var secondsPaused: Int = 900 // 0.5h
    
    var body: some View {
        VStack {
            ActivityRingsView(secondsWorked: $secondsWorked, secondsPaused: $secondsPaused)
        }
    }
}

#Preview {
    TimeTrackingView()
}
