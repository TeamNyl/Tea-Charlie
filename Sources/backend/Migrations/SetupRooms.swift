// Created by Sean L. on Aug. 7.
// Last Updated by Sean L. on Aug. 7.
// 
// Tea Charlie - Backend
// Sources/backend/Migrations/SetupRooms.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Vapor
import Fluent

struct CreateRoom: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        return database.enum("room_status")
            .case("active")
            .case("inactive")
            .case("archived")
            .create()
            .flatMap { roomStatus in
                return database.schema("rooms")
                    .id()
                    .field("name", .string, .required)
                    .field("creator_id", .uuid, .required)
                    .field("created_at", .datetime, .required)
                    .field("room_status", roomStatus, .required)
                    .unique(on: "name") // Ensure room names are unique
                    .foreignKey("creator_id", references: "users", "id", onDelete: .cascade)
                    .create()
            }
    }

    func revert(on database: any Database) -> EventLoopFuture<Void> {
        return database.schema("rooms").delete().flatMap {
            database.enum("room_status").delete()
        }
    }
}
