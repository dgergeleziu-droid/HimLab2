import Foundation
import Combine

final class ContentLoader: ObservableObject {
    static let shared = ContentLoader()

    // Данные из Bundle (работают офлайн)
    @Published private(set) var articles: [Article] = []
    @Published private(set) var balanceTasks: [BalanceTask] = []
    @Published private(set) var formulaTasks: [FormulaTask] = []
    @Published private(set) var detectiveTasks: [DetectiveTask] = []
    @Published private(set) var fixErrorTasks: [FixErrorTask] = []
    @Published private(set) var elements: [ChemElement] = []
    @Published private(set) var labExperiments: [LabExperiment] = []
    @Published private(set) var reactions: [Reaction] = []

    // Состояние сети
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?

    private let apiBase = "https://interactive-chemistry-site-b274c4.netlify.app/api/v1"

    private init() {
        loadFromBundle()
    }

    // Загрузка из Bundle (базовая)
    private func loadFromBundle() {
        articles = load("articles", [Article].self) ?? []
        balanceTasks = load("balance", [BalanceTask].self) ?? []
        formulaTasks = load("formulas", [FormulaTask].self) ?? []
        detectiveTasks = load("detective", [DetectiveTask].self) ?? []
        fixErrorTasks = load("fixerrors", [FixErrorTask].self) ?? []
        elements = load("elements", [ChemElement].self) ?? []
        labExperiments = load("labexperiments", [LabExperiment].self) ?? []
        // reactions.json пока нет в Bundle, но если добавите - он подхватится
        reactions = load("reactions", [Reaction].self) ?? []
    }

    private func load<T: Decodable>(_ name: String, _ type: T.Type) -> T? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    // Загрузка с сайта (API)
    func refreshFromNetwork() async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }

        do {
            // Параллельная загрузка всех коллекций
            async let fetchedArticles: [Article] = fetch(endpoint: "/articles")
            async let fetchedElements: [ChemElement] = fetch(endpoint: "/elements")
            async let fetchedBalance: [BalanceTask] = fetch(endpoint: "/balance")
            async let fetchedFormulas: [FormulaTask] = fetch(endpoint: "/formulas")
            async let fetchedDetective: [DetectiveTask] = fetch(endpoint: "/detective")
            async let fetchedFixErrors: [FixErrorTask] = fetch(endpoint: "/fixerrors")
            async let fetchedLab: [LabExperiment] = fetch(endpoint: "/labexperiments")
            async let fetchedReactions: [Reaction] = fetch(endpoint: "/reactions")

            // Ждем завершения всех запросов
            let (a, e, b, f, d, fx, l, r) = try await (fetchedArticles, fetchedElements, fetchedBalance, fetchedFormulas, fetchedDetective, fetchedFixErrors, fetchedLab, fetchedReactions)

            // Обновляем UI только если ВСЕ запросы прошли успешно
            await MainActor.run {
                self.articles = a
                self.elements = e
                self.balanceTasks = b
                self.formulaTasks = f
                self.detectiveTasks = d
                self.fixErrorTasks = fx
                self.labExperiments = l
                self.reactions = r
                self.isLoading = false
                self.lastUpdated = Date()
            }
        } catch {
            // При ошибке оставляем старые данные, показываем сообщение
            await MainActor.run {
                self.errorMessage = "Не удалось обновить материалы. Используются локальные данные."
                self.isLoading = false
            }
        }
    }

    private func fetch<T: Decodable>(endpoint: String) async throws -> T {
        guard let url = URL(string: "\(apiBase)\(endpoint)") else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(http.statusCode) else {
            if http.statusCode == 503 {
                throw NSError(domain: "API", code: 503, userInfo: [NSLocalizedDescriptionKey: "Сервер временно недоступен"])
            } else {
                throw NSError(domain: "API", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "Ошибка сервера: \(http.statusCode)"])
            }
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }

    func article(id: String) -> Article? { articles.first { $0.id == id } }
    var todayArticle: Article? {
        guard !articles.isEmpty else { return nil }
        let day = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        return articles[day % articles.count]
    }
}
