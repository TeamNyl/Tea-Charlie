// Created by Sean L. on Aug. 7.
// Last Updated by Sean L. on Aug. 7.
// 
// Tea Charlie - Backend
// Sources/backend/Models/Rooms.swift
// 
// Makabaka1880, 2025. All rights reserved.


import Vapor
import Fluent

final class Room: Model, Content {
    static let schema = "rooms"

    // Fields
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Parent(key: "creator_id")
    var creator: User

    @Field(key: "created_at")
    var createdAt: Date

    @Enum(key: "room_status")
    var roomStatus: UserStatus

    // Initializer
    init() {}

    init(id: UUID? = nil, name: String, creatorId: UUID, createdAt: Date = Date(), roomStatus: UserStatus = .ok) {
        self.id = id
        self.name = name
        self.$creator.id = creatorId
        self.createdAt = createdAt
        self.roomStatus = roomStatus
    }
}
