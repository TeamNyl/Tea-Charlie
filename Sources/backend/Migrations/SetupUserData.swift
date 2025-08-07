// Created by Sean L. on Aug. 7.
// Last Updated by Sean L. on Aug. 7.
// 
// Tea Charlie - Backend
// Sources/backend/Migrations/SetupUserData.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Vapor
import Fluent

struct CreateUserData: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("user_data")
            .id()
            .field("user_id", .uuid, .required)
            .field("achievements", .array(of: .json), .required, .default([]))
            .foreignKey("user_id", references: "users", "id", onDelete: .cascade)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("user_data").delete()
    }
}
