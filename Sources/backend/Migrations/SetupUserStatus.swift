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
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("user_status")
            .id()
            .field("room_id", .uuid, .required)
            .field("user_id", .uuid, .required)
            .field("position_x", .int, .required, .default(0))
            .field("position_y", .int, .required, .default(0))
            .field("coins", .int, .required, .default(300))
            .field("inventory", .jsonb, .required, .default([]))
            .field("receipts", .jsonb, .required, .default([]))
            .unique(on: "room_id", "user_id") // Make sure each (room_id, user_id) pair is unique
            .foreignKey("room_id", references: "rooms", "id", onDelete: .cascade)
            .foreignKey("user_id", references: "users", "id", onDelete: .cascade)
            .constraint("inventory_is_array", .check("jsonb_typeof(inventory) = 'array'"))
            .constraint("receipts_is_array", .check("jsonb_typeof(receipts) = 'array'"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("user_status").delete()
    }
}
