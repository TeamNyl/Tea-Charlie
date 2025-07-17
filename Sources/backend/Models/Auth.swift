// Created by Sean L. on Jul. 17.
// Last Updated by Sean L. on Jul. 17.
// 
// Tea Charlie - Backend
// Sources/backend/Models/Auth.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Fluent
import Vapor

final class Token: Model, @unchecked Sendable {
    static let schema = "tokens"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "token")
    var token: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(id: UUID? = nil, userID: UUID, token: String) {
        self.id = id
        self.$user.id = userID
        self.token = token
    }
}
