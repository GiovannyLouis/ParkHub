// submitReportView.swift
import SwiftUI

struct submitReportView: View {
    // ViewModel and Auth Environment Objects
    @EnvironmentObject var reportVM: ReportViewModel
    @EnvironmentObject var authVM: AuthViewModel

    // Environment variable to dismiss the view
    @Environment(\.dismiss) var dismiss

    // Removed token and id as they are handled by ViewModels and Firebase Auth
    // var token: String
    // var id: Int

    // Removed @State variables for inputs as they are now in reportVM
    // @State private var reportTitleInput: String = ""
    // @State private var reportDescriptionInput: String = ""
    // @State private var selectedImage: UIImage? // Image functionality removed
    // @State private var showImagePicker = false // Image functionality removed

    // Assuming TopAppBar and BotAppBar are defined elsewhere
    // If not, you'll need to provide their definitions or comment them out.
    // For this example, I'll assume they exist.

    var body: some View {
        VStack(spacing: 0) { // Ensure no spacing between TopAppBar, content, BotAppBar
            TopAppBar() // Your custom TopAppBar

            // Main content area that scrolls
            ScrollView { // Make the central form content scrollable
                VStack { // Main vertical stack for content between Top and Bot AppBars
                    Spacer() // Pushes form content down a bit if ScrollView is not full
            
                    // Form container VStack (white rounded box)
                    VStack(alignment: .leading, spacing: 12) { // Adjusted spacing
                        // Back Arrow
                        Image(systemName: "arrow.backward")
                            .font(.title2)
                            .foregroundColor(.black) // Or your theme color
                            .padding(.bottom, 8) // Add some space below the arrow
                            .onTapGesture {
                                dismiss()
                            }

                        // "Report an Issue" Title
                        Text("Report an Issue")
                            .font(.system(size: 24, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 10) // Add space below title

                        // Title field
                        Text("Title:")
                            .font(.system(size: 16, weight: .semibold))
                        TextField("Enter title", text: $reportVM.reportTitle) // Bind to ViewModel
                            .padding(10)
                            .background(Color(white: 0.784)) // Your containerColor
                            .cornerRadius(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )


                        // Description field
                        Text("Description:")
                            .font(.system(size: 16, weight: .semibold))
                        TextEditor(text: $reportVM.reportDescription) // Bind to ViewModel
                            .frame(minHeight: 80, idealHeight: 100, maxHeight: 150) // Adjusted height
                            .padding(EdgeInsets(top: 8, leading: 5, bottom: 8, trailing: 5)) // More typical padding for TextEditor
                            .background(Color(white: 0.784)) // Your containerColor
                            .cornerRadius(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        // Image Upload Field - REMOVED as per "no image" requirement
                        // Text("Upload Image:") ...
                        // Button(...) { ... }

                        // Submit Button
                        Button(action: {
                            guard let user = authVM.firebaseAuthUser else {
                                reportVM.errorMessage = "You must be logged in to submit a report."
                                return
                            }
                            // Basic client-side validation
                            guard !reportVM.reportTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                                  !reportVM.reportDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                                reportVM.errorMessage = "Title and description cannot be empty."
                                return
                            }
                            Task {
                                let success = await reportVM.createReport(
                                    currentUserId: user.uid,
                                    currentUsername: user.displayName ?? "Anonymous"
                                )
                                if success {
                                    dismiss()
                                }
                            }
                        }) {
                            Text(reportVM.isLoading ? "Submitting..." : "Submit Report")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(reportVM.isLoading ? Color.gray : Color(red: 1.0, green: 0.627, blue: 0.004)) // Your orange button color
                                .cornerRadius(8)
                        }
                        .disabled(reportVM.isLoading)
                        .padding(.top, 10) // Add space above the button

                        // Display error message from ViewModel
                        if let errorMsg = reportVM.errorMessage, !errorMsg.isEmpty {
                            Text(errorMsg)
                                .font(.callout)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 5)
                        }
                    }
                    .padding() // Inner padding for the white rounded box content
                    .background(.white)
                    .cornerRadius(16)
                    .padding(.horizontal, 30) // Adjusted horizontal padding for the white box
                    .padding(.vertical, 20)   // Adjusted vertical padding for the white box
                    
                    Spacer() // Pushes form content up if ScrollView is not full
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Allow VStack to expand
            }
            .background( // Background for the ScrollView area (behind the white card)
                Image("backgroundparking")
                    .resizable()
                    .overlay(Color.black.opacity(0.5))
                    .scaledToFill()
                    .ignoresSafeArea(.container, edges: .all) // Let background extend
            )
            .clipped() // Clip the ScrollView's content if background is applied here

            BotAppBar() // Your custom BotAppBar
        }
        // .background(...) // Background was moved to the ScrollView's content area
        .navigationBarHidden(true)
        .onAppear {
            reportVM.clearInputFields() // Clear fields and errors when view appears
            // print("submitReportView appeared.") // Removed id and token
        }
    }
}

// --- Preview ---
#Preview {
    // Ensure TopAppBar and BotAppBar are defined or provide dummies for preview
    // struct TopAppBar: View { var body: some View { Text("Top App Bar").padding().background(Color.blue.opacity(0.3)) } }
    // struct BotAppBar: View { var body: some View { Text("Bot App Bar").padding().background(Color.green.opacity(0.3)) } }

    return NavigationStack {
        submitReportView()
            // Remove token and id from preview as they are no longer properties
            // submitReportView(token: "PREVIEW_TOKEN", id: 123)
            .environmentObject(AuthViewModel())
            .environmentObject(ReportViewModel())
    }
}


