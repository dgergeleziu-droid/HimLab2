import SwiftUI

struct GamesView: View {
    @EnvironmentObject var store: ProgressStore
    @EnvironmentObject var content: ContentLoader

    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Балансировщик") { BalanceGameView() }
                NavigationLink("Собери формулу") { FormulaGameView() }
                NavigationLink("Химический детектив") { DetectiveGameView() }
                NavigationLink("Исправь ошибку") { FixErrorGameView() }
            }
            .navigationTitle("Игры")
        }
    }
}

// MARK: - Балансировщик
struct BalanceGameView: View {
    @EnvironmentObject var store: ProgressStore
    @EnvironmentObject var content: ContentLoader

    @State private var index = 0
    @State private var leftCoeffs: [Int] = []
    @State private var rightCoeffs: [Int] = []
    @State private var feedback = ""

    var task: BalanceTask? {
        content.balanceTasks.isEmpty ? nil : content.balanceTasks[index % content.balanceTasks.count]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let t = task {
                    Text("Уравнение \(index + 1) из \(content.balanceTasks.count)").font(.caption)
                    Text("\(t.equationLeft) → \(t.equationRight)").font(.headline)
                    coefficientRow(title: "Слева", atoms: t.leftAtoms, coeffs: $leftCoeffs)
                    coefficientRow(title: "Справа", atoms: t.rightAtoms, coeffs: $rightCoeffs)
                    atomCounter(t: t)
                    Button {
                        check(t: t)
                    } label: {
                        Text("Проверить").frame(maxWidth: .infinity).padding()
                            .background(Color.accentColor).foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    if !feedback.isEmpty { Text(feedback).font(.footnote) }
                    Button("Следующее уравнение") {
                        index += 1; feedback = ""
                        initCoeffs()
                    }
                } else {
                    Text("Задания не загружены.")
                }
            }
            .padding()
        }
        .onAppear { initCoeffs() }
        .navigationTitle("Балансировщик")
    }

    private func initCoeffs() {
        guard let t = task else { return }
        leftCoeffs = Array(repeating: 1, count: t.leftAtoms.count)
        rightCoeffs = Array(repeating: 1, count: t.rightAtoms.count)
    }

    private func coefficientRow(title: String, atoms: [[String: Int]],
                                coeffs: Binding<[Int]>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.subheadline)
            ForEach(atoms.indices, id: \.self) { i in
                HStack {
                    Text("Вещество \(i+1)").font(.caption)
                    Spacer()
                    Button("−") { coeffs.wrappedValue[i] = max(1, coeffs.wrappedValue[i] - 1) }
                    Text("\(coeffs.wrappedValue[i])").font(.system(.body, design: .monospaced))
                        .frame(width: 24)
                    Button("+") { coeffs.wrappedValue[i] += 1 }
                }
            }
        }
    }

    private func atomCounter(t: BalanceTask) -> some View {
        let left = ChemistryParser.totalAtoms(atoms: t.leftAtoms, coeffs: leftCoeffs)
        let right = ChemistryParser.totalAtoms(atoms: t.rightAtoms, coeffs: rightCoeffs)
        let allEl = Set(left.keys).union(right.keys).sorted()
        return VStack(alignment: .leading, spacing: 2) {
            Text("Атомы").font(.subheadline)
            ForEach(allEl, id: \.self) { el in
                Text("\(el): \(left[el] ?? 0) → \(right[el] ?? 0)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle((left[el] ?? 0) == (right[el] ?? 0) ? .green : .orange)
            }
        }
    }

    private func check(t: BalanceTask) {
        let all = leftCoeffs + rightCoeffs
        let target = t.correctCoefficients
        if all == target {
            feedback = "✅ Верно! \(t.explanation)"
            store.completeGame("balance")
            store.recordCorrectAnswer(taskID: "balance_\(t.id)")
        } else if all.map({ $0 * 2 }) == target || target.map({ $0 * 2 }) == all {
            feedback = "Почти! Вы использовали кратные коэффициенты. Сократите их на 2."
        } else if ChemistryParser.isBalanced(
            left: ChemistryParser.totalAtoms(atoms: t.leftAtoms, coeffs: leftCoeffs),
            right: ChemistryParser.totalAtoms(atoms: t.rightAtoms, coeffs: rightCoeffs))
        {
            feedback = "Атомы уравнены, но коэффициенты не минимальны. Проверьте: \(t.explanation)"
        } else {
            feedback = "Атомы не уравнены. Индексы в формулах менять нельзя — только коэффициенты."
        }
    }
}

// MARK: - Собери формулу
struct FormulaGameView: View {
    @EnvironmentObject var store: ProgressStore
    @EnvironmentObject var content: ContentLoader

    @State private var index = 0
    @State private var built: [String] = []
    @State private var feedback = ""

    var task: FormulaTask? {
        content.formulaTasks.isEmpty ? nil : content.formulaTasks[index % content.formulaTasks.count]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let t = task {
                    Text("Задание \(index + 1) из \(content.formulaTasks.count)").font(.caption)
                    Text("Соберите формулу: \(t.targetName)").font(.headline)
                    Text("Текущая формула:").font(.subheadline)
                    Text(built.isEmpty ? "—" : built.joined())
                        .font(.system(.title2, design: .monospaced))
                    HStack {
                        ForEach(t.availableTokens, id: \.self) { token in
                            Button(token) { built.append(token) }
                                .padding(8)
                                .background(Color.accentColor.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    HStack {
                        Button("Сброс") { built = [] }
                        Button("Проверить") {
                            if built.joined() == t.correctAnswer
                                || built.joined() == t.correctAnswer.replacingOccurrences(of: "1", with: "")
                            {
                                feedback = "✅ " + t.explanation
                                store.recordCorrectAnswer(taskID: "formula_\(t.id)")
                                store.completeGame("formula")
                            } else {
                                feedback = "❌ Неверно. " + t.explanation
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    if !feedback.isEmpty { Text(feedback).font(.footnote) }
                    Button("Следующее") {
                        index += 1; built = []; feedback = ""
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Собери формулу")
    }
}

// MARK: - Детектив
struct DetectiveGameView: View {
    @EnvironmentObject var store: ProgressStore
    @EnvironmentObject var content: ContentLoader

    @State private var index = 0
    @State private var feedback = ""

    var task: DetectiveTask? {
        content.detectiveTasks.isEmpty ? nil : content.detectiveTasks[index % content.detectiveTasks.count]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let t = task {
                    Text("Дело \(index + 1) из \(content.detectiveTasks.count)").font(.caption)
                    ForEach(t.clues, id: \.self) { c in
                        Label(c, systemImage: "magnifyingglass")
                    }
                    ForEach(t.options.indices, id: \.self) { i in
                        Button {
                            feedback = (i == t.correctIndex)
                                ? "✅ " + t.explanation
                                : "❌ " + t.explanation
                            if i == t.correctIndex {
                                store.recordCorrectAnswer(taskID: "detective_\(t.id)")
                                store.completeGame("detective")
                            }
                        } label: {
                            Text(t.options[i])
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(10)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }.buttonStyle(.plain)
                    }
                    if !feedback.isEmpty { Text(feedback).font(.footnote) }
                    Button("Следующее дело") { index += 1; feedback = "" }
                }
            }
            .padding()
        }
        .navigationTitle("Детектив")
    }
}

// MARK: - Исправь ошибку
struct FixErrorGameView: View {
    @EnvironmentObject var store: ProgressStore
    @EnvironmentObject var content: ContentLoader

    @State private var index = 0
    @State private var feedback = ""

    var task: FixErrorTask? {
        content.fixErrorTasks.isEmpty ? nil : content.fixErrorTasks[index % content.fixErrorTasks.count]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let t = task {
                    Text("№ \(index + 1) из \(content.fixErrorTasks.count)").font(.caption)
                    Text(t.statement)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    Text("Выберите исправление:").font(.headline)
                    ForEach(t.options.indices, id: \.self) { i in
                        Button {
                            feedback = (i == t.correctIndex)
                                ? "✅ " + t.explanation
                                : "❌ " + t.explanation
                            if i == t.correctIndex {
                                store.recordCorrectAnswer(taskID: "fix_\(t.id)")
                                store.completeGame("fix")
                            }
                        } label: {
                            Text(t.options[i])
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(10)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }.buttonStyle(.plain)
                    }
                    if !feedback.isEmpty { Text(feedback).font(.footnote) }
                    Button("Следующее") { index += 1; feedback = "" }
                }
            }
            .padding()
        }
        .navigationTitle("Исправь ошибку")
    }
}
