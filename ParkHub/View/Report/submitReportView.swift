// submitReportView.swift
import SwiftUI

struct submitReportView: View {
    // ViewModel and Auth Environment Objects
    @EnvironmentObject var reportVM: ReportViewModel
    @EnvironmentObject var authVM: AuthViewModel

    // Environment variable to dismiss the view
    @Environment(\.dismiss) var dismiss

    // 1. ADD THIS STATE VARIABLE to control the confirmation alert
    @State private var showConfirmationAlert = false

    var body: some View {
        VStack(spacing: 0) {
            TopAppBar()

            ScrollView {
                VStack {
                    Spacer()
            
                    VStack(alignment: .leading, spacing: 12) {
                        // ... (Back Arrow, Title, TextFields are all correct)
                        Image(systemName: "arrow.backward")
                            .font(.title2)
                            .foregroundColor(.black)
                            .padding(.bottom, 8)
                            .onTapGesture {
                                dismiss()
                            }

                        Text("Report an Issue")
                            .font(.system(size: 24, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 10)

                        Text("Title:")
                            .font(.system(size: 16, weight: .semibold))
                        TextField("Enter title", text: $reportVM.reportTitle)
                            .padding(10)
                            .background(Color(white: 0.784))
                            .cornerRadius(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )

                        Text("Description:")
                            .font(.system(size: 16, weight: .semibold))
                        TextEditor(text: $reportVM.reportDescription)
                            .frame(minHeight: 80, idealHeight: 100, maxHeight: 150)
                            .padding(EdgeInsets(top: 8, leading: 5, bottom: 8, trailing: 5))
                            .background(Color(white: 0.784))
                            .cornerRadius(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        // Submit Button
                        Button(action: {
                            guard let user = authVM.firebaseAuthUser else {
                                reportVM.errorMessage = "You must be logged in to submit a report."
                                return
                            }
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
                                // 2. MODIFIED LOGIC: Show alert on success
                                if success {
                                    showConfirmationAlert = true
                                }
                            }
                        }) {
                            Text(reportVM.isLoading ? "Submitting..." : "Submit Report")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(reportVM.isLoading ? Color.gray : Color(red: 1.0, green: 0.627, blue: 0.004))
                                .cornerRadius(8)
                        }
                        .disabled(reportVM.isLoading)
                        .padding(.top, 10)

                        if let errorMsg = reportVM.errorMessage, !errorMsg.isEmpty {
                            Text(errorMsg)
                                .font(.callout)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 5)
                        }
                    }
                    .padding()
                    .background(.white)
                    .cornerRadius(16)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 20)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(
                Image("backgroundparking")
                    .resizable()
                    .overlay(Color.black.opacity(0.5))
                    .scaledToFill()
                    .ignoresSafeArea(.container, edges: .all)
            )
            .clipped()

            BotAppBar()
        }
        // 3. ADD THE ALERT MODIFIER HERE
        .alert("Report Submitted", isPresented: $showConfirmationAlert) {
            Button("OK", role: .cancel) {
                // When the user taps "OK", dismiss the view
                dismiss()
            }
        } message: {
            Text("Thank you! Your report has been successfully submitted.")
        }
        .navigationBarHidden(true)
        .onAppear {
            reportVM.clearInputFields()
        }
    }
}

// --- Preview ---
#Preview {
    
    return NavigationStack {
        submitReportView()
            // Remove token and id from preview as they are no longer properties
            // submitReportView(token: "PREVIEW_TOKEN", id: 123)
            .environmentObject(AuthViewModel())
            .environmentObject(ReportViewModel())
    }
}


