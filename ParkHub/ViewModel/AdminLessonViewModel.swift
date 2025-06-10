// File: AdminLessonViewModel.swift

import Foundation

class AdminLessonViewModel: ObservableObject {
    @Published var lessons: [Lesson] = []
    @Published var isLoading: Bool = false
    
    @Published var creationError: String? = nil
    @Published var creationSuccess: Bool = false
    
    @Published var updateError: String? = nil
    @Published var updateSuccess: Bool = false
    
    @Published var errorMessage: String? = nil
    
    let repository: AdminLessonRepository
    
    init(repository: AdminLessonRepository = AdminLessonRepository()) {
        self.repository = repository
    }
    
    deinit {
        repository.stopListeningForLessons()
    }
    
    func fetchAllLessons() {
        isLoading = true
        errorMessage = nil
        
        repository.fetchAllLessons { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let lessons):
                    self.lessons = lessons
                case .failure(let error):
                    self.lessons = []
                    self.errorMessage = "Failed to fetch lessons: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func saveNewLesson(_ lesson: Lesson) {
        isLoading = true
        creationError = nil
        creationSuccess = false
        
        if lesson.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            lesson.desc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            lesson.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            creationError = "Title, Description, and Content cannot be empty."
            isLoading = false
            return
        }
        
        repository.saveNewLesson(lesson) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success():
                    self.creationSuccess = true
                case .failure(let error):
                    self.creationError = "Failed to save lesson: \(error.localizedDescription)"
                    self.creationSuccess = false
                }
            }
        }
    }
    
    func resetCreationStatusFlags() {
        creationSuccess = false
        creationError = nil
    }
    
    func fetchLessonDetails(lessonId: String) async -> Result<Lesson, Error> {
        await MainActor.run {
            isLoading = true
            updateError = nil
        }
        
        let result = await repository.fetchLessonDetails(lessonId: lessonId)
        
        await MainActor.run {
            isLoading = false
        }
        return result
    }
    
    // MARK: - Update Lesson (MODIFIED)
    func updateExistingLesson(lessonId: String, title: String, desc: String, content: String, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        isLoading = true
        updateError = nil
        updateSuccess = false
        
        var updateData: [String: Any] = [:]
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDesc = desc.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Build a dictionary with only the non-empty fields.
        // If a user clears a field in the UI, it won't be added to the update,
        // preserving the original value in the database.
        if !trimmedTitle.isEmpty {
            updateData["title"] = trimmedTitle
        }
        if !trimmedDesc.isEmpty {
            updateData["desc"] = trimmedDesc
        }
        if !trimmedContent.isEmpty {
            updateData["content"] = trimmedContent
        }
        
        // If the user cleared all fields, there's nothing to update.
        if updateData.isEmpty {
            let errorMsg = "At least one field must have content to update."
            self.updateError = errorMsg
            self.isLoading = false
            onError(errorMsg)
            return
        }
        
        repository.updateLesson(lessonId: lessonId, data: updateData) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success():
                    self.updateSuccess = true
                    onSuccess()
                case .failure(let error):
                    let errorMsg = "Failed to update lesson: \(error.localizedDescription)"
                    self.updateError = errorMsg
                    self.updateSuccess = false
                    onError(errorMsg)
                }
            }
        }
    }
    
    func resetUpdateStatusFlags() {
        updateSuccess = false
        updateError = nil
    }
    
    func deleteLesson(lessonId: String, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        repository.deleteLesson(lessonId: lessonId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    onSuccess()
                case .failure(let error):
                    onError("Failed to delete lesson: \(error.localizedDescription)")
                }
            }
        }
    }
}
