//
//  LessonDetailView.swift
//  ParkHub
//
//  Created by Axel Valerio Ertamto on 03/06/25.
//


import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    var onBackClick: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Custom Top Bar
            VStack {
                HStack {
                    LogoSmall() // Assuming LogoSmall is defined

                    Spacer()

                    Button(action: {
                        // Implement actual logout logic
                        print("Logout tapped from LessonDetail")
                    }) {
                        Text("Logout")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(logoutRed) // Assuming logoutRed is defined
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                // Apply top padding considering safe area
                .padding(.top, (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.top ?? 0 + 20)
            }
            .frame(maxWidth: .infinity)
            .background(primaryOrange) // Assuming primaryOrange is defined
            .edgesIgnoringSafeArea(.top) // Make background extend to top edge

            // Scrollable Content
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Back button and Title
                    HStack(spacing: 8) {
                        Button(action: onBackClick) {
                            Image(systemName: "arrow.backward")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(.black)
                        }
                        Text(lesson.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.bottom, 16)

                    // Image display - Fixed
                    if let imageName = lesson.imageUrl, !imageName.isEmpty {
                        // Assuming imageName is an asset name.
                        // If it's a URL, you'd use AsyncImage (iOS 15+)
                        // or a custom image loader.
                        Image(imageName) // Uses the asset name directly
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped() // Clips the image to the frame bounds
                            .cornerRadius(8) // Optional: add corner radius to image
                            .padding(.bottom, 16)
                    }

                    // Lesson Content
                    Text(lesson.content)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(16) // Padding for the content within ScrollView
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white) // Background for the scrollable content area

            BotAppBar() // Assuming BotAppBar is defined
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)) // Overall background
        .navigationBarHidden(true) // Hide system navigation bar if this view is part of a NavigationView
    }
}

struct LessonDetailView_Previews: PreviewProvider {
    static var previews: some View {

        let sampleLesson = Lesson(
            id: "detail_prev_1", // Corrected: used 'id'
            title: "Advanced SwiftUI Techniques",
            desc: "A deep dive into advanced concepts.", // desc is part of Lesson model
            content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.",
            imageUrl: "swiftui_logo" // Make sure "swiftui_logo" exists in your Assets.xcassets for preview
        )

        LessonDetailView(
            lesson: sampleLesson,
            onBackClick: { print("Back button tapped in preview") }
        )
    }
}
