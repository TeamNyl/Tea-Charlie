// Created by Sean L. on Jul. 17.
// Last Updated by Sean L. on Jul. 17.
// 
// Tea Charlie - Backend
// Sources/backend/Models/User.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Vapor
import Fluent
import Foundation

final class User: Model, @unchecked Sendable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "email")
    var email: String

    @Field(key: "pass_hash")
    var passHash: String

    @Field(key: "username")
    var username: String?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Children(for: \.$user)
    var tokens: [Token]

    @OptionalChild(for: \.$user)
    var userData: UserData?

    init() {}

    init(id: UUID? = nil, email: String, passHash: String, username: String? = nil) {
        self.id = id
        self.email = email
        self.passHash = passHash
        self.username = username
    }
}
