// Created by Sean L. on Aug. 7.
// Last Updated by Sean L. on Aug. 7.
// 
// Tea Charlie - Backend
// Sources/backend/Models/LoginSession.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Vapor
import Fluent

final class LoginSession: Model, Content, @unchecked Sendable {
    static let schema = "login_sessions"

    // Fields
    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "session_key")
    var sessionKey: UUID

    @Field(key: "created_at")
    var createdAt: Date

    @Field(key: "user_agent")
    var userAgent: String?

    @Field(key: "ip_address")
    var ipAddress: String?

    // Initializer
    init() {}

    init(id: UUID? = nil, userId: UUID, sessionKey: UUID, createdAt: Date = Date(), userAgent: String? = nil, ipAddress: String? = nil) {
        self.id = id
        self.$user.id = userId
        self.sessionKey = sessionKey
        self.createdAt = createdAt
        self.userAgent = userAgent
        self.ipAddress = ipAddress
    }
}
