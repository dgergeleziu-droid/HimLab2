import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: ProgressStore
    @EnvironmentObject var content: ContentLoader
    @Binding var showAI: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    gradePicker
                    continueButton
                    dailyTask
                    quickLinks
                    aiButton
                }
                .padding()
            }
            .navigationTitle("ХимЛаб")
            .background(Color(.systemGroupedBackground))
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Привет, юный химик!")
                .font(.title2).bold()
            Text("Очки: \(store.data.earnedPoints) · Уроков: \(store.data.completedArticles.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var gradePicker: some View {
        HStack {
            Text("Класс").font(.headline)
            Spacer()
            Picker("Класс", selection: Binding(
                get: { store.data.selectedGrade },
                set: { store.setGrade($0) }
            )) {
                ForEach([8, 9, 10], id: \.self) { g in
                    Text("\(g) класс").tag(g)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 260)
        }
    }

    private var continueButton: some View {
        NavigationLink {
            LearnView()
        } label: {
            Label("Продолжить обучение", systemImage: "play.fill")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private var dailyTask: some View {
        Group {
            if let a = content.todayArticle {
                NavigationLink {
                    ArticleView(article: a)
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Задание дня").font(.caption).foregroundStyle(.secondary)
                        Text(a.title).font(.headline)
                        Text(a.summary).font(.subheadline).lineLimit(2)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
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
                quickCard(title: "Справочник", icon: "book")
            }
            NavigationLink {
                PeriodicTableView()
            } label: {
                quickCard(title: "Таблица", icon: "square.grid.3x3")
            }
        }
        .buttonStyle(.plain)
    }

    private var aiButton: some View {
        Button {
            showAI = true
        } label: {
            Label("Спросить ИИ", systemImage: "brain.head.profile")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple.opacity(0.15))
                .foregroundStyle(.purple)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private func quickCard(title: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.title)
            Text(title).font(.subheadline).bold()
        }
        .frame(maxWidth: .infinity, minHeight: 90)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
