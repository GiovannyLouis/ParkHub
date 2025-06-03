// Login.swift
// ParkHub
// Created by student on 03/06/25.

import SwiftUI

struct LoginView: View { // Renamed to LoginView for clarity if needed
    @EnvironmentObject var authVM: AuthViewModel
    @Binding var showRegisterSheet: Bool // To switch to the Register screen
    
    var body: some View {
        ZStack {
            Color(red: 1.0, green: 0.627, blue: 0.004) // #FFA001
                .ignoresSafeArea()
            
            VStack {
                LogoBig() // Assuming LogoBig() is defined
                    .padding(.bottom, 24)
                
                VStack {
                    // Email field
                    TextField("Email", text: $authVM.inputUser.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textFieldStyle(.roundedBorder)
                        .background(Color.white)
                        .cornerRadius(4)
                        .padding(.horizontal)
                    
                    Spacer().frame(height: 12)
                    
                    // Password field
                    SecureField("Password", text: $authVM.inputUser.password)
                        .textFieldStyle(.roundedBorder)
                        .background(Color.white)
                        .cornerRadius(4)
                        .padding(.horizontal)
                    
                    // Display Authentication Error
                    if let error = authVM.authError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 8)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Spacer().frame(height: 24)
                    
                    Button(action: {
                        Task {
                            await authVM.signIn()
                            if authVM.isSignedIn {
                                // The sheet should dismiss automatically if isSignedIn changes
                                // and the parent view handles it.
                                // authVM.clearInputFields() // ViewModel's listener or success block can handle this
                            }
                        }
                    }) {
                        if authVM.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity, minHeight: 22)
                        } else {
                            Text("Login")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 1.0, green: 0.627, blue: 0.004)) // Orange button
                    .foregroundColor(.white) // Ensure text is visible
                    .padding(.horizontal)
                    .disabled(authVM.isLoading)
                    
                    HStack {
                        Text("Don't have an account?")
                            .font(.system(size: 12))
                        
                        Button("Register") {
                            authVM.clearAuthError() // Clear error when switching
                            // authVM.clearInputFields() // Keep inputs if user made a mistake and wants to switch then switch back
                            showRegisterSheet = true // Signal parent to show Register view
                        }
                        .font(.system(size: 12, weight: .medium))
                        .tint(Color(red: 1.0, green: 0.627, blue: 0.004))
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(Color(red: 1.0, green: 0.89, blue: 0.78)) // Light orange
                .cornerRadius(12)
                .frame(width: 300)
            }
        }
        .onAppear {
            authVM.clearAuthError() // Clear previous errors when view appears
            // Don't clear input fields on appear, user might be coming back to fix a typo
        }
    }
}


#Preview {
    LoginView(showRegisterSheet: .constant(false))
        .environmentObject(AuthViewModel())
}
