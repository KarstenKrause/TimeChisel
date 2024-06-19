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
    @State private var companyName = ""
    @State private var jobTitle = ""
    @State private var hourlyRate = HourlyRate(value: 0, currency: .EUR)
    @State private var workingHours: Int = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section("Jobinfos") {
                        VStack(alignment: .leading) {
                            companyName.isEmpty ? nil :
                            Text("Name des unternehmens")
                                .foregroundStyle(.gray)
                                
                            TextField("Name des Unternehmens", text: $companyName)
                                .focused($focus, equals: .company)
                        }
                        VStack(alignment: .leading) {
                            jobTitle.isEmpty ? nil :
                            Text("Job-Titel").foregroundStyle(.gray)
                            
                            TextField("Job-Titel", text: $jobTitle)
                                .focused($focus, equals: .jobTitle)
                        }
                        
                        VStack(alignment: .leading) {
                            if String(hourlyRate.value).isEmpty == false {
                                Text("Stundenlohn").foregroundStyle(.gray)
                            }
                            
                            
                            HStack {
                                TextField("", value: $hourlyRate.value, format: .number)
                                    .keyboardType(.decimalPad)
                                    .focused($focus, equals: .hourlyRate)
                                
                                Picker("", selection: $jobModel.hourlyRate.currency) {
                                    ForEach(HourlyRate.Currency.allCases, id: \.self) { currency in
                                        Text(currency.rawValue).tag(currency)
                                    }
                                }
                            }
                        }

                    }
                    
                    Section("Arbeitszeiten") {
                        VStack(alignment: .leading) {
        
                            Text("Stunden pro Woche").foregroundStyle(.gray)
                            
                            TextField("", value: $workingHours, format: .number)
                                .keyboardType(.decimalPad)
                                .focused($focus, equals: .workingHours)
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
                .scrollDismissesKeyboard(.immediately)
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
                            save()
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
            }
        }
        .onAppear {
            companyName = jobModel.companyName
            jobTitle = jobModel.jobTitle
            workingHours = jobModel.workingHoursPerWeek
            hourlyRate = jobModel.hourlyRate
            
        }
    }
    
    private func save() {
        jobModel.companyName = companyName
        jobModel.jobTitle = jobTitle
        jobModel.workingHoursPerWeek = workingHours
        jobModel.hourlyRate = hourlyRate
    }
    
    
    private func dismissKeyboard() {
        focus = nil
    }
    
    private func hourlyRateBinding() -> Binding<Double?> {
        Binding<Double?>(
            get: {
                hourlyRate.value > 0 ? hourlyRate.value : nil
            },
            
            set: { newValue in
                hourlyRate.value = newValue ?? 0
            }
        )
    }
    
    private func workingHoursBinding () -> Binding <Int?> {
        Binding<Int?>(
            get: {
                workingHours > 0 ? workingHours : nil
            },
            set: { newValue in
                workingHours = newValue ?? 0
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
