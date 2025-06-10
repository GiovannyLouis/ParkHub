// reportCardView.swift
import SwiftUI

struct reportCardView: View {
    let report: Report // Accepts the whole Report object (which no longer has imageUrl)
    let currentUserId: String? // UID of the currently logged-in user
    @ObservedObject var reportViewModel: ReportViewModel // To call delete

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User info section
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.gray)
                
                Text(report.username.isEmpty ? "Anonymous" : report.username)
                    .font(.headline)
                
                Spacer()
            }
            
            // --- Static Placeholder Image Section ---
            // This is where the placeholder image is always displayed.
            // Ensure "backgroundparking" is in your Assets.xcassets.
            Image("backgroundparking")
                .resizable()
                .scaledToFill() // Or .scaledToFit() depending on desired behavior
                .frame(maxWidth: .infinity)
                .frame(height: 150) // Or your desired fixed height
                .clipped() // Important if using .scaledToFill() to prevent overflow
                .cornerRadius(8)
                .opacity(0.8) // Optional: make it look slightly like a placeholder

            // Report title
            Text(report.title)
                .font(.title3.bold())
                .lineLimit(2)
            
            // Report description
            Text(report.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)

            // Bottom section with timestamp and delete button
            HStack {
                // Timestamp
                Text("Reported: \(Date(timeIntervalSince1970: report.timestamp / 1000), style: .relative) ago")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Show delete button only if the report belongs to the current user
                if report.userId == currentUserId && !report.userId.isEmpty {
                    Button {
                        // Consider adding an alert here for delete confirmation
                        // Example: reportViewModel.showDeleteConfirmationAlert(for: report)
                        Task {
                            await reportViewModel.deleteReport(report: report, currentUserId: currentUserId ?? "")
                        }
                    }
                    
                    label: {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 2)
        }
        .padding()
        .background(Color(.systemBackground)) // Adapts to light/dark mode
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    // Create dummy data for preview (Report struct no longer has imageUrl)
    let dummyReportOwned = Report(
        reportId: "preview1",
        userId: "user123", // This user owns the report
        username: "John Preview",
        title: "Placeholder Image Test & Long Title That Might Wrap Around",
        description: "This card demonstrates the static placeholder image and how text flows with a longer description to check line limits.",
        timestamp: Date(timeIntervalSinceNow: -3600).timeIntervalSince1970 * 1000 // 1 hour ago
    )
    
    let dummyReportNotOwned = Report(
        reportId: "preview2",
        userId: "user456", // Different user
        username: "Jane Preview",
        title: "Another Report Example",
        description: "A shorter description for this card.",
        timestamp: Date(timeIntervalSinceNow: -86400).timeIntervalSince1970 * 1000 // 1 day ago
    )

    let reportVM_preview = ReportViewModel() // Dummy VM for preview

    return ScrollView { // Wrap in ScrollView for context if cards might overflow
        VStack(spacing: 20) {
            reportCardView(
                report: dummyReportOwned,
                currentUserId: "user123", // Simulate current user owns this report
                reportViewModel: reportVM_preview
            )
            // .padding() // Padding is already inside the card, apply here if you want extra space between cards

            reportCardView(
                report: dummyReportOwned, // Same report
                currentUserId: "anotherUser789", // Simulate current user DOES NOT own this report
                reportViewModel: reportVM_preview
            )

            reportCardView(
                report: dummyReportNotOwned,
                currentUserId: "user456", // Simulate current user owns this report
                reportViewModel: reportVM_preview
            )
        }
        .padding() // Padding around the VStack of cards
    }
    // .environmentObject(AuthViewModel()) // Only if AuthViewModel is directly used by reportCardView, which it isn't
}
