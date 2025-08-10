// Created by Sean L. on Aug. 7.
// Last Updated by Sean L. on Aug. 7.
// 
// Tea Charlie - Backend
// Sources/backend/Models/UserStatus.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Vapor
import Fluent

final class UserGameStatus: Model, Content, @unchecked Sendable {
    static let schema = "user_status"

    // Fields
    @ID(key: .id)
    var id: UUID?

    @Parent(key: "room_id")
    var room: Room

    @Parent(key: "user_id")
    var user: User

    @Field(key: "position_x")
    var positionX: Int

    @Field(key: "position_y")
    var positionY: Int

    @Field(key: "coins")
    var coins: Int

    @Field(key: "inventory")
    var inventory: [String]

    @Field(key: "receipts")
    var receipts: [String]

    // Initializer
    init() {}

    init(id: UUID? = nil, roomId: UUID, userId: UUID, positionX: Int = 0, positionY: Int = 0, coins: Int = 300, inventory: [String] = [], receipts: [String] = []) {
        self.id = id
        self.$room.id = roomId
        self.$user.id = userId
        self.positionX = positionX
        self.positionY = positionY
        self.coins = coins
        self.inventory = inventory
        self.receipts = receipts
    }
}
