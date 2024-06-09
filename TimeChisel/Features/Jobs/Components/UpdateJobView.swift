//
//  EditJobView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 10.02.24.
//

import SwiftUI

enum FocusableField: Hashable {
    case company
    case jobTitle
    case hourlyRate

}

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
                    Picker("Stunden pro Woche", selection: $jobModel.workingHoursPerWeek) {
                        ForEach(1...60, id: \.self) {
                            Text("\($0) Stunden")
                        }
                    }
                    
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Label("Schließen", systemImage: "xmark.circle.fill")
                    })
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Fertig") {
                        dismissKeyboard()
                    }
                }
            }
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
    
  
}

//#Preview {
//    EditJobView()
//}
