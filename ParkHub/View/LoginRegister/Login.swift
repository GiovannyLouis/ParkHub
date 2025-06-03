//
//  Login.swift
//  ParkHub
//
//  Created by student on 03/06/25.
//

import SwiftUI

struct Login: View {
    @State private var username: String = ""
    @State private var password: String = ""
    
    var body: some View {
        ZStack {
            // Background color
            Color(red: 1.0, green: 0.627, blue: 0.004) // #FFA001
                .ignoresSafeArea()
            
            VStack {
                // Your ParkHub logo
                LogoBig()
                    .padding(.bottom, 24)
                
                // Login form container
                VStack {
                    // Username field
                    TextField("Username", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .background(Color.white)
                        .cornerRadius(4)
                        .padding(.horizontal)
                    
                    Spacer()
                        .frame(height: 12)
                    
                    // Password field
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .background(Color.white)
                        .cornerRadius(4)
                        .padding(.horizontal)
                    
                    Spacer()
                        .frame(height: 24)
                    
                    // Login button
                    Button(action: {}) {
                        Text("Login")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 1.0, green: 0.627, blue: 0.004))
                    .padding(.horizontal)
                    
                    // Register prompt
                    HStack {
                        Text("Don't have an account?")
                            .font(.system(size: 12))
                        
                        Button("Register") {}
                            .font(.system(size: 12, weight: .medium))
                            .tint(Color(red: 1.0, green: 0.627, blue: 0.004))
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(Color(red: 1.0, green: 0.89, blue: 0.78))
                .cornerRadius(12)
                .frame(width: 300)
            }
        }
    }
}

#Preview {
    Login()
}
