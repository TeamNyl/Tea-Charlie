// Created by Sean L. on Aug. 7.
// Last Updated by Sean L. on Aug. 7.
// 
// Tea Charlie - Backend
// Sources/backend/Migrations/SetupUserStatus
// 
// Makabaka1880, 2025. All rights reserved.

import Vapor
import Fluent

struct CreateUserStatus: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        return database.schema("user_status")
            .id()
            .field("room_id", .uuid, .required)
            .field("user_id", .uuid, .required)
            .field("position_x", .int, .required, .sql(.default(0)))
            .field("position_y", .int, .required, .sql(.default(0)))
            .field("coins", .int, .required, .sql(.default(300)))
            .field("inventory", .array(of: .string), .required, .sql(.default("'{}'::text[]")))
            .field("receipts", .array(of: .string), .required, .sql(.default("'{}'::text[]")))
            .unique(on: "room_id", "user_id") // Make sure each (room_id, user_id) pair is unique
            .foreignKey("room_id", references: "rooms", "id", onDelete: .cascade)
            .foreignKey("user_id", references: "users", "id", onDelete: .cascade)
            .create()
    }

    func revert(on database: any Database) -> EventLoopFuture<Void> {
        return database.schema("user_status").delete()
    }
}