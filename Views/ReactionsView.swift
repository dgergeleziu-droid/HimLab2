import SwiftUI

struct ReactionsView: View {
    @EnvironmentObject var content: ContentLoader
    @State private var searchText = ""
    @State private var selectedType = "Все"
    @State private var selectedReaction: Reaction?

    var body: some View {
        NavigationStack {
            VStack {
                // Фильтры
                if !content.reactions.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(availableTypes, id: \.self) { type in
                                Button(type) {
                                    selectedType = type
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedType == type ? Color.teal : Color(.secondarySystemGroupedBackground))
                                .foregroundStyle(selectedType == type ? .white : .primary)
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Список
                if content.isLoading && content.reactions.isEmpty {
                    ProgressView("Загрузка каталога...")
                        .frame(maxHeight: .infinity)
                } else if filteredReactions.isEmpty {
                    ContentUnavailableView(
                        "Ничего не найдено",
                        systemImage: "magnifyingglass",
                        description: Text("Измените поисковый запрос или фильтр.")
                    )
                } else {
                    List(filteredReactions) { reaction in
                        Button {
                            selectedReaction = reaction
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(reaction.title).font(.headline)
                                    Spacer()
                                    Text(reaction.level)
                                        .font(.caption2).bold()
                                        .padding(.horizontal, 6).padding(.vertical, 2)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundStyle(.blue)
                                        .clipShape(Capsule())
                                }
                                Text(reaction.equation)
                                    .font(.system(.subheadline, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                Text(reaction.type).font(.caption).foregroundStyle(.orange)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Каталог реакций")
            .searchable(text: $searchText, prompt: "Название или формула")
            .sheet(item: $selectedReaction) { reaction in
                ReactionDetailView(reaction: reaction)
            }
        }
    }

    private var availableTypes: [String] {
        let types = Set(content.reactions.map { $0.type }).sorted()
        return ["Все"] + types
    }

    private var filteredReactions: [Reaction] {
        content.reactions.filter { reaction in
            let matchesType = selectedType == "Все" || reaction.type == selectedType
            let normalizedSearch = normalize(searchText)
            let matchesSearch = searchText.isEmpty ||
                normalize(reaction.title).contains(normalizedSearch) ||
                normalize(reaction.equation).contains(normalizedSearch)
            return matchesType && matchesSearch
        }
    }

    // Приведение нижних индексов (₂) к обычным цифрам (2) для удобного поиска
    private func normalize(_ text: String) -> String {
        let map: [Character: Character] = [
            "₀":"0", "₁":"1", "₂":"2", "₃":"3", "₄":"4",
            "₅":"5", "₆":"6", "₇":"7", "₈":"8", "₉":"9"
        ]
        let normalized = text.map { map[$0] ?? $0 }
        return String(normalized).lowercased()
    }
}

struct ReactionDetailView: View {
    let reaction: Reaction
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(reaction.title).font(.title2).bold()
                    Text(reaction.equation)
                        .font(.system(.title3, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    Group {
                        Text("Тип реакции").font(.headline).foregroundStyle(.teal)
                        Text(reaction.type)
                        
                        Text("Условия").font(.headline).foregroundStyle(.teal)
                        Text(reaction.conditions.isEmpty ? "Обычные условия" : reaction.conditions)
                        
                        Text("Наблюдение").font(.headline).foregroundStyle(.teal)
                        Text(reaction.observation)
                        
                        Text("Объяснение").font(.headline).foregroundStyle(.teal)
                        Text(reaction.explanation)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Закрыть") { dismiss() }
            }
        }
    }
}
