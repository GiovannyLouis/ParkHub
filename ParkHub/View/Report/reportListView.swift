// reportListView.swift
import SwiftUI

struct reportListView: View {
    @EnvironmentObject var reportVM: ReportViewModel
    @EnvironmentObject var authVM: AuthViewModel

    // Assuming TopAppBar and BotAppBar are defined elsewhere
    // If not, you'll need to provide their definitions or comment them out.
    // For this example, I'll assume they exist.

    var body: some View {
        VStack(spacing: 0) { // No spacing between app bars and content
            TopAppBar() // Your custom TopAppBar

            // Main content area
            Group { // Group to apply frame and handle states
                if reportVM.isLoading && reportVM.reports.isEmpty {
                    ProgressView("Loading reports...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = reportVM.errorMessage, !errorMessage.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("Error Loading Reports")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Retry") {
                            reportVM.fetchReports()
                        }
                        .padding(.top, 5)
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else if reportVM.reports.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "list.bullet.rectangle.portrait")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No Reports Found")
                            .font(.headline)
                        Text("There are currently no reports to display.")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    ScrollView {
                        // "Recent Reports" Title - can be here or in TopAppBar
                        Text("Recent Reports")
                            .font(.title2.bold())
                            .padding(.horizontal)
                            .padding(.top, 10) // Add some top padding if title is here
                            .frame(maxWidth: .infinity, alignment: .leading) // Align to leading

                        LazyVStack(alignment: .center, spacing: 16) {
                            ForEach(reportVM.reports) { report in
                                reportCardView(
                                    report: report,
                                    currentUserId: authVM.firebaseAuthUser?.uid,
                                    reportViewModel: reportVM
                                )
                                .padding(.horizontal) // Padding for each card
                            }
                        }
                        .padding(.vertical) // Padding for the content within ScrollView
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure Group takes available space

            BotAppBar() // Your custom BotAppBar
        }
        .navigationBarHidden(true) // Assuming TopAppBar handles navigation appearance
        .onAppear {
            // The listener in ReportViewModel's init should keep data updated.
            // Explicitly fetching can be done if needed, e.g., for pull-to-refresh.
            // reportVM.fetchReports()
            print("reportListView appeared. Reports count: \(reportVM.reports.count)")
        }
    }
}

#Preview {
    // Ensure TopAppBar and BotAppBar are defined or provide dummies for preview
    // struct TopAppBar: View { var body: some View { Text("Top App Bar Preview").padding().background(Color.blue.opacity(0.3)) } }
    // struct BotAppBar: View { var body: some View { Text("Bot App Bar Preview").padding().background(Color.green.opacity(0.3)) } }

    let authVM_preview = AuthViewModel()
    // To test delete button visibility in preview, you'd mock a logged-in user:
    // For example, if you have a way to create a FirebaseAuth.User mock or a simplified User struct for preview:
    // authVM_preview.firebaseAuthUser = MockUser(uid: "user1_preview", displayName: "Preview Owner")

    let reportVM_preview = ReportViewModel()
    // Populate with dummy data that matches the current Report model (no imageUrl)
    reportVM_preview.reports = [
        Report(reportId: "prev1", userId: "user1_preview", username: "First User", title: "Leaky Faucet in Restroom A", description: "The faucet in the main restroom has been leaking for two days.", timestamp: Date(timeIntervalSinceNow: -3600 * 24 * 2).timeIntervalSince1970 * 1000), // 2 days ago
        Report(reportId: "prev2", userId: "user2_preview", username: "Second User", title: "Broken Light Fixture", description: "Parking lot light near section C is out.", timestamp: Date(timeIntervalSinceNow: -3600 * 5).timeIntervalSince1970 * 1000), // 5 hours ago
        Report(reportId: "prev3", userId: "user1_preview", username: "First User", title: "Graffiti on Wall", description: "Offensive graffiti found on the east wall of the building.", timestamp: Date().timeIntervalSince1970 * 1000) // Now
    ]
    // reportVM_preview.isLoading = true // To test loading state
    // reportVM_preview.errorMessage = "A sample error message for preview." // To test error state
    // reportVM_preview.reports = [] // To test empty state

    return NavigationView { // NavigationView provides a context for potential navigation
        reportListView()
            .environmentObject(authVM_preview)
            .environmentObject(reportVM_preview)
    }
    // .preferredColorScheme(.dark) // To test dark mode
}

