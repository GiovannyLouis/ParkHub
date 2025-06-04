// BotAppBar.swift
// ParkHub
// Created by student on 30/05/25.

import SwiftUI

struct BotAppBar: View {
// To make these links work, the view that USES BotAppBar
// needs to be inside a NavigationView or NavigationStack.

var body: some View {
    HStack(alignment: .center) {
        Spacer()

        // Report Button - Navigates to submitReportView
        NavigationLink(destination: submitReportView()) { // submitReportView is the destination
            VStack(spacing: 4) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                Text("Report")
                    .font(.system(size: 14))
            }
            .foregroundColor(.white)
        }
        .buttonStyle(PlainButtonStyle())

        Spacer()

        // Location Button - Navigates to LocationView
        NavigationLink(destination: LocationView()) { // LocationView is already defined
            VStack(spacing: 4) {
                Image(systemName: "car.fill")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                Text("Location")
                    .font(.system(size: 14))
            }
            .foregroundColor(.white)
        }
        .buttonStyle(PlainButtonStyle())

        Spacer()

        // Lesson Button - Navigates to UserLessonSectionView (which uses LessonPageView)
        NavigationLink(destination: UserLessonSectionView()) { // UserLessonSectionView uses LessonPageView
            VStack(spacing: 4) {
                Image(systemName: "book.fill")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                Text("Lesson")
                    .font(.system(size: 14))
            }
            .foregroundColor(.white)
        }
        .buttonStyle(PlainButtonStyle())

        Spacer()
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 12)
    .background(Color(red: 1.0, green: 0.627, blue: 0.004)) // primaryOrange
    // Consider implications of .ignoresSafeArea() as previously discussed
}
}

// --- Destination View for "Lesson" Button (if not already defined) ---
// This wrapper ensures LessonPageView gets the AuthViewModel
struct UserLessonSectionView: View {
@EnvironmentObject var authVM: AuthViewModel
var body: some View {
LessonPageView() // Ensure LessonPageView is defined
// .navigationTitle("Lessons") // LessonPageView might set its own title or have TopAppBar
// .navigationBarHidden(true) // If LessonPageView has its own complete nav bar (TopAppBar)
}
}

// --- Preview for BotAppBar ---
#Preview {
// To make NavigationLinks in BotAppBar work in its own preview,
// BotAppBar needs to be embedded in a NavigationView or NavigationStack.
NavigationView {
VStack {
Spacer() // Content placeholder
Text("Some Page Content")
.padding()
Spacer()
BotAppBar()
}
// Provide dummy environment objects if needed by linked views
// For submitReportView:
.environmentObject(AuthViewModel())
.environmentObject(ReportViewModel())
// For UserLessonSectionView (which uses LessonPageView):
// AuthViewModel is already provided above.
// If LessonPageView uses LessonViewModel, add it:
// .environmentObject(LessonViewModel())
}
}

// Make sure the following views are defined and accessible:
// - submitReportView.swift (as you provided)
// - LocationView.swift
// - LessonPageView.swift
// - TopAppBar.swift (used by submitReportView)
// And the necessary ViewModels for them.
