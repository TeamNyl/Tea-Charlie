// Created by Sean L. on Jul. 17.
// Last Updated by Sean L. on Jul. 17.
// 
// Tea Charlie - Backend
// Sources/backend/Models/User.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Vapor
import Fluent

final class User: Model, Content {
    static let schema = "users"

    // Fields
    @ID(key: .id)
    var id: UUID?

    @Field(key: "email")
    var email: String

    @Field(key: "username")
    var username: String

    @Field(key: "pass_hash")
    var passHash: String

    @Enum(key: "user_role")
    var userRole: UserRole

    @Enum(key: "user_status")
    var userStatus: UserStatus

    @Field(key: "created_at")
    var createdAt: Date

    @Field(key: "avatar_url")
    var avatarUrl: String?

    init() {}

    init(id: UUID? = nil, email: String, username: String, passHash: String, userRole: UserRole, userStatus: UserStatus, createdAt: Date = Date(), avatarUrl: String? = nil) {
        self.id = id
        self.email = email
        self.username = username
        self.passHash = passHash
        self.userRole = userRole
        self.userStatus = userStatus
        self.createdAt = createdAt
        self.avatarUrl = avatarUrl
    }
}
