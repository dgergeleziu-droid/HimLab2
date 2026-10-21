import SwiftUI

struct ArticleView: View {
    let article: Article
    @EnvironmentObject var store: ProgressStore
    @State private var selectedAnswer: Int?
    @State private var feedback: String?
    @State private var showAI = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(article.title).font(.title2).bold()
                    Spacer()
                    Button {
                        store.toggleFavorite(article.id)
                    } label: {
                        Image(systemName: store.data.favorites.contains(article.id)
                              ? "star.fill" : "star")
                    }
                    .accessibilityLabel("Избранное")
                }

                section(title: "Простое объяснение", body: article.summary)
                if !article.formulas.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Формулы и правила").font(.headline)
                        ForEach(article.formulas, id: \.self) { f in
                            Text(f).font(.system(.body, design: .monospaced))
                                .padding(8)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                section(title: "Разобранный пример", body: article.example)
                section(title: "Типичная ошибка", body: article.commonMistake)

                if let task = article.interactiveTask {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Попробуйте сами").font(.headline)
                        Text(task.prompt)
                        ForEach(task.options.indices, id: \.self) { i in
                            Button {
                                selectedAnswer = i
                                feedback = (i == task.correctIndex)
                                    ? "✅ " + task.explanation
                                    : "❌ Попробуйте ещё раз. " + task.explanation
                                if i == task.correctIndex {
                                    store.recordCorrectAnswer(taskID: article.id + "_task")
                                }
                            } label: {
                                HStack {
                                    Text(task.options[i])
                                    Spacer()
                                    if selectedAnswer == i {
                                        Image(systemName: i == task.correctIndex
                                              ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    }
                                }
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.plain)
                        }
                        if let f = feedback { Text(f).font(.footnote) }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Самопроверка").font(.headline)
                    ForEach(article.checkQuestions) { q in
                        QuizCard(question: q, taskID: article.id + "_q_" + q.prompt)
                    }
                }

                Button {
                    showAI = true
                } label: {
                    Label("Спросить ИИ по этой теме", systemImage: "brain.head.profile")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple.opacity(0.15))
                        .foregroundStyle(.purple)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    store.completeArticle(article.id)
                } label: {
                    Label(store.data.completedArticles.contains(article.id)
                          ? "Изучено" : "Отметить как изученное",
                          systemImage: "checkmark.seal")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.15))
                        .foregroundStyle(.green)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle("Карточка")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAI) {
            AIView(articleTitle: article.title)
                .environmentObject(store)
                .environmentObject(ContentLoader.shared)
        }
    }

    private func section(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.headline)
            Text(body)
        }
    }
}

struct QuizCard: View {
    let question: QuizQuestion
    let taskID: String
    @EnvironmentObject var store: ProgressStore
    @State private var selected: Int?
    @State private var feedback: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(question.prompt).font(.subheadline).bold()
            ForEach(question.options.indices, id: \.self) { i in
                Button {
                    selected = i
                    if i == question.correctIndex {
                        feedback = "✅ " + question.explanation
                        store.recordCorrectAnswer(taskID: taskID)
                    } else {
                        feedback = "❌ Неверно. " + question.explanation
                    }
                } label: {
                    HStack {
                        Text(question.options[i])
                        Spacer()
                        if selected == i {
                            Image(systemName: i == question.correctIndex
                                  ? "checkmark.circle.fill" : "xmark.circle.fill")
                        }
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
            if let f = feedback { Text(f).font(.caption) }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
