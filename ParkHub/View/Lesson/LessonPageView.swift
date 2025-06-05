// File: LessonPageView.swift

import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
let logoutRed = Color(hex: 0xFFD9534F)
let primaryOrange = Color(hex: 0xffffa001)

struct LessonPageView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var lessonVM: LessonViewModel

    var body: some View {
        VStack(spacing: 0) {
            TopAppBar()

            if lessonVM.isLoading {
                Spacer()
                ProgressView("Loading lessons...")
                    .progressViewStyle(CircularProgressViewStyle(tint: primaryOrange))
                    .scaleEffect(1.5)
                Spacer()
            } else if let message = lessonVM.errorMessage {
                Spacer()
                VStack {
                    Text(message)
                        .foregroundColor(.red)
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Try Again") {
                        lessonVM.fetchAllLessons()
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .tint(primaryOrange)
                }
                Spacer()
            } else if lessonVM.lessons.isEmpty {
                Spacer()
                VStack {
                    Text("No lessons available at the moment.")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding()
                    Button("Refresh") {
                        lessonVM.fetchAllLessons()
                    }
                    .padding()
                    .buttonStyle(.bordered)
                }
                Spacer()
            } else {
                List {
                    ForEach(lessonVM.lessons) { lesson in
                        LessonCardView(lesson: lesson)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                    }
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    lessonVM.fetchAllLessons()
                }
            }

            BotAppBar()
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .onAppear {
            if lessonVM.lessons.isEmpty && !lessonVM.isLoading {
                lessonVM.fetchAllLessons()
            }
        }
        .onDisappear {
        }
    }
}

#Preview {
    NavigationView {
        LessonPageView()
            .environmentObject(AuthViewModel())
            .environmentObject(LessonViewModel())
    }
}
