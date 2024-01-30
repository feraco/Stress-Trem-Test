import SwiftUI

/**
 View for MoodSnap sheet.
 */
struct MoodSnapView: View {
    @Environment(\.dismiss) var dismiss
    @State var moodSnap: MoodSnapStruct
    @EnvironmentObject var data: DataStoreClass
    @EnvironmentObject var health: HealthManager
    @State private var showingDatePickerSheet = false
    @State private var showingTremorTestView = false
    @State private var question1: Double = 2
    @State private var question2: Double = 2
    @State private var question3: Double = 3
    @State private var question4: Double = 4
    @State private var question5: Double = 3
    @State private var question6: Double = 1
    @State private var question7: Double = 3
    @State private var question8: Double = 3
    @State private var question9: Double = 3
    @State private var question10: Double = 3
    private func updateAnxietyScore() {
           let totalScore = question1 + question2 + question3 + (5 - question4) + (5 - question5) + question6 + (5 - question7) + (5 - question8) + question9 + question10
           moodSnap.anxiety = totalScore
       }

    @ViewBuilder
       private func surveyQuestion(_ text: String, value: Binding<Double>, isReversed: Bool = false) -> some View {
           Text(text)
           Slider(value: value, in: 1...5, step: 1)
               .accentColor(isReversed ? .green : .blue)
       }
    var body: some View {
        GroupBox {
            ScrollView {
                Group {
                    HStack {
                        Label(moodSnap.timestamp.dateTimeString(), systemImage: "clock")
                            .font(.caption)

                        Spacer()

                        Button {
                            showingDatePickerSheet.toggle()
                        } label: { Image(systemName: "calendar.badge.clock")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 15, height: 15)
                                .foregroundColor(Color.primary)
                        }.sheet(isPresented: $showingDatePickerSheet) {
                            DatePickerView(moodSnap: $moodSnap, settings: data.settings)
                        }
                    }
                }

                // Mood
                Group {
                    ScrollView {
                        VStack {
                            // Questions
                            surveyQuestion("1. In the last month, how often have you been upset because of something that happened unexpectedly?", value: $question1)                    .onChange(of: question1) { _ in updateAnxietyScore() }

                            surveyQuestion("2. In the last month, how often have you felt that you were unable to control the important things in your life?", value: $question2)
                                .onChange(of: question2) { _ in updateAnxietyScore() }

                            surveyQuestion("3. In the last month, how often have you felt nervous and stressed?", value: $question3)
                                .onChange(of: question3) { _ in updateAnxietyScore() }

                            surveyQuestion("4. In the last month, how often have you felt confident about your ability to handle your personal problems?", value: $question4, isReversed: true)
                                .onChange(of: question4) { _ in updateAnxietyScore() }

                            surveyQuestion("5. In the last month, how often have you felt that things were going your way?", value: $question5, isReversed: true)
                                .onChange(of: question5) { _ in updateAnxietyScore() }

                            surveyQuestion("6. In the last month, how often have you found that you could not cope with all the things that you had to do?", value: $question6)
                                .onChange(of: question6) { _ in updateAnxietyScore() }

                            surveyQuestion("7. In the last month, how often have you been able to control irritations in your life?", value: $question7, isReversed: true)
                                .onChange(of: question7) { _ in updateAnxietyScore() }

                            surveyQuestion("8. In the last month, how often have you felt that you were on top of things?", value: $question8, isReversed: true)
                                .onChange(of: question8) { _ in updateAnxietyScore() }

                            surveyQuestion("9. In the last month, how often have you been angered because of things that happened that were outside of your control?", value: $question9)
                                .onChange(of: question9) { _ in updateAnxietyScore() }

                            surveyQuestion("10. In the last month, how often have you felt difficulties were piling up so high that you could not overcome them?", value: $question10)
                                .onChange(of: question10) { _ in updateAnxietyScore() }

                            
                            // Calculate the total score
                            let totalScore = question1 + question2 + question3 + (5 - question4) + (5 - question5) + question6 + (5 - question7) + (5 - question8) + question9 + question10
                            Text("Total MoodSnap Anxiety Score: \(totalScore, specifier: "%.1f")")
                        }
                    }
                    Divider()
                    VStack(spacing: themes[data.settings.theme].sliderSpacing) {
                        Label("mood", systemImage: "brain.head.profile").font(.caption)
                        Spacer()
                            .frame(height: 20)
                        Text("elevation")
                            .font(Font.caption.bold())
                            .foregroundColor(themes[data.settings.theme].elevationColor)
                        Slider(value: $moodSnap.elevation, in: 0 ... 4, step: 1)
                            .onChange(of: moodSnap.elevation) { _ in
                                hapticResponseLight(data: data)
                            }
                        Text("depression")
                            .font(Font.caption.bold())
                            .foregroundColor(themes[data.settings.theme].depressionColor)
                        Slider(value: $moodSnap.depression, in: 0 ... 4, step: 1)
                            .onChange(of: moodSnap.depression) { _ in
                                hapticResponseLight(data: data)
                            }
                        Text("anxiety")
                            .font(Font.caption.bold())
                            .foregroundColor(themes[data.settings.theme].anxietyColor)
                        Slider(value: $moodSnap.anxiety, in: 0 ... 4, step: 1)
                            .onChange(of: moodSnap.anxiety) { _ in
                                hapticResponseLight(data: data)
                            }
                        Text("irritability")
                            .font(Font.caption.bold())
                            .foregroundColor(themes[data.settings.theme].irritabilityColor)
                        Slider(value: $moodSnap.irritability, in: 0 ... 4, step: 1)
                            .onChange(of: moodSnap.irritability) { _ in
                                hapticResponseLight(data: data)
                            }
                    }
                }

                // Symptoms
                if visibleSymptomsCount(settings: data.settings) > 0 {
                    Group {
                        Button("Start Tremor Test") {
                                          showingTremorTestView.toggle()
                                      }
                                      .buttonStyle(.borderedProminent)
                                      .padding(.vertical)
                                      .sheet(isPresented: $showingTremorTestView) {
                                          TremorTestView()
                                      }
                        Divider()
                        Label("symptoms", systemImage: "heart.text.square").font(.caption)

                        let gridItemLayout = Array(repeating: GridItem(.flexible()), count: data.settings.numberOfGridColumns)

                        LazyVGrid(columns: gridItemLayout, spacing: themes[data.settings.theme].moodSnapGridSpacing) {
                            ForEach(0 ..< symptomList.count, id: \.self) { i in
                                if data.settings.symptomVisibility[i] {
                                    Toggle(.init(symptomList[i]), isOn: $moodSnap.symptoms[i])
                                        .toggleStyle(.button)
                                        .tint(themes[data.settings.theme].buttonColor)
                                        .font(.caption)
                                        .padding(1)
                                        .onChange(of: moodSnap.symptoms[i]) { _ in
                                            hapticResponseLight(data: data)
                                        }
                                }
                            }
                        }
                    }
                }

                // Activities
                if visibleActivitiesCount(settings: data.settings) > 0 {
                    Group {
                        Divider()
                        Label("activity", systemImage: "figure.walk").font(.caption)

                        let gridItemLayout = Array(repeating: GridItem(.flexible()), count: data.settings.numberOfGridColumns)

                        LazyVGrid(columns: gridItemLayout, spacing: themes[data.settings.theme].moodSnapGridSpacing) {
                            ForEach(0 ..< activityList.count, id: \.self) { i in
                                if data.settings.activityVisibility[i] {
                                    Toggle(.init(activityList[i]), isOn: $moodSnap.activities[i])
                                        .toggleStyle(.button)
                                        .tint(themes[data.settings.theme].buttonColor)
                                        .font(.caption)
                                        .onChange(of: moodSnap.activities[i]) { _ in
                                            hapticResponseLight(data: data)
                                        }
                                }
                            }
                        }
                    }
                }

                // Social
                if visibleSocialCount(settings: data.settings) > 0 {
                    Group {
                        Divider()
                        Label("social", systemImage: "person.2").font(.caption)

                        let gridItemLayout = Array(repeating: GridItem(.flexible()), count: data.settings.numberOfGridColumns)

                        LazyVGrid(columns: gridItemLayout, spacing: themes[data.settings.theme].moodSnapGridSpacing) {
                            ForEach(0 ..< socialList.count, id: \.self) { i in
                                if data.settings.socialVisibility[i] {
                                    Toggle(.init(socialList[i]), isOn: $moodSnap.social[i])
                                        .toggleStyle(.button)
                                        .tint(themes[data.settings.theme].buttonColor)
                                        .font(.caption)
                                        .onChange(of: moodSnap.social[i]) { _ in
                                            hapticResponseLight(data: data)
                                        }
                                }
                            }
                        }
                    }
                }

                // Notes
                Group {
                    VStack {
                        Divider()
                        Label("notes", systemImage: "note.text").font(.caption)
                        TextEditor(text: $moodSnap.notes)
                            .font(.caption)
                            .frame(minHeight: 50, alignment: .leading)
                    }
                }

                // Save button
                Button {
                    hapticResponseLight(data: data)
                    DispatchQueue.main.async {
                        withAnimation {
                            data.stopProcessing()
                            health.stopProcessing(data: data)
                            moodSnap.snapType = .mood
                            data.moodSnaps = deleteHistoryItem(moodSnaps: data.moodSnaps, moodSnap: moodSnap)
                            data.moodSnaps.append(moodSnap)
                            data.settings.addedSnaps += 1
                            let quoteSnap = getQuoteSnap(count: data.settings.addedSnaps)
                            if quoteSnap != nil {
                                data.moodSnaps.append(quoteSnap!)
                            }
                            data.startProcessing()
                            health.startProcessing(data: data)
                        }
                    }
                    dismiss()
                } label: { Image(systemName: "arrowtriangle.right.circle")
                    .resizable()
                    .scaledToFill()
                    .foregroundColor(themes[data.settings.theme].buttonColor)
                    .frame(width: themes[data.settings.theme].controlBigIconSize, height: themes[data.settings.theme].controlBigIconSize)
                }
            }
        }
    }
}
