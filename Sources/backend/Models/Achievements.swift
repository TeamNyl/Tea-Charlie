// Created by Sean L. on Jul. 19.
// Last Updated by Sean L. on Jul. 19.
// 
// Tea Charlie - Backend
// Sources/backend/Models/Achievements.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Vapor

struct Achievement: Content {
    var name: String
    var time: Date
    var coords_x: Int
    var coords_y: Int
}

import Vapor

struct InventoryItem: Content {
    var itemName: String
    var description: String
    var iconURL: String?

    var maxStackSize: Int

    var itemType: ItemType

    var value: Int
    var isUsable: Bool
    var isDroppable: Bool
}

enum ItemType: String, Content, Codable {
    case weapon = "Weapon"
    case armor = "Armor"
    case consumable = "Consumable"
    case material = "Material"
    case quest = "Quest"
    case misc = "Misc"
}
