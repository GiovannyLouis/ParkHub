//
//  TopAppBar.swift
//  ParkHub
//
//  Created by student on 30/05/25.
//

import SwiftUI

struct TopAppBar: View { // Renamed to avoid potential conflicts
    var onNavigateToHome: () -> Void // Passed down to LogoSmallView

    var body: some View {
        VStack { // Column
            LogoSmallView(onNavigateToHome: onNavigateToHome)
        }
        .frame(maxWidth: .infinity) // fillMaxWidth
        .padding(EdgeInsets(top: 40, leading: 20, bottom: 20, trailing: 20))
        .background() // background(color = Color(0xffffa001))
    }
}
