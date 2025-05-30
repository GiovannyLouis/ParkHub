//
//  Logo.swift
//  ParkHub
//
//  Created by student on 30/05/25.
//

import SwiftUI

struct LogoBig: View {
    var body: some View {
        HStack(alignment: .center, spacing: 2) { // verticalAlignment, Spacer width
            Text("Park")
                .foregroundColor(.white)
                .font(.system(size: 36, weight: .semibold)) // W600 is semibold

            Text("hub")
                .foregroundColor(Color(red: 1.0, green: 0.627, blue: 0.004))
                .font(.system(size: 36, weight: .semibold))
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(Color.white)
                .cornerRadius(6) // clip(RoundedCornerShape(6.dp))
        }
    }
}

struct LogoSmall: View {
    var body: some View {
        // Outer Row with fillMaxWidth and Arrangement.Start
        HStack {
            // Inner Row with clickable
            HStack(alignment: .center, spacing: 2) {
                Text("Park")
                    .foregroundColor(.white)
                    .font(.system(size: 24, weight: .semibold))

                Text("hub")
                    .foregroundColor(Color(red: 1.0, green: 0.627, blue: 0.004))
                    .font(.system(size: 24, weight: .semibold))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.white)
                    .cornerRadius(6)
            }
//            .onTapGesture {
//                onNavigateToHome() // Execute the navigation action
//            }
            Spacer() // Pushes the logo to the leading edge (Arrangement.Start)
        }
        .frame(maxWidth: .infinity) // fillMaxWidth
    }
}
