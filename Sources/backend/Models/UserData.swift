// Created by Sean L. on Aug. 7.
// Last Updated by Sean L. on Aug. 7.
// 
// Tea Charlie - Backend
// Sources/backend/Models/UserData.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Vapor
import Fluent

struct Achievement: Content {
    let name: String
    let achievedAt: Date
}


final class UserData: Model, Content {
    static let schema = "user_data"

    // Fields
    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "achievements")
    var achievements: [Achievement]

    // Initializer
    init() {}

    init(id: UUID? = nil, userId: UUID, achievements: [Achievement] = []) {
        self.id = id
        self.$user.id = userId
        self.achievements = achievements
    }
}
