import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: ProgressStore
    @EnvironmentObject var content: ContentLoader
    @Binding var showAI: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    gradePicker
                    continueButton
                    dailyTask
                    quickLinks
                    aiButton
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("ХимЛаб")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Привет, юный химик! 👋")
                .font(.title2).bold()
            Text("Очки: \(store.data.earnedPoints) · Уроков: \(store.data.completedArticles.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var gradePicker: some View {
        HStack {
            Image(systemName: "graduationcap.fill").foregroundStyle(.teal)
            Picker("Класс", selection: Binding(
                get: { store.data.selectedGrade },
                set: { store.setGrade($0) }
            )) {
                ForEach([8, 9, 10], id: \.self) { g in
                    Text("\(g) класс").tag(g)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(10)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var continueButton: some View {
        NavigationLink {
            LearnView()
        } label: {
            HStack {
                Image(systemName: "play.fill")
                Text("Продолжить обучение").bold()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(LinearGradient(colors: [.teal, .blue], startPoint: .leading, endPoint: .trailing))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
        }
    }

    private var dailyTask: some View {
        Group {
            if let a = content.todayArticle {
                NavigationLink {
                    ArticleView(article: a)
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Задание дня", systemImage: "star.fill")
                            .font(.caption).bold()
                            .foregroundStyle(.orange)
                        Text(a.title).font(.headline).foregroundStyle(.primary)
                        Text(a.summary).font(.subheadline).lineLimit(2)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var quickLinks: some View {
        HStack(spacing: 12) {
            NavigationLink {
                LearnView()
            } label: {
                quickCard(title: "Справочник", icon: "book.closed.fill", color: .green)
            }
            NavigationLink {
                PeriodicTableView()
            } label: {
                quickCard(title: "Таблица", icon: "square.grid.3x3.fill", color: .purple)
            }
        }
        .buttonStyle(.plain)
    }

    private var aiButton: some View {
        Button {
            showAI = true
        } label: {
            HStack {
                Image(systemName: "brain.head.profile")
                Text("Спросить ИИ-помощника")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.purple.opacity(0.15))
            .foregroundStyle(.purple)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private func quickCard(title: String, icon: String, color: Color) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(title)
                .font(.subheadline).bold()
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
