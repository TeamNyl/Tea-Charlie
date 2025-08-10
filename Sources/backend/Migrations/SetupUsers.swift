// Created by Sean L. on Aug. 7.
// Last Updated by Sean L. on Aug. 7.
// 
// Tea Charlie - Backend
// Sources/backend/Migrations/SetupUsers.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Vapor
import Fluent

struct CreateUser: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        return database.enum("user_role")
            .case("user")
            .case("admin")
            .case("moderator")
            .create()
            .flatMap { userRole in
                return database.enum("user_status")
                    .case("ok")
                    .case("banned")
                    .case("down")
                    .create()
                    .flatMap { userStatus in
                        return database.schema("users")
                            .id()
                            .field("email", .string, .required)
                            .field("username", .string, .required)
                            .field("pass_hash", .string, .required)
                            .field("user_role", userRole, .required)
                            .field("user_status", userStatus, .required)
                            .field("created_at", .datetime, .required)
                            .field("avatar_url", .string)
                            .unique(on: "email")
                            .unique(on: "username")
                            .create()
                    }
            }
    }

    func revert(on database: any Database) -> EventLoopFuture<Void> {
        return database.schema("users").delete().flatMap {
            database.enum("user_status").delete().flatMap {
                database.enum("user_role").delete()
            }
        }
    }
}
