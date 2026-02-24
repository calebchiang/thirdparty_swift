//
//  User.swift
//  thirdparty_ios
//
//  Created by Caleb Chiang on 2026-02-23.
//

struct User: Decodable {
    let id: Int
    let name: String
    let email: String
    let credits: Int
    let isPremium: Bool
}
