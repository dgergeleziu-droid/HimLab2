import SwiftUI

struct LabView: View {
    @EnvironmentObject var store: ProgressStore
    @State private var selectedA: String?
    @State private var selectedB: String?
    @State private var result: LabOutcome?
    @State private var showResult = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Лабораторный стол
                ZStack {
                    Color(.systemGroupedBackground).ignoresSafeArea()
                    
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(colors: [.gray.opacity(0.2), .gray.opacity(0.05)], startPoint: .top, endPoint: .bottom))
                        .frame(height: 200)
                        .padding()
                        .overlay {
                            HStack(spacing: 40) {
                                BeakerView(reagentID: selectedA)
                                Image(systemName: "plus").font(.title).foregroundStyle(.secondary)
                                BeakerView(reagentID: selectedB)
                            }
                        }
                }
                .frame(height: 220)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("⚠️ Это учебная симуляция. Не повторяйте опыты дома.")
                            .font(.caption).foregroundStyle(.orange).padding(.horizontal)

                        Text("Реагент 1").font(.headline).padding(.horizontal)
                        reagentGrid(selected: $selectedA)

                        Text("Реагент 2").font(.headline).padding(.horizontal)
                        reagentGrid(selected: $selectedB)

                        Button {
                            react()
                        } label: {
                            Label("Смешать", systemImage: "flask.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.teal)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .padding()
                        .disabled(selectedA == nil || selectedB == nil)
                        .opacity((selectedA == nil || selectedB == nil) ? 0.5 : 1)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Лаборатория")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showResult) {
                if case .experiment(let e) = result {
                    ExperimentResultView(experiment: e).environmentObject(store)
                } else {
                    UnsupportedReactionView()
                }
            }
        }
    }

    private func reagentGrid(selected: Binding<String?>) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(LabService.shared.allReagents) { r in
                    Button {
                        selected.wrappedValue = r.id
                    } label: {
                        VStack(spacing: 4) {
                            Text(r.symbol).font(.system(.body, design: .monospaced)).bold()
                            Text(r.name).font(.caption2).lineLimit(1)
                        }
                        .frame(width: 80, height: 60)
                        .background(selected.wrappedValue == r.id ? Color.teal.opacity(0.2) : Color(.secondarySystemGroupedBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selected.wrappedValue == r.id ? Color.teal : Color.clear, lineWidth: 2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }

    private func react() {
        guard let a = selectedA, let b = selectedB else { return }
        let outcome = LabService.shared.find(a: a, b: b)
        result = outcome
        showResult = true
        if case .experiment(let e) = outcome {
            store.completeLab(e.id)
        }
    }
}

struct BeakerView: View {
    let reagentID: String?
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                // Колба
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary, lineWidth: 3)
                    .frame(width: 80, height: 120)
                
                // Жидкость
                if let id = reagentID {
                    Rectangle()
                        .fill(colorFor(id))
                        .frame(width: 74, height: 60)
                        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 6, bottomTrailingRadius: 6))
                }
            }
            Text(reagentID ?? "—").font(.caption).bold()
        }
    }
    
    private func colorFor(_ id: String) -> Color {
        switch LabService.color(for: id) {
        case "blue": return .blue.opacity(0.6)
        case "gray": return .gray.opacity(0.6)
        default: return .teal.opacity(0.3)
        }
    }
}

struct UnsupportedReactionView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill").font(.largeTitle).foregroundStyle(.orange)
            Text("Реакция не предусмотрена").font(.headline)
            Text("В учебной базе нет данных о взаимодействии этих веществ. Попробуйте другие реагенты.").multilineTextAlignment(.center).padding()
            Button("Закрыть") { dismiss() }.buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct ExperimentResultView: View {
    let experiment: LabExperiment
    @EnvironmentObject var store: ProgressStore
    @Environment(\.dismiss) private var dismiss
    @State private var selected: Int?
    @State private var answered = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(experiment.title).font(.title2).bold()
                
                Group {
                    Text("Цель").font(.headline).foregroundStyle(.teal); Text(experiment.goal)
                    Text("Наблюдение").font(.headline).foregroundStyle(.teal); Text(experiment.observation)
                }
                
                if let eq = experiment.equation {
                    Text("Уравнение").font(.headline).foregroundStyle(.teal)
                    Text(eq).font(.system(.body, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                Text("Объяснение").font(.headline).foregroundStyle(.teal); Text(experiment.explanation)

                Divider()

                Text("Проверь себя").font(.headline)
                Text(experiment.question.prompt)
                
                ForEach(experiment.question.options.indices, id: \.self) { i in
                    Button {
                        selected = i
                        answered = true
                        if i == experiment.question.correctIndex {
                            store.recordCorrectAnswer(taskID: experiment.id + "_q")
                        }
                    } label: {
                        Text(experiment.question.options[i])
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }.buttonStyle(.plain)
                }
                
                if answered, let s = selected {
                    Text(s == experiment.question.correctIndex ? "✅ " + experiment.question.explanation : "❌ " + experiment.question.explanation)
                        .padding()
                        .background(s == experiment.question.correctIndex ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding()
        }
    }
}
