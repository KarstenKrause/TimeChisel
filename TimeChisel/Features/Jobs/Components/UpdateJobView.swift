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
    @Bindable var jobVM = JobViewModel()
    @FocusState var focus: FocusableField?
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section("Jobinfos") {
                        VStack(alignment: .leading) {
                            jobVM.companyName.isEmpty ? nil :
                            Text("Name des unternehmens")
                                .foregroundStyle(.gray)
                                
                            TextField("Name des Unternehmens", text: $jobVM.companyName)
                                .focused($focus, equals: .company)
                        }
                        
                        VStack(alignment: .leading) {
                            jobVM.jobTitle.isEmpty ? nil :
                            Text("Job-Titel").foregroundStyle(.gray)
                            
                            TextField("Job-Titel", text: $jobVM.jobTitle)
                                .focused($focus, equals: .jobTitle)
                        }
                        
                        VStack(alignment: .leading) {
                            if String(jobVM.hourlyRate.value).isEmpty == false {
                                Text("Stundenlohn").foregroundStyle(.gray)
                            }
                            
                            HStack {
                                TextField("", value: $jobVM.hourlyRate.value, format: .number)
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
                            
                            TextField("", value: $jobVM.workingHoursPerWeek, format: .number)
                                .keyboardType(.decimalPad)
                                .focused($focus, equals: .workingHours)
                        }

                        Picker("Tage pro Woche", selection: $jobVM.workingDaysPerWeek) {
                            ForEach(1...6, id: \.self) { days in
                                Text("\(days) Tage").tag(days)
                            }
                        }
                        
                        Picker("Pause am Tag", selection: $jobVM.pauseMinutesPerDay) {
                            ForEach(0...3, id: \.self) { index in
                                let minutes = (index + 1) * 15
                                Text("\(minutes) Minuten").tag(index)
                            }
                        }
                    }
                    
                    Section {
                        HStack{
                            Button(action: {
                                save()
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
                            jobVM.previous()
                        } label: {
                            Image(systemName: "chevron.up")
                        }
                        
                        Button {
                            jobVM.next()
                        } label: {
                            Image(systemName: "chevron.down")
                        }
                        
                        Spacer()
                        
                        Button("Fertig") {
                            jobVM.dismissKeyboard()
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
            print("onAppear fired")
            jobVM.companyName = jobModel.companyName
            jobVM.jobTitle = jobModel.jobTitle
            jobVM.workingHoursPerWeek = jobModel.workingHoursPerWeek
            jobVM.hourlyRate = jobModel.hourlyRate
            jobVM.pauseMinutesPerDay = jobModel.pauseMinutesPerDay
            jobVM.workingDaysPerWeek = jobModel.workingDaysPerWeek
        }
        .focusStateSync($jobVM.focus, with: _focus)
    }
    
    private func save() {
        
        print("Pause pro Tag ausgewählt: \(jobVM.pauseMinutesPerDay)")
        print("Arbeitstage pro Woche ausgewählt: \(jobVM.pauseMinutesPerDay)")
        jobModel.companyName = jobVM.companyName
        jobModel.jobTitle = jobVM.jobTitle
        jobModel.workingHoursPerWeek = jobVM.workingHoursPerWeek
        jobModel.hourlyRate = jobVM.hourlyRate
        jobModel.pauseMinutesPerDay = jobVM.pauseMinutesPerDay
        jobModel.workingDaysPerWeek = jobVM.workingDaysPerWeek
    }
}
