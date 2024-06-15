//
//  EditJobView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 10.02.24.
//

import SwiftUI

struct UpdateJobView: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @Bindable var jobModel: JobModel
    @FocusState var focus: FocusableField?
    
    var body: some View {
        NavigationView {
            Form {
                Section("Jobinfos") {
                    TextField("Name des Unternehmens", text: $jobModel.companyName)
                        .focused($focus, equals: .company)
                    
                    TextField("Job-Titel", text: $jobModel.jobTitle)
                        .focused($focus, equals: .jobTitle)
                    
                    HStack {
                        TextField("Stundenlohn", value: hourlyRateBinding(), format: .number)
                            .keyboardType(.decimalPad)
                            .focused($focus, equals: .hourlyRate)
                        
                        Picker("", selection: $jobModel.hourlyRate.currency) {
                            ForEach(HourlyRate.Currency.allCases, id: \.self) { currency in
                                Text(currency.rawValue).tag(currency)
                            }
                        }
                    }
                }
                
                Section("Arbeitszeiten") {
                    TextField("Stunden pro Woche", value: workingHoursBinding(), format: .number)
                        .keyboardType(.decimalPad)
                        .focused($focus, equals: .hourlyRate)
                    
                    Picker("Tage pro Woche", selection: $jobModel.workingDaysPerWeek) {
                        ForEach(1...6, id: \.self) {
                            Text("\($0) Tage")
                        }
                    }
                    
                    
                    Picker("Pause am Tag", selection: $jobModel.pauseMinutesPerDay) {
                        ForEach(0...4, id: \.self) { index in
                            let minutes = index * 30
                            Text("\(minutes) Minuten")
                        }
                    }
                }
                
                Section {
                    HStack{
                        Button(action: {
                            dismiss()
                        }, label: {
                            Text("Fertig")
                                .frame(maxWidth: .infinity, alignment: .center)
                        })
                    }
                }
                .buttonStyle(.borderless)
                
            }
            .navigationTitle("Bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button {
                        previous()
                    } label: {
                        Image(systemName: "chevron.up")
                    }
                    
                    Button {
                        next()
                    } label: {
                        Image(systemName: "chevron.down")
                    }
                    
                    Spacer()
                    
                    Button("Fertig") {
                        dismissKeyboard()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Label("Schließen", systemImage: "xmark.circle.fill")
                    })
                }
            }
 // TODO: Try to make Picker work alongside tab gesture!
//            .simultaneousGesture(
//                TapGesture()
//                    .onEnded {
//                        dismissKeyboard()
//                    }
//            )
        }
    }
    
    private func dismissKeyboard() {
        focus = nil
    }
    
    private func hourlyRateBinding() -> Binding<Double?> {
        Binding<Double?>(
            get: {
                jobModel.hourlyRate.value > 0 ? jobModel.hourlyRate.value : nil
            },
            
            set: { newValue in
                jobModel.hourlyRate.value = newValue ?? 0
            }
        )
    }
    
    private func workingHoursBinding () -> Binding <Int?> {
        Binding<Int?>(
            get: {
                jobModel.workingHoursPerWeek > 0 ? jobModel.workingHoursPerWeek : nil
            },
            set: { newValue in
                jobModel.workingHoursPerWeek = newValue ?? 0
            }
        )
    }
    
    private func next() {
        guard let currentInput = focus,
              let lastIndex = FocusableField.allCases.last?.rawValue else { return }
        
        let index = min(currentInput.rawValue + 1, lastIndex)
        self.focus = FocusableField(rawValue: index)
    }
    
    private func previous() {
        guard let currentInput = focus,
              let lastIndex = FocusableField.allCases.last?.rawValue else { return }
        
        let index = min(currentInput.rawValue - 1, lastIndex)
        self.focus = FocusableField(rawValue: index)
    }
}



//#Preview {
//    EditJobView()
//}
