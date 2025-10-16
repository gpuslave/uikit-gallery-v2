//
//  URLHelper.swift
//  gallerry
//
//  Created by Aleksei Nemtsev on 16.10.2025.
//

import Foundation

/// Helper for manipulating VK image URLs with smart size selection
struct URLHelper {
    
    /// Finds a thumbnail size close to target width from available sizes
    /// - Parameters:
    ///   - vkURL: Original VK URL with 'as=' parameter listing sizes
    ///   - targetWidth: Desired width (default 240 for thumbnails)
    /// - Returns: Modified URL requesting appropriate thumbnail size
    static func getThumbnailURL(from vkURL: String, targetWidth: Int = 240) -> String {
        guard let urlComponents = URLComponents(string: vkURL),
              let queryItems = urlComponents.queryItems else {
            return vkURL
        }
        
        // Find the 'as=' parameter which lists available sizes
        guard let asItem = queryItems.first(where: { $0.name == "as" }),
              let sizesString = asItem.value else {
            return vkURL
        }
        
        // Parse available sizes: "32x21,48x32,72x48,108x72,160x107,240x160,..."
        let sizes = sizesString.split(separator: ",").compactMap { sizeStr -> (width: Int, height: Int)? in
            let parts = sizeStr.split(separator: "x")
            guard parts.count == 2,
                  let width = Int(parts[0]),
                  let height = Int(parts[1]) else {
                return nil
            }
            return (width, height)
        }
        
        // Find the size closest to target width
        let bestSize = findClosestSize(in: sizes, targetWidth: targetWidth)
        
        guard let selectedSize = bestSize else {
            print("[URLHelper] No suitable size found, using original URL")
            return vkURL
        }
        
        // Build the thumbnail size string (e.g., "240x160")
        let thumbnailSizeString = "\(selectedSize.width)x\(selectedSize.height)"
        
        print("[URLHelper] Selected thumbnail size: \(thumbnailSizeString) from \(sizes.count) available sizes")
        
        // Modify the 'cs=' parameter to request this size
        return modifyCSParameter(in: vkURL, to: thumbnailSizeString)
    }
    
    /// Finds the size closest to target width (preferring slightly larger)
    private static func findClosestSize(in sizes: [(width: Int, height: Int)], targetWidth: Int) -> (width: Int, height: Int)? {
        guard !sizes.isEmpty else { return nil }
        
        // Sort by width
        let sortedSizes = sizes.sorted { $0.width < $1.width }
        
        // Find first size >= targetWidth, or use largest if all are smaller
        return sortedSizes.first(where: { $0.width >= targetWidth }) ?? sortedSizes.last
    }
    
    /// Modifies the 'cs=' parameter in VK URL
    private static func modifyCSParameter(in urlString: String, to newValue: String) -> String {
        guard var urlComponents = URLComponents(string: urlString) else {
            return urlString
        }
        
        // Modify the 'cs' (current size) parameter
        if let queryItems = urlComponents.queryItems {
            urlComponents.queryItems = queryItems.map { item in
                if item.name == "cs" {
                    return URLQueryItem(name: "cs", value: newValue)
                }
                return item
            }
        }
        
        return urlComponents.url?.absoluteString ?? urlString
    }
    
    /// Gets the largest available size from VK URL for detail view
    /// - Parameter vkURL: VK URL with 'as=' parameter
    /// - Returns: Size string (e.g., "2560x1707") or original URL if parsing fails
    static func getFullSizeURL(from vkURL: String) -> String {
        guard let urlComponents = URLComponents(string: vkURL),
              let queryItems = urlComponents.queryItems else {
            return vkURL
        }
        
        // Find 'as=' parameter
        guard let asItem = queryItems.first(where: { $0.name == "as" }),
              let sizesString = asItem.value else {
            return vkURL
        }
        
        // Get last (largest) size
        let sizes = sizesString.split(separator: ",")
        guard let largestSize = sizes.last else {
            return vkURL
        }
        
        print("🔍 [URLHelper] Selected full size: \(largestSize)")
        
        // Modify 'cs=' to largest size
        return modifyCSParameter(in: vkURL, to: String(largestSize))
    }
}

