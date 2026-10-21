import SwiftUI

struct PeriodicTableView: View {
    @EnvironmentObject var content: ContentLoader
    @State private var search = ""
    @State private var selected: ChemElement?

    var body: some View {
        NavigationStack {
            ScrollView([.horizontal, .vertical]) {
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(60), spacing: 4), count: 18),
                          spacing: 4) {
                    ForEach(0..<130, id: \.self) { cell in
                        if let el = elementAt(cell) {
                            Button { selected = el } label: {
                                VStack(spacing: 0) {
                                    Text("\(el.number)").font(.system(size: 8))
                                    Text(el.symbol).font(.system(size: 16, weight: .bold))
                                    Text(el.nameRu).font(.system(size: 7)).lineLimit(1)
                                }
                                .frame(width: 58, height: 58)
                                .background(colorFor(el))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                            .buttonStyle(.plain)
                        } else {
                            Color.clear.frame(width: 58, height: 58)
                        }
                    }
                }
                .padding()
            }
            .searchable(text: $search, prompt: "Символ, название или номер")
            .navigationTitle("Периодическая таблица")
            .overlay(alignment: .top) {
                if !search.isEmpty {
                    searchResults
                }
            }
            .sheet(item: $selected) { el in
                ElementDetailView(element: el)
            }
        }
    }

    private var searchResults: some View {
        let s = search.lowercased()
        let found = content.elements.filter {
            $0.symbol.lowercased().contains(s)
            || $0.nameRu.lowercased().contains(s)
            || String($0.number) == s
        }
        return VStack {
            List(found) { el in
                Button {
                    selected = el
                } label: {
                    Text("\(el.number) · \(el.symbol) · \(el.nameRu)")
                }
            }
            .frame(maxHeight: 220)
        }
        .background(.ultraThinMaterial)
    }

    private func elementAt(_ index: Int) -> ChemElement? {
        // Упрощённая визуальная раскладка: периоды — строки по 18 ячеек
        let row = index / 18
        let col = index % 18
        return content.elements.first { el in
            guard let p = el.period, let g = el.group else { return false }
            if p == 1 { return row == 0 && (col == 0 || col == 17) && el.number <= 2 }
            return row == p - 1 && col == g - 1
        }
    }

    private func colorFor(_ el: ChemElement) -> Color {
        switch el.number {
        case 1...2: return .blue.opacity(0.25)
        case 3...10: return .green.opacity(0.25)
        case 11...18: return .orange.opacity(0.25)
        default: return Color.gray.opacity(0.2)
        }
    }
}

struct ElementDetailView: View {
    let element: ChemElement
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                LabeledContent("Номер", value: "\(element.number)")
                LabeledContent("Символ", value: element.symbol)
                LabeledContent("Название", value: element.nameRu)
                if let m = element.atomicMass { LabeledContent("Атомная масса", value: String(format: "%.3f", m)) }
                if let p = element.period { LabeledContent("Период", value: "\(p)") }
                if let g = element.group { LabeledContent("Группа", value: "\(g)") }
                if let d = element.description { Section("Описание") { Text(d) } }
                if let c = element.compounds, !c.isEmpty {
                    Section("Соединения") { ForEach(c, id: \.self) { Text($0) } }
                }
            }
            .navigationTitle(element.nameRu)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Закрыть") { dismiss() }
                }
            }
        }
    }
}
