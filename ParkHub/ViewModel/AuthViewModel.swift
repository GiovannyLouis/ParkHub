// AuthViewModel.swift
// ParkHub
// Created by student on 03/06/25.

import Foundation
import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var inputUser: User = User()
    @Published var firebaseAuthUser: FirebaseAuth.User?
    @Published var isSignedIn: Bool = false
    @Published var authError: String?
    @Published var isLoading: Bool = false

    private var authStateHandler: AuthStateDidChangeListenerHandle?

    init() {
        listenToAuthState()
    }

    deinit {
        if let handle = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func listenToAuthState() {
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
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
            _ = try await Auth.auth().signIn(withEmail: inputUser.email, password: inputUser.password)
            print("AuthViewModel: Successfully signed in user with email: \(inputUser.email)")
        } catch {
            print("AuthViewModel: Sign In Error - \(error.localizedDescription)")
            authError = mapFirebaseError(error)
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
            let authResult = try await Auth.auth().createUser(withEmail: inputUser.email, password: inputUser.password)
            
            let changeRequest = authResult.user.createProfileChangeRequest()
            changeRequest.displayName = inputUser.username.trimmingCharacters(in: .whitespacesAndNewlines)
            try await changeRequest.commitChanges()
            
            print("AuthViewModel: Successfully signed up user - \(authResult.user.uid) with email: \(inputUser.email) and username: \(inputUser.username)")
            
        } catch {
            print("AuthViewModel: Sign Up Error - \(error.localizedDescription)")
            authError = mapFirebaseError(error)
        }
        isLoading = false
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
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

    private func mapFirebaseError(_ error: Error) -> String {
        if let errorCode = AuthErrorCode(rawValue: (error as NSError).code) {
            switch errorCode {
            case .invalidEmail:
                return "Invalid email format."
            case .emailAlreadyInUse:
                return "This email is already registered. Please login or use a different email."
            case .weakPassword:
                return "Password is too weak. It must be at least 6 characters."
            case .wrongPassword, .invalidCredential:
                return "Incorrect email or password. Please try again."
            case .userNotFound:
                return "No account found with this email. Please register."
            case .networkError:
                return "Network error. Please check your connection."
            case .userDisabled:
                return "This user account has been disabled."
            default:
                return "An authentication error occurred. Please try again."
            }
        }
        return error.localizedDescription
    }
}
