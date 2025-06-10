//
//  ParkHubTests.swift
//  ParkHubTests
//
//  Created by student on 21/05/25.
//

import XCTest
@testable import ParkHub

final class AdminLessonViewModelTests: XCTestCase {

    class MockAdminLessonRepository: AdminLessonRepository {
        var shouldReturnError = false

        override func fetchAllLessons(completion: @escaping (Result<[Lesson], Error>) -> Void) {
            if shouldReturnError {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])))
            } else {
                completion(.success([
                    Lesson(id: "1", title: "Sample", desc: "Sample Desc", content: "Sample Content", userId: nil)
                ]))
            }
        }

        override func saveNewLesson(_ lesson: Lesson, completion: @escaping (Result<Void, Error>) -> Void) {
            if shouldReturnError {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock save error"])))
            } else {
                completion(.success(()))
            }
        }
    }

    func testFetchAllLessonsSuccess() {
        let mockRepo = MockAdminLessonRepository()
        let viewModel = AdminLessonViewModel(repository: mockRepo)

        let expectation = XCTestExpectation(description: "Fetch lessons")
        viewModel.fetchAllLessons()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(viewModel.lessons.count, 1)
            XCTAssertNil(viewModel.errorMessage)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchAllLessonsFailure() {
        let mockRepo = MockAdminLessonRepository()
        mockRepo.shouldReturnError = true
        let viewModel = AdminLessonViewModel(repository: mockRepo)

        let expectation = XCTestExpectation(description: "Fetch lessons failure")
        viewModel.fetchAllLessons()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(viewModel.lessons.count, 0)
            XCTAssertNotNil(viewModel.errorMessage)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testSaveNewLessonValidationFails() {
        let viewModel = AdminLessonViewModel(repository: MockAdminLessonRepository())
        viewModel.saveNewLesson(Lesson(id: "test-id", title: "", desc: "", content: "", userId: nil))
        XCTAssertEqual(viewModel.creationError, "Title, Description, and Content cannot be empty.")
        XCTAssertFalse(viewModel.creationSuccess)
    }

    func testSaveNewLessonSuccess() {
        let viewModel = AdminLessonViewModel(repository: MockAdminLessonRepository())

        let expectation = XCTestExpectation(description: "Save lesson")
        viewModel.saveNewLesson(Lesson(id: "test-id", title: "T", desc: "D", content: "C", userId: nil))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(viewModel.creationSuccess)
            XCTAssertNil(viewModel.creationError)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
}

final class LessonViewModelTests: XCTestCase {

    class MockLessonRepository: LessonRepository {
        var shouldReturnError = false

        override func observeLessons(onUpdate: @escaping ([Lesson]) -> Void, onError: @escaping (Error) -> Void) {
            if shouldReturnError {
                onError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Fetch error"]))
            } else {
                onUpdate([
                    Lesson(id: "1", title: "Title", desc: "Description", content: "Content", userId: nil)
                ])
            }
        }
    }

    func testFetchAllLessonsSuccess() {
        let mockRepo = MockLessonRepository()
        let viewModel = LessonViewModel(repository: mockRepo)


        let expectation = XCTestExpectation(description: "Fetch lessons")
        viewModel.fetchAllLessons()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(viewModel.lessons.isEmpty)
            XCTAssertNil(viewModel.errorMessage)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchAllLessonsFailure() {
        let mockRepo = MockLessonRepository()
        mockRepo.shouldReturnError = true
        let viewModel = LessonViewModel(repository: mockRepo)

        let expectation = XCTestExpectation(description: "Fetch lessons failure")
        viewModel.fetchAllLessons()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(viewModel.lessons.isEmpty)
            XCTAssertNotNil(viewModel.errorMessage)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
