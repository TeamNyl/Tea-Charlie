// Created by Sean L. on Jul. 17.
// Last Updated by Sean L. on Jul. 17.
//
// Tea Charlie - Backend
// Sources/backend/DTOs/UserPublicDTO.swift
//
// Makabaka1880, 2025. All rights reserved.

import Vapor
import Fluent

// This DTO (Data Transfer Object) represents the public-facing
// data for a user, excluding sensitive information like the password hash.
struct UserPublicDTO: Content {
    let id: UUID
    let email: String
    let username: String
    let userRole: UserRole
    let userStatus: UserStatus
    let createdAt: Date
    let avatarUrl: String?

    // Initializer to create a UserPublicDTO from a User model.
    // This ensures only the safe and necessary data is exposed.
    init(user: User) throws {
        // We use try user.requireID() because a User model that's
        // being sent to the client should always have an ID after being saved.
        self.id = try user.requireID()
        self.email = user.email
        self.username = user.username
        self.userRole = user.userRole
        self.userStatus = user.userStatus
        self.createdAt = user.createdAt
        self.avatarUrl = user.avatarUrl
    }
}