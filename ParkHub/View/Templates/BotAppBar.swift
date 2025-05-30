//
//  BotAppBar.swift
//  ParkHub
//
//  Created by student on 30/05/25.
//

import SwiftUI

struct BotAppBar: View {
    var body: some View {
        HStack(alignment: .center) { // Row, verticalAlignment = CenterVertically
            // For Arrangement.SpaceAround, we use Spacers
            Spacer()

            Button(action: {}) {
                VStack(spacing: 4) { // Add some spacing between icon and text
                    Image(systemName: "exclamationmark.triangle.fill") // Assumes image is in Assets.xcassets
                        .resizable()
                        .renderingMode(.template) // Allows tinting with foregroundColor
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                    Text("Report")
                        .font(.system(size: 14))
                }
                .foregroundColor(.white) // Apply tint to both Image and Text
            }
            .buttonStyle(PlainButtonStyle()) // Removes default button styling

            Spacer()

            Button(action: {}) {
                VStack(spacing: 4) { // Add some spacing between icon and text
                    Image(systemName: "car.fill") // Assumes image is in Assets.xcassets
                        .resizable()
                        .renderingMode(.template) // Allows tinting with foregroundColor
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                    Text("Location")
                        .font(.system(size: 14))
                }
                .foregroundColor(.white) // Apply tint to both Image and Text
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()

            Button(action: {}) {
                VStack(spacing: 4) { // Add some spacing between icon and text
                    Image(systemName: "book.fill") // Assumes image is in Assets.xcassets
                        .resizable()
                        .renderingMode(.template) // Allows tinting with foregroundColor
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                    Text("Lesson")
                        .font(.system(size: 14))
                }
                .foregroundColor(.white) // Apply tint to both Image and Text
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()
        }
        .frame(maxWidth: .infinity) // fillMaxWidth
        .padding(.vertical, 12)
        .background(Color(red: 1.0, green: 0.627, blue: 0.004)) // background(color = Color(0xffffa001))
        .ignoresSafeArea()
    }
}

#Preview {
    BotAppBar()
}

