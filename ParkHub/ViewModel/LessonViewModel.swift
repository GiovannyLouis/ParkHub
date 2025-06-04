import SwiftUI

class LessonViewModel: ObservableObject {
    @Published var lessons: [Lesson] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    let repository: LessonRepository
    
    init(repository: LessonRepository = LessonRepository()) {
        self.repository = repository
    }
    func fetchAllLessons() {
        isLoading = true
        errorMessage = nil
        
        repository.observeLessons { [weak self] lessons in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.lessons = lessons
                self?.errorMessage = lessons.isEmpty ? "No valid lesson data could be parsed from the available records." : nil
            }
        } onError: { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.errorMessage = "Failed to fetch lessons: \(error.localizedDescription)"
                self?.lessons = []
            }
        }
    }
}
