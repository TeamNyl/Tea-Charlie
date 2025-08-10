// Created by Sean L. on Aug. 7.
// Last Updated by Sean L. on Aug. 7.
// 
// Tea Charlie - Backend
// Sources/backend/Models/Types.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Vapor
import Fluent

enum UserRole: String, Codable {
    case user
    case admin
    case moderator
}

enum UserStatus: String, Codable {
    case ok
    case banned
    case down
}

enum RoomStatus: String, Codable {
    case active
    case inactive
    case archived
}
