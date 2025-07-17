// Created by Sean L. on Jul. 17.
// Last Updated by Sean L. on Jul. 17.
// 
// Tea Charlie - Backend
// Sources/backend/Controllers/Services/Hasher.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Vapor

class EncryptionManager {
    static func hashPassword(_ pass: String) throws -> String {
        return try Bcrypt.hash(pass)
    }

    static func verifyPassword(_ plaintext: String, hash: String) throws -> Bool {
        return try Bcrypt.verify(plaintext, created: hash)
    }
}
