// Register.swift
// ParkHub
// Created by student on 03/06/25.

import SwiftUI

struct RegisterView: View { // Renamed to RegisterView for clarity
    @EnvironmentObject var authVM: AuthViewModel
    @Binding var showRegisterSheet: Bool // To switch back to the Login screen

    var body: some View {
        ZStack {
            Color(red: 1.0, green: 0.627, blue: 0.004) // Orange background (#FFA001)
                .ignoresSafeArea()
            
            VStack {
                LogoBig() // Assuming LogoBig() is defined
                    .padding(.bottom, 24)
                
                VStack(spacing: 12) {
                    // Username field
                    TextField("Username", text: $authVM.inputUser.username)
                        .autocapitalization(.words)
                        .textFieldStyle(.roundedBorder)
                        .background(Color.white)
                        .cornerRadius(4)
                        .padding(.horizontal)

                    // Email field
                    TextField("Email", text: $authVM.inputUser.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textFieldStyle(.roundedBorder)
                        .background(Color.white)
                        .cornerRadius(4)
                        .padding(.horizontal)
                    
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
                    
                    Spacer().frame(height: 12) // Adjusted spacer
                    
                    Button(action: {
                        Task {
                            await authVM.signUp()
                            if authVM.isSignedIn {
                                // The sheet should dismiss automatically
                                // authVM.clearInputFields()
                            }
                        }
                    }) {
                        if authVM.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity, minHeight: 22)
                        } else {
                            Text("Register")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 1.0, green: 0.627, blue: 0.004)) // Orange button
                    .foregroundColor(.white) // Ensure text is visible
                    .padding(.horizontal)
                    .disabled(authVM.isLoading)
                    
                    HStack {
                        Text("Already have an account?")
                            .font(.system(size: 12))
                        
                        Button("Login") {
                            authVM.clearAuthError() // Clear error when switching
                            // authVM.clearInputFields() // Keep inputs
                            showRegisterSheet = false // Signal parent to show Login view
                        }
                        .font(.system(size: 12, weight: .medium))
                        .tint(Color(red: 1.0, green: 0.627, blue: 0.004))
                        .padding(.leading, 4)
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(Color(red: 1.0, green: 0.89, blue: 0.78)) // Light orange
                .cornerRadius(12)
                .frame(width: 300)
            }
        }
        .navigationBarHidden(true) // As per your original
        .onAppear {
            authVM.clearAuthError()
        }
    }
}

#Preview {
    RegisterView(showRegisterSheet: .constant(true))
        .environmentObject(AuthViewModel())
}
