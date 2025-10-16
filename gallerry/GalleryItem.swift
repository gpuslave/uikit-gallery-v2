//
//  GalleryItem.swift
//  gallerry
//
//  Created by Aleksei Nemtsev on 16.10.2025.
//

import Foundation

/// Model representing a single gallery item
struct GalleryItem {
    
    // MARK: - Properties
    
    /// Name of the image asset
    let imageName: String
    
    /// Title of the gallery item
    let title: String
    
    /// Description of the gallery item
    let description: String
    
    /// Optional date when photo was taken
    let date: Date?
    
    // MARK: - Initializer
    
    /// Creates a new gallery item
    /// - Parameters:
    ///   - imageName: Name of the image in assets
    ///   - title: Display title
    ///   - description: Display description
    ///   - date: Optional date
    init(imageName: String, title: String, description: String, date: Date? = nil) {
        self.imageName = imageName
        self.title = title
        self.description = description
        self.date = date
    }
}
