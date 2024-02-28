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
            HStack {
                // TODO: change button background colors
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Text("Pause")
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
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
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
    TimeTrackingView()
}
