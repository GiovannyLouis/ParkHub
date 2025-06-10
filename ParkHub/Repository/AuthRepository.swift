// AuthRepository.swift
// ParkHub
// Created by student on 03/06/25.

import Foundation
import FirebaseAuth

class AuthRepository {
    
    func signIn(email: String, password: String) async throws -> FirebaseAuth.User {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user
    }
    
    func signUp(username: String, email: String, password: String) async throws -> FirebaseAuth.User {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = username.trimmingCharacters(in: .whitespacesAndNewlines)
        try await changeRequest.commitChanges()
        return result.user
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func addAuthStateDidChangeListener(_ listener: @escaping (FirebaseAuth.User?) -> Void) -> AuthStateDidChangeListenerHandle {
        return Auth.auth().addStateDidChangeListener { _, user in
            listener(user)
        }
    }
    
    func removeAuthStateDidChangeListener(_ handle: AuthStateDidChangeListenerHandle) {
        Auth.auth().removeStateDidChangeListener(handle)
    }
    
    func mapFirebaseError(_ error: Error) -> String {
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

class MockAuthRepository: AuthRepository {
    var mockUser: FirebaseAuth.User?
    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "TestError", code: -1)

    override func signIn(email: String, password: String) async throws -> FirebaseAuth.User {
        if shouldThrowError {
            throw errorToThrow
        }
        return mockUser!
    }

    override func signUp(username: String, email: String, password: String) async throws -> FirebaseAuth.User {
        if shouldThrowError {
            throw errorToThrow
        }
        return mockUser!
    }

    override func signOut() throws {
        if shouldThrowError {
            throw errorToThrow
        }
    }

    override func addAuthStateDidChangeListener(_ listener: @escaping (FirebaseAuth.User?) -> Void) -> AuthStateDidChangeListenerHandle {
        listener(mockUser)
        return NSObject() // Dummy handle
    }

    override func removeAuthStateDidChangeListener(_ handle: AuthStateDidChangeListenerHandle) {
        // No-op for testing
    }
}
