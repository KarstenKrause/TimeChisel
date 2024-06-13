//
//  AddJobView.swift
//  TimeChisel
//
//  Created by Karsten Krause on 04.02.24.
//

import SwiftUI

struct AddJobView: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    
    @Bindable var jobVM = JobViewModel(
        companyName: "",
        jobTitle: "",
        workingHoursPerWeek: 0,
        workingDaysPerWeek: 1,
        pauseMinutesPerDay: 0,
        hourlyRate: HourlyRate(value: 0, currency: .EUR)
    )
    
    @FocusState var isFocused: Bool
    
    var jobs: [JobModel] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section("Jobinfos") {
                    TextField("Name des Unternehmens", text: $jobVM.companyName)
                        .focused($isFocused)
                    TextField("Job-Titel", text: $jobVM.jobTitle)
                        .focused($isFocused)
                    
                    HStack {
                        TextField("Stundenlohn", value: hourlyRateBinding(), format: .number)
                            .keyboardType(.decimalPad)
                            .focused($isFocused)
                        Picker("", selection: $jobVM.hourlyRate.currency) {
                            ForEach(HourlyRate.Currency.allCases, id: \.self) { currency in
                                Text(currency.rawValue).tag(currency)
                            }
                        }
                    }
                }
                
                Section("Arbeitszeiten") {
                    TextField("Stunden pro Woche", value: workingHoursBinding(), format: .number)
                        .keyboardType(.decimalPad)
                        .focused($isFocused)
                    
                    Picker("Tage pro Woche", selection: $jobVM.workingDaysPerWeek) {
                        ForEach(1...6, id: \.self) {
                            Text("\($0) Tage")
                        }
                    }
                    
                    Picker("Pause am Tag", selection: $jobVM.pauseMinutesPerDay) {
                        ForEach(0...4, id: \.self) { index in
                            let minutes = index * 30
                            Text("\(minutes) Minuten")
                        }
                    }
                }
                
                Section {
                    HStack{
                        Button(action: {
                            let job: JobModel = JobModel(companyName: jobVM.companyName, jobTitle: jobVM.jobTitle, workingHoursPerWeek: jobVM.workingHoursPerWeek, workingDaysPerWeek: jobVM.workingDaysPerWeek, pauseMinutesPerDay: jobVM.pauseMinutesPerDay, hourlyRate: jobVM.hourlyRate )
                            
                            context.insert(job)
                            try! context.save()
                            dismiss()
                        }, label: {
                            Text("Speichern")
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                        })
                        .disabled((jobVM.companyName.isEmpty || jobVM.jobTitle.isEmpty))
                    }
                }
                .buttonStyle(.borderless)
            }
            .navigationTitle("Job hinzufügen")
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
                        isFocused = false
                    }
                }
            }
        }
    }
    
    private func hourlyRateBinding() -> Binding<Double?> {
        Binding<Double?>(
            get: {
                jobVM.hourlyRate.value > 0 ? jobVM.hourlyRate.value : nil
            },
            
            set: { newValue in
                jobVM.hourlyRate.value = newValue ?? 0
            }
        )
    }
    
    private func workingHoursBinding () -> Binding <Int?> {
        Binding<Int?>(
            get: {
                jobVM.workingHoursPerWeek > 0 ? jobVM.workingHoursPerWeek : nil
            },
            set: { newValue in
                jobVM.workingHoursPerWeek = newValue ?? 0
            }
        )
    }
}

#Preview {
    AddJobView()
}
