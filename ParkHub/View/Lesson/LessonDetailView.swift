//
//  LessonDetailView.swift
//  ParkHub
//
//  Created by Axel Valerio Ertamto on 30/05/25.
//

import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    var onBackClick: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                HStack {
                    LogoSmall()

                    Spacer()

                    Button(action: {
                        print("Logout tapped from LessonDetail")
                    }) {
                        Text("Logout")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                    }
                    .background(logoutRed)
                    .cornerRadius(8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .padding(.top, (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.top ?? 0 + 20)
            }
            .frame(maxWidth: .infinity)
            .background(primaryOrange)
            .edgesIgnoringSafeArea(.top)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
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

                    if !lesson.imageUrl.isEmpty && UIImage(named: lesson.imageUrl) != nil {
                        Image(lesson.imageUrl)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .padding(.bottom, 16)
                    }

                    Text(lesson.content)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)

            BotAppBar()
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    }
}

struct LessonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleLesson = Lesson(
            lessonId: "detail_prev_1",
            title: "Advanced SwiftUI Techniques",
            desc: "A deep dive into advanced concepts.",
            content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.",
            imageUrl: "swiftui_logo"
        )

        LessonDetailView(
            lesson: sampleLesson,
            onBackClick: { print("Back button tapped in preview") }
        )
    }
}
