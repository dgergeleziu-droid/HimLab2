import Foundation

// MARK: - Справочник

struct Article: Identifiable, Codable, Hashable {
    let id: String
    let grade: Int
    let title: String
    let keywords: [String]
    let summary: String          // простое объяснение
    let formulas: [String]       // формулы/правила
    let example: String          // разобранный пример
    let commonMistake: String    // типичная ошибка
    let interactiveTask: InteractiveTask?
    let checkQuestions: [QuizQuestion]
}

struct InteractiveTask: Codable, Hashable {
    let prompt: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
}

struct QuizQuestion: Codable, Hashable, Identifiable {
    var id: String { prompt }
    let prompt: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
}

// MARK: - Игры

struct BalanceTask: Identifiable, Codable, Hashable {
    let id: String
    let equationLeft: String
    let equationRight: String
    let leftAtoms: [[String: Int]]   // состав каждого вещества слева
    let rightAtoms: [[String: Int]]
    let correctCoefficients: [Int]   // для левой и правой частей
    let explanation: String
}

struct FormulaTask: Identifiable, Codable, Hashable {
    let id: String
    let targetName: String
    let availableTokens: [String]   // например ["H", "O", "2"]
    let correctAnswer: String        // например "H2O"
    let explanation: String
}

struct DetectiveTask: Identifiable, Codable, Hashable {
    let id: String
    let clues: [String]
    let options: [String]
    let correctIndex: Int
    let explanation: String
}

struct FixErrorTask: Identifiable, Codable, Hashable {
    let id: String
    let statement: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
}

// MARK: - Химический элемент

struct ChemElement: Identifiable, Codable, Hashable {
    var id: Int { number }
    let number: Int
    let symbol: String
    let nameRu: String
    let atomicMass: Double?
    let period: Int?
    let group: Int?
    let description: String?
    let compounds: [String]?
}

// MARK: - Лаборатория

struct LabReagent: Identifiable, Hashable {
    let id: String
    let name: String
    let symbol: String
    let color: String  // "clear", "blue", "yellow", "red", "green", "white"
}

struct LabExperiment: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let reagentA: String
    let reagentB: String
    let goal: String
    let observation: String
    let equation: String?
    let explanation: String
    let question: QuizQuestion
    let visualType: String // "colorChange", "precipitate", "gas", "dissolve"
}

// MARK: - Задание (универсальное)

enum TaskResult {
    case correct(String)      // explanation
    case incorrect(String)    // hint/explanation
}

// MARK: - ИИ

struct AIMessage: Identifiable, Hashable {
    let id = UUID()
    let role: Role
    let text: String
    enum Role { case user, assistant, system }
}
