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
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        return database.schema("user_data")
            .id()
            .field("user_id", .uuid, .required)
            .field("achievements", .array(of: .json), .required, .sql(.default("'{}'::jsonb[]")))
            .field("coins", .int, .required, .sql(.default(400)))
            .field("map_x", .float, .required, .sql(.default(0)))
            .field("map_y", .float, .required, .sql(.default(0)))
            .field("created_teas", .array(of: .json), .required, .sql(.default("'{}'::jsonb[]")))
            .foreignKey("user_id", references: "users", "id", onDelete: .cascade)
            .create()
    }

    func revert(on database: any Database) -> EventLoopFuture<Void> {
        return database.schema("user_data").delete()
    }
}
