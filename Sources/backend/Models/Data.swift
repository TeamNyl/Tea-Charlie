// Created by Sean L. on Jul. 17.
// Last Updated by Sean L. on Jul. 17.
// 
// Tea Charlie - Backend
// Sources/backend/Models/Data.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Vapor
import Fluent

final class UserData: Model, @unchecked Sendable {
    static let schema = "user_data"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "coins")
    var coins: Int

    @Field(key: "map_x")
    var mapX: Float

    @Field(key: "map_y")
    var mapY: Float

    @Field(key: "created_teas")
    var createdTeas: [TeaEntry]

    @Field(key: "achievements")
    var achievements: [Achievement]

    @Field(key: "inventory")
    var inventory: [InventoryItem]

    init() {}

    init(id: UUID? = nil, userID: UUID, coins: Int = 400, mapX: Float = 0, mapY: Float = 0, createdTeas: [TeaEntry] = [], achievements: [Achievement] = [], inventory: [InventoryItem] = []) {
        self.id = id
        self.$user.id = userID
        self.coins = coins
        self.mapX = mapX
        self.mapY = mapY
        self.createdTeas = createdTeas
        self.achievements = achievements
        self.inventory = inventory
    }
}