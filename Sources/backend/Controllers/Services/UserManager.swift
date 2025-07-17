// Created by Sean L. on Jul. 17.
// Last Updated by Sean L. on Jul. 17.
// 
// Tea Charlie - Backend
// Sources/backend/Controllers/Services/User.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Foundation
import Vapor
import Fluent

class UserCredentialsManager {
    static func authenticateUser(email: String, password: String, db: any Database) async throws -> User? {
        guard let user = try await User.query(on: db)
            .with(\.$userData)
            .filter(\.$email == email)
            .first() else { return nil }
        
        let verified = try EncryptionManager.verifyPassword(password, hash: user.passHash)
        return verified ? user : nil
    }
    static func verifySessionToken(_ id: String, db: any Database) async throws -> User? {
        // Fetch the token with its user
        guard let token = try await Token.query(on: db)
            .filter(\.$token == id)
            .with(\.$user)
            .first()
        else {
            return nil
        }

        // Load the user's userData manually (if needed)
        try await token.user.$userData.load(on: db)

        return token.user
    }
}
