// AuthViewModel.swift
// ParkHub
// Created by student on 03/06/25.

import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var inputUser: User = User()
    @Published var firebaseAuthUser: FirebaseAuth.User?
    @Published var isSignedIn: Bool = false
    @Published var authError: String?
    @Published var isLoading: Bool = false

    var authStateHandler: AuthStateDidChangeListenerHandle?
    var authRepository = AuthRepository()

    init() {
        listenToAuthState()
    }

    deinit {
        if let handle = authStateHandler {
            authRepository.removeAuthStateDidChangeListener(handle)
        }
    }

    func listenToAuthState() {
        authStateHandler = authRepository.addAuthStateDidChangeListener { [weak self] user in
            guard let self = self else { return }

            self.firebaseAuthUser = user
            self.isSignedIn = (user != nil)

            if self.isSignedIn {
                print("AuthViewModel: User is signed in - UID: \(user?.uid ?? "N/A"), Email: \(user?.email ?? "N/A"), DisplayName: \(user?.displayName ?? "N/A")")
            } else {
                print("AuthViewModel: User is signed out.")
            }
        }
    }

    func signIn() async {
        guard !inputUser.email.isEmpty, !inputUser.password.isEmpty else {
            authError = "Email and password cannot be empty."
            return
        }

        isLoading = true
        authError = nil

        do {
            let user = try await authRepository.signIn(email: inputUser.email, password: inputUser.password)
            print("AuthViewModel: Successfully signed in user with email: \(user.email ?? "N/A")")
        } catch {
            print("AuthViewModel: Sign In Error - \(error.localizedDescription)")
            authError = authRepository.mapFirebaseError(error)
        }

        isLoading = false
    }

    func signUp() async {
        guard !inputUser.username.isEmpty, !inputUser.email.isEmpty, !inputUser.password.isEmpty else {
            authError = "Username, email, and password cannot be empty."
            return
        }

        isLoading = true
        authError = nil

        do {
            let user = try await authRepository.signUp(
                username: inputUser.username,
                email: inputUser.email,
                password: inputUser.password
            )
            print("AuthViewModel: Successfully signed up user - \(user.uid) with email: \(user.email ?? "N/A") and username: \(user.displayName ?? "N/A")")
        } catch {
            print("AuthViewModel: Sign Up Error - \(error.localizedDescription)")
            authError = authRepository.mapFirebaseError(error)
        }

        isLoading = false
    }

    func signOut() {
        do {
            try authRepository.signOut()
            clearInputFields()
        } catch {
            print("AuthViewModel: Sign Out Error - \(error.localizedDescription)")
            authError = "Failed to sign out: \(error.localizedDescription)"
        }
    }

    func clearInputFields() {
        inputUser = User()
    }

    func clearAuthError() {
        authError = nil
    }
}
