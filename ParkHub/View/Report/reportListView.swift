//
//  reportListView.swift
//  ParkHub
//
//  Created by student on 03/06/25.
//

import SwiftUI

struct reportListView: View {
    @State private var reports: [Report] = [
        Report(reportId: "1", userId: "user1", title: "Broken parking meter", description: "The parking meter near the main entrance is not accepting coins or cards.", imageUrl: ""),
        Report(reportId: "2", userId: "user2", title: "Overflowing trash", description: "The trash bin near section B is overflowing.", imageUrl: ""),
        Report(reportId: "3", userId: "user3", title: "Damaged pavement", description: "Large crack near parking spot 42.", imageUrl: "")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            TopAppBar()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recent Reports")
                        .font(.title2.bold())
                        .padding(.horizontal)
                        .padding(.top)
                    
                    ForEach(reports, id: \.reportId) { report in
                        reportCardView(
                            userName: report.userId,
                            title: report.title,
                            description: report.description
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom)
            }
            
            BotAppBar()
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    reportListView()
}
