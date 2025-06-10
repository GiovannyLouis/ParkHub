import SwiftUI

struct submitReportView: View {
    @EnvironmentObject var reportVM: ReportViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showConfirmationAlert = false

    var body: some View {
        VStack(spacing: 0) {
            TopAppBar()

            GeometryReader { geometry in
                ScrollView {
                    VStack {
                        Spacer(minLength: 50)

                        VStack(alignment: .leading, spacing: 12) {
                            // Back Arrow
                            Image(systemName: "arrow.backward")
                                .font(.title2)
                                .foregroundColor(.black)
                                .padding(.bottom, 8)
                                .onTapGesture {
                                    dismiss()
                                }

                            // Title
                            Text("Report an Issue")
                                .font(.system(size: 24, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.bottom, 10)

                            // TextField - Title
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

                            // TextEditor - Description
                            Text("Description:")
                                .font(.system(size: 16, weight: .semibold))
                            TextEditor(text: $reportVM.reportDescription)
                                .frame(minHeight: 100, maxHeight: 200)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 8)
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
                                    .background(reportVM.isLoading ? Color.gray : Color.orange)
                                    .cornerRadius(8)
                            }
                            .disabled(reportVM.isLoading)
                            .padding(.top, 10)

                            // Error Message
                            if let errorMsg = reportVM.errorMessage, !errorMsg.isEmpty {
                                Text(errorMsg)
                                    .font(.callout)
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.top, 5)
                            }
                        }
                        .padding()
                        .frame(minHeight: geometry.size.height * 0.6) // ✅ Makes the white box taller on iPad
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 20)

                        Spacer(minLength: 40)
                    }
                    .frame(minHeight: geometry.size.height)
                }
                .background(
                    Image("backgroundparking")
                        .resizable()
                        .scaledToFill()
                        .overlay(Color.black.opacity(0.5))
                        .ignoresSafeArea()
                )
            }

            BotAppBar()
        }
        .alert("Report Submitted", isPresented: $showConfirmationAlert) {
            Button("OK", role: .cancel) {
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

#Preview {
    NavigationStack {
        submitReportView()
            .environmentObject(AuthViewModel())
            .environmentObject(ReportViewModel())
    }
}
