import Foundation

final class ContentLoader: ObservableObject {

    static let shared = ContentLoader()

    @Published private(set) var articles: [Article] = []
    @Published private(set) var balanceTasks: [BalanceTask] = []
    @Published private(set) var formulaTasks: [FormulaTask] = []
    @Published private(set) var detectiveTasks: [DetectiveTask] = []
    @Published private(set) var fixErrorTasks: [FixErrorTask] = []
    @Published private(set) var elements: [ChemElement] = []
    @Published private(set) var labExperiments: [LabExperiment] = []

    private init() { load() }

    private func load<T: Decodable>(_ name: String, _ type: T.Type) -> T? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("❌ Не найден ресурс: \(name).json")
            return nil
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("❌ Ошибка парсинга \(name).json: \(error)")
            return nil
        }
    }

    private func load() {
        articles = load("articles", [Article].self) ?? []
        balanceTasks = load("balance", [BalanceTask].self) ?? []
        formulaTasks = load("formulas", [FormulaTask].self) ?? []
        detectiveTasks = load("detective", [DetectiveTask].self) ?? []
        fixErrorTasks = load("fixerrors", [FixErrorTask].self) ?? []
        elements = load("elements", [ChemElement].self) ?? []
        labExperiments = load("labexperiments", [LabExperiment].self) ?? []
    }

    func article(id: String) -> Article? {
        articles.first { $0.id == id }
    }

    var todayArticle: Article? {
        guard !articles.isEmpty else { return nil }
        let day = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        return articles[day % articles.count]
    }
}
