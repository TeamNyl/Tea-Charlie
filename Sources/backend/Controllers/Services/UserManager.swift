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
    static func authenticateUser(identifier: String, password: String, db: any Database) async throws -> User? {
            let userQuery = User.query(on: db)
                .with(\.$userData)
            
            if let uuid = UUID(uuidString: identifier) {
                userQuery.filter(\.$id == uuid)
            } else if identifier.contains("@") {
                userQuery.filter(\.$email == identifier)
            } else {
                userQuery.filter(\.$username == identifier)
            }
            
            guard let user = try await userQuery.first() else {
                return nil
            }

            let verified = try EncryptionManager.verifyPassword(password, hash: user.passHash)
            return verified ? user : nil
    }

    static func verifySessionToken(_ id: String, db: any Database) async throws -> User? {
        // Check for ttl
        let ttlTime = Double(SecretsManager.get(.loginTokenTTL)!)!
        let ttl = Date().addingTimeInterval(ttlTime * 24 * 60 * 60)
        print(ttl)
        // Fetch the token with its user
        guard let token = try await Token.query(on: db)
            .filter(\.$createdAt < ttl)
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
