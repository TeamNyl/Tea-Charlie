// Created by Sean L. on Aug. 7.
// Last Updated by Sean L. on Aug. 7.
// 
// Tea Charlie - Backend
// Sources/backend/Migrations/SetupLoginSession.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Vapor
import Fluent

struct CreateLoginSession: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        return database.schema("login_sessions")
            .id()
            .field("user_id", .uuid, .required)
            .field("session_key", .uuid, .required)
            .field("created_at", .datetime, .required)
            .field("user_agent", .string)
            .field("ip_address", .string)
            .unique(on: "session_key")
            .foreignKey("user_id", references: "users", "id", onDelete: .cascade)
            .create()
    }

    func revert(on database: any Database) -> EventLoopFuture<Void> {
        return database.schema("login_sessions").delete()
    }
}
