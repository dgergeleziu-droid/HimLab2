import SwiftUI

struct LearnView: View {
    @EnvironmentObject var store: ProgressStore
    @EnvironmentObject var content: ContentLoader
    @State private var search = ""
    @State private var onlyFavorites = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Только избранное", isOn: $onlyFavorites)
                    Picker("Класс", selection: Binding(
                        get: { store.data.selectedGrade },
                        set: { store.setGrade($0) }
                    )) {
                        ForEach([8, 9, 10], id: \.self) { g in Text("\(g)").tag(g) }
                    }.pickerStyle(.segmented)
                }
                Section(header: Text("Карточки")) {
                    ForEach(filtered) { a in
                        NavigationLink {
                            ArticleView(article: a)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(a.title).font(.headline)
                                    Text(a.summary).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                                }
                                Spacer()
                                if store.data.favorites.contains(a.id) {
                                    Image(systemName: "star.fill").foregroundStyle(.yellow)
                                }
                                if store.data.completedArticles.contains(a.id) {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                                }
                            }
                        }
                    }
                    if filtered.isEmpty {
                        ContentUnavailableView("Ничего не найдено",
                                               systemImage: "magnifyingglass",
                                               description: Text("Измените запрос или класс"))
                    }
                }
            }
            .searchable(text: $search, prompt: "Поиск по названию или ключевым словам")
            .navigationTitle("Справочник")
        }
    }

    private var filtered: [Article] {
        content.articles.filter { a in
            if a.grade != store.data.selectedGrade { return false }
            if onlyFavorites && !store.data.favorites.contains(a.id) { return false }
            if search.isEmpty { return true }
            let s = search.lowercased()
            return a.title.lowercased().contains(s)
                || a.keywords.contains { $0.lowercased().contains(s) }
        }
    }
}
