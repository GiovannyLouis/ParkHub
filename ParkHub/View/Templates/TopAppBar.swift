//
//  TopAppBar.swift
//  ParkHub
//
//  Created by student on 30/05/25.
//

import SwiftUI

struct TopAppBar: View { // Renamed to avoid potential conflicts
    var body: some View {
        HStack() { // Column
            Spacer()
            LogoSmall()
        }
        .frame(maxWidth: .infinity) // fillMaxWidth
        .padding()
        .background(Color(red: 1.0, green: 0.627, blue: 0.004)) // background(color = Color(0xffffa001))
    }
}

#Preview {
    TopAppBar()
}
