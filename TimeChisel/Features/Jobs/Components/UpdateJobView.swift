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
    let pauseSelection: [Int] = [15, 30, 45, 60]
    let daysSelection: [Int] = [1, 2, 3, 4, 5, 6]
    
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
                                    ForEach(Money.Currency.allCases, id: \.self) { currency in
                                        Text(currency.rawValue).tag(currency)
                                    }
                                }
                            }
                        }
                    }
                    
                    Section("Arbeitszeiten") {
                        Picker("Arbeitsmodell", selection: $jobVM.scheduleType) {
                            ForEach(WorkScheduleType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type)
                            }
                        }

                        if jobVM.scheduleType == .flexible {
                            VStack(alignment: .leading) {
                                Text("Stunden pro Woche").foregroundStyle(.gray)

                                TextField("", value: $jobVM.workingHoursPerWeek, format: .number)
                                    .keyboardType(.decimalPad)
                                    .focused($focus, equals: .workingHours)
                            }

                            #warning("App is crashing, if daySelection > 1")
                            Picker("Tage pro Woche", selection: $jobVM.workingDaysPerWeek) {
                                ForEach(daysSelection, id: \.self) { days in
                                    Text("\(days) Tage").tag(days)
                                }
                            }

                            Picker("Pause am Tag", selection: $jobVM.pauseMinutesPerDay) {
                                ForEach(pauseSelection, id: \.self) { minutes in
                                    Text("\(minutes) Minuten").tag(minutes)
                                }
                            }
                        } else {
                            WeekScheduleEditor(weekSchedule: $jobVM.weekSchedule)
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
            jobVM.companyName = jobModel.companyName
            jobVM.jobTitle = jobModel.jobTitle
            jobVM.scheduleType = jobModel.scheduleType
            jobVM.workingHoursPerWeek = jobModel.workingHoursPerWeek
            jobVM.hourlyRate = jobModel.hourlyRate
            jobVM.pauseMinutesPerDay = jobModel.pauseMinutesPerDay
            jobVM.workingDaysPerWeek = jobModel.workingDaysPerWeek
            jobVM.workingHoursPerDay = jobModel.workingHoursPerDay
            jobVM.weekSchedule = jobModel.weekSchedule
        }
        .focusStateSync($jobVM.focus, with: _focus)
    }
    
    private func save() {
        jobModel.companyName = jobVM.companyName
        jobModel.jobTitle = jobVM.jobTitle
        jobModel.scheduleType = jobVM.scheduleType
        jobModel.workingHoursPerWeek = jobVM.workingHoursPerWeek
        jobModel.hourlyRate = jobVM.hourlyRate
        jobModel.pauseMinutesPerDay = jobVM.pauseMinutesPerDay
        jobModel.workingDaysPerWeek = jobVM.workingDaysPerWeek
        jobModel.weekSchedule = jobVM.scheduleType == .fixed ? jobVM.weekSchedule : []
    }
}
