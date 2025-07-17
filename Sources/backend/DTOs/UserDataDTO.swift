// Created by Sean L. on Jul. 17.
// Last Updated by Sean L. on Jul. 17.
// 
// Tea Charlie - Backend
// Sources/backend/DTOs/UserDataDTO
// 
// Makabaka1880, 2025. All rights reserved.

import Vapor

struct UserDataDTO: Content {
    let coins: Int
    let mapX: Float
    let mapY: Float
    let createdTeas: [TeaEntryDTO]
    let achievements: [String]
    
    init(from userData: UserData) {
        self.coins = userData.coins
        self.mapX = userData.mapX
        self.mapY = userData.mapY
        self.createdTeas = userData.createdTeas.map { TeaEntryDTO(from: $0) }
        self.achievements = userData.achievements
    }
}
