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


final class ReportViewModelTests: XCTestCase {

    class MockReportRepository: ReportRepository {
        var shouldFail = false
        var reports: [Report] = []

        override func fetchReports(onSuccess: @escaping ([Report]) -> Void, onError: @escaping (String) -> Void) {
            if shouldFail {
                onError("Mock fetch failed")
            } else {
                onSuccess(reports)
            }
        }

        override func createReport(_ report: Report) async throws {
            if shouldFail {
                throw NSError(domain: "Mock", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock create failed"])
            }
        }

        override func deleteReport(reportId: String) async throws {
            if shouldFail {
                throw NSError(domain: "Mock", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock delete failed"])
            }
        }
    }

    func testFetchReportsSuccess() {
        let mockRepo = MockReportRepository()
        mockRepo.reports = [
            Report(userId: "123", username: "John", title: "Test", description: "Some issue")
        ]

        let viewModel = ReportViewModel(reportRepository: mockRepo)
        

        let expectation = XCTestExpectation(description: "Fetch reports succeeds")

        viewModel.fetchReports()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(viewModel.reports.count, 1)
            XCTAssertNil(viewModel.errorMessage)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testFetchReportsFailure() {
        let mockRepo = MockReportRepository()
        mockRepo.shouldFail = true

        let viewModel = ReportViewModel()
        viewModel.reportRepository = mockRepo

        let expectation = XCTestExpectation(description: "Fetch reports fails")

        viewModel.fetchReports()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertTrue(viewModel.reports.isEmpty)
            XCTAssertNotNil(viewModel.errorMessage)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testCreateReportSuccess() async {
        let mockRepo = MockReportRepository()
        let viewModel = ReportViewModel()
        viewModel.reportRepository = mockRepo

        viewModel.reportTitle = "Title"
        viewModel.reportDescription = "Description"

        let success = await viewModel.createReport(currentUserId: "123", currentUsername: "John")
        XCTAssertTrue(success)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.reportTitle, "")
        XCTAssertEqual(viewModel.reportDescription, "")
    }

    func testCreateReportFailure_EmptyFields() async {
        let viewModel = ReportViewModel()
        viewModel.reportTitle = ""
        viewModel.reportDescription = ""

        let success = await viewModel.createReport(currentUserId: "123", currentUsername: "John")
        XCTAssertFalse(success)
        XCTAssertEqual(viewModel.errorMessage, "Title and description cannot be empty.")
    }

    func testCreateReportFailure_RepoThrows() async {
        let mockRepo = MockReportRepository()
        mockRepo.shouldFail = true

        let viewModel = ReportViewModel()
        viewModel.reportRepository = mockRepo

        viewModel.reportTitle = "Test"
        viewModel.reportDescription = "Description"

        let success = await viewModel.createReport(currentUserId: "123", currentUsername: "John")
        XCTAssertFalse(success)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    func testDeleteReportSuccess() async {
        let mockRepo = MockReportRepository()
        let viewModel = ReportViewModel()
        viewModel.reportRepository = mockRepo

        let report = Report(userId: "123", username: "John", title: "Issue", description: "Desc")
        await viewModel.deleteReport(report: report, currentUserId: "123")

        XCTAssertNil(viewModel.errorMessage)
    }

    func testDeleteReportFailure_NotOwner() async {
        let viewModel = ReportViewModel()

        let report = Report(userId: "otherUser", username: "Jane", title: "Wrong", description: "Oops")

        await viewModel.deleteReport(report: report, currentUserId: "123")
        XCTAssertEqual(viewModel.errorMessage, "You can only delete your own reports.")
    }

    func testDeleteReportFailure_RepoThrows() async {
        let mockRepo = MockReportRepository()
        mockRepo.shouldFail = true

        let viewModel = ReportViewModel()
        viewModel.reportRepository = mockRepo

        let report = Report(userId: "123", username: "John", title: "Fail", description: "Oops")
        await viewModel.deleteReport(report: report, currentUserId: "123")

        XCTAssertNotNil(viewModel.errorMessage)
    }
}


final class LocationViewModelTests: XCTestCase {

    var viewModel: LocationViewModel!

    override func setUp() {
        super.setUp()
        viewModel = LocationViewModel(repository: MockLocationRepository())
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testBukitLocationSections() {
        let expectation = XCTestExpectation(description: "Bukit locations loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.vertiBukitLocations.count, 18)
            XCTAssertEqual(self.viewModel.horizBukitLocations.count, 18)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testLapanganLocationSections() {
        let expectation = XCTestExpectation(description: "Lapangan locations loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.locations_260_273.count, 14)
            XCTAssertEqual(self.viewModel.locations_220_259_rev.count, 40)
            XCTAssertEqual(self.viewModel.locations_0_39.count, 40)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testGedungFloorFiltering() {
        let expectation = XCTestExpectation(description: "Gedung locations loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.viewModel.currentGedungFloor = 4 // Even floor
            XCTAssertEqual(self.viewModel.filteredGedungsForCurrentFloor.count, 36)
            XCTAssertEqual(self.viewModel.evenFloorLeftSectionSpots.count, 18)

            self.viewModel.currentGedungFloor = 5 // Odd floor
            XCTAssertEqual(self.viewModel.filteredGedungsForCurrentFloor.count, 39)
            XCTAssertEqual(self.viewModel.oddFloorLeftSectionSpots.count, 21)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testGedungFloorNavigationLimits() {
        viewModel.currentGedungFloor = 14
        viewModel.incrementGedungFloor()
        XCTAssertEqual(viewModel.currentGedungFloor, 14)

        viewModel.currentGedungFloor = 3
        viewModel.decrementGedungFloor()
        XCTAssertEqual(viewModel.currentGedungFloor, 3)
    }
}
