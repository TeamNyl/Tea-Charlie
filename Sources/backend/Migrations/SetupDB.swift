// Created by Sean L. on Jul. 17.
// Last Updated by Sean L. on Jul. 17.
// 
// Tea Charlie - Backend
// Sources/backend/Migrations/SetupDB.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Fluent
import Vapor

struct CreateUsers: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.enum("tea_step_kind")
            .case("PICK")
            .case("WITHER")
            .case("KILL_GREEN")
            .case("SHAKE_GREEN")
            .case("ROLL")
            .case("DRY")
            .case("OXIDIZE")
            .case("PILE_FERMENT")
            .case("SUN_DRY")
            .create()
            .flatMap { _ in
                database.schema("users")
                    .id()
                    .field("email", .string, .required)
                    .unique(on: "email")
                    .field("pass_hash", .string, .required)
                    .field("username", .string)
                    .field("created_at", .datetime)
                    .create()
            }
    }

    func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("users").delete().flatMap {
            database.enum("tea_step_kind").delete()
        }
    }
}

struct CreateTokens: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("tokens")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("token", .string, .required)
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("tokens").delete()
    }
}

struct CreateUserData: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("user_data")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))

            .field("coins", .int, .required, .sql(.default(400)))

            .field("map_x", .float, .required, .sql(.default(0)))
            .field("map_y", .float, .required, .sql(.default(0)))

            .field("created_teas", .array(of: .json), .required, .sql(.default("'{}'::jsonb[]")))
            .field("achievements", .array(of: .string), .required, .sql(.default("'{}'")))

            .create()
    }

    func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("user_data").delete()
    }
}

