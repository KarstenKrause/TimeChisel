//
//  TimeView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 23.06.24.
//

import SwiftUI

struct TimeView: View {
    @Bindable var timeVM: TimeViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .center) {
            Text("\(timeVM.getTime())")
                .font(.custom("Helvetica Neue", size: 38))
                .foregroundStyle(timeVM.timeType == .workTime ? Color("lightGreen") : (colorScheme == .dark ? Color("lightBlue") : .blue))
                .bold()
            
            Text(timeVM.timeType == .workTime ? "In Arbeit": "In Pause")
                .foregroundStyle(timeVM.timeType == .workTime ? Color("lightGreen") : (colorScheme == .dark ? Color("lightBlue") : .blue))
                .bold()
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var time = 20000
        
        var body: some View {
            TimeView(timeVM: TimeViewModel(seconds: time, for: .breakTime))
        }
        
    }
    return PreviewWrapper()
}
