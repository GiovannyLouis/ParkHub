// ReportViewModel.swift
// ReportViewModel.swift
// ParkHub

import Foundation

class ReportViewModel: ObservableObject {
    @Published var reports: [Report] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    @Published var reportTitle: String = ""
    @Published var reportDescription: String = ""

    var reportRepository = ReportRepository()

    init(reportRepository: ReportRepository = ReportRepository()) {
            self.reportRepository = reportRepository
            fetchReports()
        }

    deinit {
        reportRepository.removeObservers()
    }

    func clearInputFields() {
        reportTitle = ""
        reportDescription = ""
        errorMessage = nil
    }

    func createReport(currentUserId: String, currentUsername: String) async -> Bool {
        guard !reportTitle.isEmpty, !reportDescription.isEmpty else {
            errorMessage = "Title and description cannot be empty."
            return false
        }

        isLoading = true
        errorMessage = nil

        let newReport = Report(
            userId: currentUserId,
            username: currentUsername.isEmpty ? "Anonymous" : currentUsername,
            title: reportTitle,
            description: reportDescription
        )

        var success = false

        do {
            try await reportRepository.createReport(newReport)
            clearInputFields()
            print("ReportViewModel: Report created: \(newReport.reportId)")
            success = true
        } catch {
            errorMessage = "Failed to create report: \(error.localizedDescription)"
        }

        isLoading = false
        return success
    }

    func fetchReports() {
        isLoading = true
        errorMessage = nil

        reportRepository.fetchReports { [weak self] reports in
            self?.reports = reports
            self?.isLoading = false
        } onError: { [weak self] error in
            self?.errorMessage = error
            self?.reports = []
            self?.isLoading = false
        }
    }

    func deleteReport(report: Report, currentUserId: String) async {
        guard report.userId == currentUserId else {
            errorMessage = "You can only delete your own reports."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await reportRepository.deleteReport(reportId: report.reportId)
            print("ReportViewModel: Deleted report \(report.reportId)")
        } catch {
            errorMessage = "Failed to delete report: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
