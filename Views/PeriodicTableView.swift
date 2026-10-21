import SwiftUI

struct PeriodicTableView: View {
    @EnvironmentObject var content: ContentLoader
    @State private var search = ""
    @State private var selected: ChemElement?

    let columns = 18
    let rows = 10 // 7 периодов + 2 ряда лантаноидов/актиноидов + отступ

    var body: some View {
        NavigationStack {
            ScrollView([.horizontal, .vertical]) {
                VStack {
                    if !search.isEmpty {
                        searchResultsList
                    } else {
                        periodicGrid
                    }
                }
                .padding()
            }
            .searchable(text: $search, prompt: "Символ, название или номер")
            .navigationTitle("Периодическая таблица")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selected) { el in
                ElementDetailView(element: el)
            }
        }
    }

    private var periodicGrid: some View {
        LazyHGrid(rows: Array(repeating: GridItem(.fixed(50), spacing: 2), count: rows), spacing: 2) {
            // Генерируем ячейки строго по колонкам
            ForEach(0..<columns, id: \.self) { col in
                ForEach(0..<rows, id: \.self) { row in
                    if let el = findElement(group: col + 1, period: row + 1) {
                        ElementCell(element: el) { selected = el }
                    } else {
                        Color.clear.frame(width: 50, height: 50)
                    }
                }
            }
        }
    }

    private func findElement(group: Int, period: Int) -> ChemElement? {
        // Ищем элемент по группе и периоду из JSON
        content.elements.first { $0.group == group && $0.period == period }
    }

    private var searchResultsList: some View {
        let s = search.lowercased()
        let found = content.elements.filter {
            $0.symbol.lowercased().contains(s) ||
            $0.nameRu.lowercased().contains(s) ||
            String($0.number) == s
        }
        
        return VStack(alignment: .leading) {
            if found.isEmpty {
                Text("Ничего не найдено").foregroundStyle(.secondary)
            } else {
                ForEach(found) { el in
                    Button {
                        selected = el
                    } label: {
                        HStack {
                            Text("\(el.number)").font(.system(.body, design: .monospaced)).foregroundStyle(.secondary)
                            Text(el.symbol).bold()
                            Text(el.nameRu)
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct ElementCell: View {
    let element: ChemElement
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text("\(element.number)").font(.system(size: 8)).foregroundStyle(.secondary)
                Text(element.symbol).font(.system(size: 14, weight: .bold))
                Text(element.nameRu).font(.system(size: 7)).lineLimit(1)
            }
            .frame(width: 50, height: 50)
            .background(colorFor(element.number))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.primary.opacity(0.1), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func colorFor(_ number: Int) -> Color {
        switch number {
        case 1...2: return .blue.opacity(0.2)
        case 3...10: return .green.opacity(0.2)
        case 11...18: return .orange.opacity(0.2)
        case 19...36: return .purple.opacity(0.2)
        case 37...54: return .pink.opacity(0.2)
        default: return Color.gray.opacity(0.15)
        }
    }
}

struct ElementDetailView: View {
    let element: ChemElement
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Основное") {
                    LabeledContent("Номер", value: "\(element.number)")
                    LabeledContent("Символ", value: element.symbol)
                    LabeledContent("Название", value: element.nameRu)
                    if let m = element.atomicMass { LabeledContent("Атомная масса", value: String(format: "%.2f", m)) }
                }
                if let p = element.period, let g = element.group {
                    Section("Положение") {
                        LabeledContent("Период", value: "\(p)")
                        LabeledContent("Группа", value: "\(g)")
                    }
                }
                if let d = element.description, !d.isEmpty {
                    Section("Описание") { Text(d) }
                }
                if let c = element.compounds, !c.isEmpty {
                    Section("Соединения") { ForEach(c, id: \.self) { Text($0) } }
                }
            }
            .navigationTitle(element.nameRu)
            .toolbar {
                Button("Закрыть") { dismiss() }
            }
        }
    }
}
