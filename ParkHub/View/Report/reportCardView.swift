//
//  reportCardView.swift
//  ParkHub
//
//  Created by student on 30/05/25.
//

import SwiftUI

struct reportCardView: View {
    let userName: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User info section
            HStack {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.blue)
                
                Text(userName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
            }
            
            // Report image using backgroundparking from assets
            Image("backgroundparking")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .clipped()
                .cornerRadius(8)
            
            // Report title
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            
            // Report description
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // Divider line
            Divider()
                .padding(.vertical, 4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    reportCardView(
        userName: "John Doe",
        title: "Broken parking meter",
        description: "The parking meter near the main entrance is not accepting coins or cards. It's been like this for 3 days now."
    )
    .padding()
    
}
