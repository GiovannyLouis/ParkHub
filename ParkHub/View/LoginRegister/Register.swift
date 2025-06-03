//
//  Register.swift
//  ParkHub
//
//  Created by student on 03/06/25.
//

import SwiftUI

struct Register: View {
    @State private var username: String = ""
    @State private var password: String = ""
    
    var body: some View {
        ZStack {
            // Orange background (#FFA001)
            Color(red: 1.0, green: 0.627, blue: 0.004)
                .ignoresSafeArea()
            
            VStack {
                // Logo
                LogoBig()
                    .padding(.bottom, 24)
                
                // Form container (light orange #FFE3C7)
                VStack(spacing: 12) {
                    // Username field
                    TextField("Username", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .background(Color.white)
                        .cornerRadius(4)
                        .padding(.horizontal)
                    
                    // Password field
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .background(Color.white)
                        .cornerRadius(4)
                        .padding(.horizontal)
                    
                    Spacer()
                        .frame(height: 24)
                    
                    // Register button
                    Button(action: {
                        // Register action
                    }) {
                        Text("Register")
                            .frame(maxWidth: .infinity)
                            .font(.system(size: 18))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 1.0, green: 0.627, blue: 0.004))
                    .padding(.horizontal)
                    
                    // Login prompt
                    HStack {
                        Text("Already have an account?")
                            .font(.system(size: 12))
                        
                        Button("Login") {
                            // Navigate to login
                        }
                        .font(.system(size: 12, weight: .medium))
                        .tint(Color(red: 1.0, green: 0.627, blue: 0.004))
                        .padding(.leading, 4)
                    }
                }
                .padding()
                .background(Color(red: 1.0, green: 0.89, blue: 0.78))
                .cornerRadius(12)
                .frame(width: 300)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    Register()
}
