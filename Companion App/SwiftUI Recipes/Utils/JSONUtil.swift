//
//  JSONUtils.swift
//  SwiftUI Recipes
//
//  Created by Gordan Glavaš on 28.07.2021..
//

import Foundation

let jsonEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .formatted(dateFormat)
    return encoder
}()

let jsonDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(dateFormat)
    return decoder
}()

private let dateFormat: DateFormatter = {
    let df = DateFormatter()
    df.timeZone = TimeZone(abbreviation: "UTC")!
    df.dateFormat = DateUtil.ISO_UTC_DATE_FORMAT
    return df
}()
