import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: ProgressStore
    @State private var showReset = false

    var body: some View {
        NavigationStack {
            List {
                Section("Статистика") {
                    LabeledContent("Класс", value: "\(store.data.selectedGrade)")
                    LabeledContent("Очки", value: "\(store.data.earnedPoints)")
                    LabeledContent("Правильных ответов", value: "\(store.data.correctAnswersTotal)")
                    LabeledContent("Изучено карточек", value: "\(store.data.completedArticles.count)")
                }
                Section("Достижения") {
                    let list = ["first_lesson", "five_correct", "first_equation", "first_lab"]
                    ForEach(list, id: \.self) { id in
                        HStack {
                            Image(systemName: store.data.achievements.contains(id)
                                  ? "checkmark.seal.fill" : "circle")
                                .foregroundStyle(store.data.achievements.contains(id) ? .green : .gray)
                            Text(store.achievementTitle(id) ?? id)
                        }
                    }
                }
                Section {
                    Button(role: .destructive) {
                        showReset = true
                    } label: {
                        Text("Сбросить прогресс")
                    }
                }
            }
            .navigationTitle("Профиль")
            .confirmationDialog("Удалить весь прогресс?", isPresented: $showReset, titleVisibility: .visible) {
                Button("Удалить", role: .destructive) { store.reset() }
                Button("Отмена", role: .cancel) {}
            }
        }
    }
}
