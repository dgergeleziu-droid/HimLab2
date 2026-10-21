import Foundation

// =====================================================
// ПРОТОКОЛ
// =====================================================
protocol AIService {
    var isMock: Bool { get }
    func send(question: String, grade: Int, articleTitle: String?, taskText: String?) async throws -> String
}

// =====================================================
// MOCK
// =====================================================
final class MockAIService: AIService {
    let isMock = true
    private let content = ContentLoader.shared

    func send(question: String, grade: Int, articleTitle: String?, taskText: String?) async throws -> String {
        try await Task.sleep(nanoseconds: 400_000_000)

        let q = question.lowercased()
        let article = articleTitle.flatMap { content.articles.first { $0.title == $0.title && $0.title == $0.title && $0.title == $0.title && $0.title == $0.title && $0.title == $0.title && $0.title == $0.title && $0.title == $0.title && $0.title == $0.title && $0.title == $0.title && $0.title == $0.title } }

        let articleCard = articleTitle.flatMap { title in
            content.articles.first { $0.title == title }
        }

        // Демо-кнопки
        if q.contains("проще") {
            return "🧪 Демо-режим (не настоящий ИИ).\n\nЕсли объяснять проще: \(articleCard?.summary ?? "выберите карточку и нажмите кнопку «Объясни проще» ещё раз.")\n\nКогда будет подключён сервер — здесь появится настоящий разбор."
        }
        if q.contains("подсказк") {
            let hint = articleCard?.formulas.first ?? "Сначала вспомните определение, затем подставьте числа."
            return "💡 Подсказка (демо): \(hint)"
        }
        if q.contains("пример") {
            return "📘 Разбор примера (демо):\n\n\(articleCard?.example ?? "Откройте карточку и нажмите «Разбери пример».")"
        }
        if q.contains("проверь") {
            return "✏️ Чтобы я проверил ответ, нужен настоящий сервер — пока это демо. Ваш вопрос: «\(question)» сохранён. Позже здесь появится обратная связь."
        }
        return "🤖 Демонстрационный помощник.\n\nЯ не подключён к настоящему ИИ. Свободный диалог станет доступен после подключения сервера (см. настройки RemoteAIService)."
    }
}

// =====================================================
// REMOTE (заготовка)
// =====================================================
final class RemoteAIService: AIService {
    let isMock = false
    private let endpoint: URL

    init(endpoint: URL) {
        self.endpoint = endpoint
    }

    func send(question: String, grade: Int, articleTitle: String?, taskText: String?) async throws -> String {
        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.timeoutInterval = 30

        let body: [String: Any] = [
            "message": question,
            "grade": grade,
            "article_title": articleTitle ?? "",
            "task_text": taskText ?? "",
            "system": Self.systemPrompt
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw NSError(domain: "RemoteAI", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Сервер вернул ошибку"])
        }
        struct Reply: Decodable { let reply: String }
        let decoded = try JSONDecoder().decode(Reply.self, from: data)
        return decoded.reply
    }

    static let systemPrompt = """
    Ты — ИИ-репетитор по химии для школьников. Отвечай на русском языке.
    Учитывай класс (8–10). Сначала помогай понять ход решения, полный разбор — по просьбе.
    Не выдумывай химические факты и результаты опытов, явно говори о неопределённости.
    Различай индексы (в формуле), коэффициенты (перед формулой) и заряды ионов.
    Не предлагай опасные домашние эксперименты.
    """
}
