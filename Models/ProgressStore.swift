import Foundation

struct ProgressData: Codable {
    var selectedGrade: Int = 8
    var completedArticles: Set<String> = []
    var favorites: Set<String> = []
    var earnedPoints: Int = 0
    var correctAnswersTotal: Int = 0
    var completedTaskIDs: Set<String> = []
    var completedGames: Set<String> = []
    var completedLabExperiments: Set<String> = []
    var achievements: Set<String> = []
}

final class ProgressStore: ObservableObject {

    static let shared = ProgressStore()

    @Published private(set) var data: ProgressData {
        didSet { save() }
    }

    private let fileURL: URL

    private init() {
        let fm = FileManager.default
        let dir = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fm.temporaryDirectory
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("himlab_progress.json")

        if let raw = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode(ProgressData.self, from: raw) {
            data = decoded
        } else {
            data = ProgressData()
        }
    }

    private func save() {
        guard let raw = try? JSONEncoder().encode(data) else { return }
        try? raw.write(to: fileURL, options: .atomic)
    }

    // MARK: - Действия

    func setGrade(_ grade: Int) {
        data.selectedGrade = grade
    }

    func completeArticle(_ id: String) {
        if !data.completedArticles.contains(id) {
            data.completedArticles.insert(id)
            data.earnedPoints += 5
            checkAchievements()
        }
    }

    func toggleFavorite(_ id: String) {
        if data.favorites.contains(id) { data.favorites.remove(id) }
        else { data.favorites.insert(id) }
    }

    func recordCorrectAnswer(taskID: String) {
        data.correctAnswersTotal += 1
        if !data.completedTaskIDs.contains(taskID) {
            data.completedTaskIDs.insert(taskID)
            data.earnedPoints += 2
        }
        checkAchievements()
    }

    func completeGame(_ gameID: String) {
        if !data.completedGames.contains(gameID) {
            data.completedGames.insert(gameID)
            data.earnedPoints += 10
            checkAchievements()
        }
    }

    func completeLab(_ id: String) {
        if !data.completedLabExperiments.contains(id) {
            data.completedLabExperiments.insert(id)
            data.earnedPoints += 5
            checkAchievements()
        }
    }

    func reset() {
        data = ProgressData()
    }

    private func checkAchievements() {
        if !data.completedArticles.isEmpty {
            data.achievements.insert("first_lesson")
        }
        if data.correctAnswersTotal >= 5 {
            data.achievements.insert("five_correct")
        }
        if data.completedGames.contains("balance") {
            data.achievements.insert("first_equation")
        }
        if !data.completedLabExperiments.isEmpty {
            data.achievements.insert("first_lab")
        }
    }

    func achievementTitle(_ id: String) -> String? {
        switch id {
        case "first_lesson": return "Первый урок"
        case "five_correct": return "5 правильных ответов"
        case "first_equation": return "Первое уравнение"
        case "first_lab": return "Первый виртуальный опыт"
        default: return nil
        }
    }
}
