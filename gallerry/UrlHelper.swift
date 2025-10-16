//
//  URLHelper.swift
//  gallerry
//
//  Created by Aleksei Nemtsev on 16.10.2025.
//

import UIKit

/// Helper for handling image URLs from multiple sources (VK, direct URLs, etc.)
struct URLHelper {
    
    // MARK: - Public Interface
    
    /// Gets an appropriate thumbnail URL or marks for client-side resizing
    /// - Parameters:
    ///   - urlString: Original image URL (VK or direct)
    ///   - targetWidth: Desired thumbnail width (default 240)
    /// - Returns: Tuple with URL and whether client-side resize is needed
    static func getThumbnailStrategy(from urlString: String, targetWidth: Int = 240) -> (url: String, needsResize: Bool) {
        if isVKURL(urlString) {
            // VK URL: modify parameters to request smaller size
            let modifiedURL = getVKThumbnailURL(from: urlString, targetWidth: targetWidth)
            return (modifiedURL, false)
        } else {
            // Regular URL: will need client-side resizing
            return (urlString, true)
        }
    }
    
    /// Gets the full-size URL (largest available)
    /// - Parameter urlString: Original image URL
    /// - Returns: URL for full-size image
    static func getFullSizeURL(from urlString: String) -> String {
        if isVKURL(urlString) {
            return getVKFullSizeURL(from: urlString)
        } else {
            // Regular URLs are already full size
            return urlString
        }
    }
    
    // MARK: - VK URL Detection
    
    /// Checks if URL is a VK CDN URL
    private static func isVKURL(_ urlString: String) -> Bool {
        return urlString.contains("vkuserphoto.ru") && urlString.contains("as=")
    }
    
    // MARK: - VK-Specific Methods
    
    /// Finds a thumbnail size close to target width from VK available sizes
    private static func getVKThumbnailURL(from vkURL: String, targetWidth: Int) -> String {
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
            print("[URLHelper] No suitable VK size found, using original URL")
            return vkURL
        }
        
        // Build the thumbnail size string (e.g., "240x160")
        let thumbnailSizeString = "\(selectedSize.width)x\(selectedSize.height)"
        
        print("[URLHelper] VK thumbnail: \(thumbnailSizeString) from \(sizes.count) sizes")
        
        // Modify the 'cs=' parameter to request this size
        return modifyCSParameter(in: vkURL, to: thumbnailSizeString)
    }
    
    /// Gets the largest available size from VK URL
    private static func getVKFullSizeURL(from vkURL: String) -> String {
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
        
        print("[URLHelper] VK full size: \(largestSize)")
        
        // Modify 'cs=' to largest size
        return modifyCSParameter(in: vkURL, to: String(largestSize))
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
}

// MARK: - UIImage Extension for Client-Side Resizing

extension UIImage {
    
    /// Resizes image to fit within target width while preserving aspect ratio
    /// Uses Image I/O for efficient memory usage (Apple recommended approach)
    /// - Parameter targetWidth: Maximum width in pixels
    /// - Returns: Resized UIImage
    func resized(toWidth targetWidth: CGFloat) -> UIImage {
        let scale = targetWidth / self.size.width
        let targetHeight = self.size.height * scale
        let targetSize = CGSize(width: targetWidth, height: targetHeight)
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    /// Creates a thumbnail from image data efficiently using Image I/O
    /// Recommended by Apple for memory efficiency - avoids loading full image
    /// - Parameters:
    ///   - data: Image data
    ///   - maxPixelSize: Maximum dimension (width or height)
    /// - Returns: Thumbnail UIImage or nil
    static func thumbnail(from data: Data, maxPixelSize: Int) -> UIImage? {
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ]
        
        guard let thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
            return nil
        }
        
        return UIImage(cgImage: thumbnail)
    }
}
