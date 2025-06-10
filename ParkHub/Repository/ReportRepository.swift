//
//  ReportRepository.swift
//  ParkHub
//
//  Created by student on 10/06/25.
//


import Foundation
import FirebaseDatabase
import FirebaseAuth

final class ReportRepository {
    private var dbRef: DatabaseReference
    private var reportsRef: DatabaseReference
    private var reportsHandle: DatabaseHandle?

    init() {
        dbRef = Database.database().reference()
        reportsRef = dbRef.child("reports")
    }

    func createReport(_ report: Report) async throws {
        let reportData = try JSONEncoder().encode(report)
        let json = try JSONSerialization.jsonObject(with: reportData, options: []) as? [String: Any]
        guard let reportJSON = json else {
            throw NSError(domain: "EncodingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to prepare report data for saving."])
        }
        try await reportsRef.child(report.reportId).setValue(reportJSON)
    }

    func fetchReports(onSuccess: @escaping ([Report]) -> Void, onError: @escaping (String) -> Void) {
        if let handle = reportsHandle {
            reportsRef.removeObserver(withHandle: handle)
        }

        reportsHandle = reportsRef.queryOrdered(byChild: "timestamp").observe(.value) { snapshot in
            var fetchedReports: [Report] = []

            guard snapshot.exists(), let value = snapshot.value as? [String: Any] else {
                onSuccess([])
                return
            }

            for (key, reportData) in value {
                if let dict = reportData as? [String: Any] {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
                        let report = try JSONDecoder().decode(Report.self, from: jsonData)
                        fetchedReports.append(report)
                    } catch {
                        print("Decode error for report \(key): \(error)")
                    }
                }
            }

            let sorted = fetchedReports.sorted(by: { $0.timestamp > $1.timestamp })
            onSuccess(sorted)
        } withCancel: { error in
            onError("Failed to fetch reports: \(error.localizedDescription)")
        }
    }

    func deleteReport(reportId: String) async throws {
        try await reportsRef.child(reportId).removeValue()
    }

    func removeObservers() {
        if let handle = reportsHandle {
            reportsRef.removeObserver(withHandle: handle)
            reportsHandle = nil
        }
    }

    deinit {
        removeObservers()
    }
}
