import SwiftUI

struct LabView: View {
    @EnvironmentObject var store: ProgressStore
    @EnvironmentObject var content: ContentLoader

    @State private var selectedA: String?
    @State private var selectedB: String?
    @State private var result: LabOutcome?
    @State private var showResult = false
    @State private var answeredQuestion = false
    @State private var feedback = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("⚠️ Учебная симуляция. Не повторяйте дома.")
                        .font(.caption).foregroundStyle(.orange)

                    workbench

                    Text("Реагент 1").font(.headline)
                    reagentGrid(selected: $selectedA)

                    Text("Реагент 2").font(.headline)
                    reagentGrid(selected: $selectedB)

                    Button {
                        react()
                    } label: {
                        Label("Смешать", systemImage: "flask.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(selectedA == nil || selectedB == nil)
                }
                .padding()
            }
            .navigationTitle("Лаборатория")
            .sheet(isPresented: $showResult) {
                if case .experiment(let e) = result {
                    ExperimentResultView(experiment: e)
                        .environmentObject(store)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "questionmark.circle").font(.largeTitle)
                        Text("Эта реакция не предусмотрена в учебной базе.")
                        Text("Попробуйте другую пару реагентов.").font(.caption)
                        Button("Закрыть") { showResult = false }
                    }.padding()
                }
            }
        }
    }

    private var workbench: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: [.gray.opacity(0.15), .gray.opacity(0.05)],
                                     startPoint: .top, endPoint: .bottom))
            HStack(spacing: 30) {
                beaker(label: selectedA)
                Text("+").font(.title).foregroundStyle(.secondary)
                beaker(label: selectedB)
            }
        }
        .frame(height: 180)
    }

    private func beaker(label: String?) -> some View {
        VStack {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 4).stroke(Color.secondary, lineWidth: 2)
                    .frame(width: 70, height: 100)
                if let l = label {
                    Rectangle().fill(Color.accentColor.opacity(0.3))
                        .frame(width: 66, height: 40)
                }
            }
            Text(label ?? "—").font(.caption)
        }
    }

    private func reagentGrid(selected: Binding<String?>) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
            ForEach(LabService.shared.allReagents) { r in
                Button {
                    selected.wrappedValue = r.id
                } label: {
                    VStack(spacing: 2) {
                        Text(r.symbol).font(.system(.body, design: .monospaced)).bold()
                        Text(r.name).font(.caption2).lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .padding(6)
                    .background(selected.wrappedValue == r.id
                                ? Color.accentColor.opacity(0.25)
                                : Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func react() {
        guard let a = selectedA, let b = selectedB else { return }
        answeredQuestion = false
        feedback = ""
        let outcome = LabService.shared.find(a: a, b: b)
        result = outcome
        showResult = true
        if case .experiment(let e) = outcome {
            store.completeLab(e.id)
        }
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
            VStack(alignment: .leading, spacing: 12) {
                Text(experiment.title).font(.title2).bold()
                Text("Цель").font(.headline); Text(experiment.goal)
                Text("Наблюдение").font(.headline); Text(experiment.observation)
                if let eq = experiment.equation {
                    Text("Уравнение").font(.headline)
                    Text(eq).font(.system(.body, design: .monospaced))
                        .padding(8).background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                Text("Объяснение").font(.headline); Text(experiment.explanation)

                Text("Вопрос").font(.headline)
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
                            .padding(8)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }.buttonStyle(.plain)
                }
                if answered, let s = selected {
                    Text(s == experiment.question.correctIndex
                         ? "✅ " + experiment.question.explanation
                         : "❌ " + experiment.question.explanation)
                        .font(.footnote)
                }

                Button("Закрыть") { dismiss() }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
    }
}
