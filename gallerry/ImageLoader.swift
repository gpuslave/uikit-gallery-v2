//
//  ImageLoader.swift
//  gallerry
//
//  Created by Aleksei Nemtsev on 16.10.2025.
//

import UIKit

/// Singleton class for downloading and caching images from URLs
/// This handles all network requests and memory management for images
class ImageLoader {
    
    // MARK: - Singleton Instance
    
    /// Shared instance - use ImageLoader.shared throughout your app
    static let shared = ImageLoader()
    
    // MARK: - Properties
    
    /// In-memory cache for storing downloaded images
    /// NSCache automatically removes items when memory is low
    private let imageCache = NSCache<NSString, UIImage>()
    
    /// URLSession for making network requests
    /// Configured with caching enabled for better performance
    private let session: URLSession
    
    /// Dictionary to track ongoing download tasks
    /// Key: URL string, Value: The download task
    /// Used to prevent downloading the same image twice
    private var runningTasks: [String: URLSessionDataTask] = [:]
    
    // MARK: - Initialization
    
    /// Private initializer (singleton pattern - only one instance allowed)
    private init() {
        // Configure URLSession with disk and memory caching
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,   // 50 MB memory cache
            diskCapacity: 100 * 1024 * 1024     // 100 MB disk cache
        )
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        
        self.session = URLSession(configuration: configuration)
        
        // Configure in-memory image cache limits
        imageCache.countLimit = 100                  // Max 100 images in memory
        imageCache.totalCostLimit = 50 * 1024 * 1024  // Max 50 MB in memory
    }
    
    // MARK: - Public Methods
    
    /// Loads an image from a URL asynchronously
    /// - Parameters:
    ///   - urlString: The URL string of the image (VK URL with multiple sizes)
    ///   - completion: Completion handler called on main thread with downloaded image
    /// - Returns: The data task (can be used to cancel the download)
    @discardableResult
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) -> URLSessionDataTask? {
        
        // STEP 1: Check if image is already in memory cache
        let cacheKey = urlString as NSString
        if let cachedImage = imageCache.object(forKey: cacheKey) {
            print("✅ [ImageLoader] Using cached image for: \(urlString.prefix(50))...")
            completion(cachedImage)
            return nil
        }
        
        // STEP 2: Check if we're already downloading this image
        if let existingTask = runningTasks[urlString] {
            print("⏳ [ImageLoader] Already downloading: \(urlString.prefix(50))...")
            return existingTask
        }
        
        // STEP 3: Validate URL
        guard let url = URL(string: urlString) else {
            print("❌ [ImageLoader] Invalid URL: \(urlString)")
            completion(nil)
            return nil
        }
        
        print("⬇️ [ImageLoader] Starting download: \(urlString.prefix(50))...")
        
        // STEP 4: Create and start download task
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            
            // Remove task from running tasks
            self?.runningTasks.removeValue(forKey: urlString)
            
            // STEP 5: Handle errors
            if let error = error {
                print("❌ [ImageLoader] Download failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // STEP 6: Validate response and data
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("❌ [ImageLoader] Invalid response")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("❌ [ImageLoader] Could not create image from data")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // STEP 7: Cache the image
            self?.imageCache.setObject(image, forKey: cacheKey)
            print("✅ [ImageLoader] Image downloaded and cached: \(urlString.prefix(50))...")
            
            // STEP 8: Call completion on main thread
            DispatchQueue.main.async {
                completion(image)
            }
        }
        
        // Store task in running tasks dictionary
        runningTasks[urlString] = task
        
        // Start the download
        task.resume()
        
        return task
    }
    
    /// Cancels a specific image download
    /// - Parameter urlString: The URL of the image to cancel
    func cancelLoad(for urlString: String) {
        runningTasks[urlString]?.cancel()
        runningTasks.removeValue(forKey: urlString)
    }
    
    /// Cancels all pending downloads
    func cancelAll() {
        runningTasks.values.forEach { $0.cancel() }
        runningTasks.removeAll()
    }
    
    /// Clears the in-memory image cache
    func clearCache() {
        imageCache.removeAllObjects()
        print("🗑️ [ImageLoader] Cache cleared")
    }
}

// MARK: - UIImageView Extension

/// Convenient extension for loading images directly into UIImageView
extension UIImageView {
    
    /// Loads and displays an image from a URL
    /// - Parameters:
    ///   - urlString: The URL string of the image
    ///   - placeholder: Optional placeholder image to show while loading
    func loadImage(from urlString: String, placeholder: UIImage? = nil) {
        // Show placeholder immediately
        self.image = placeholder
        
        // Load image asynchronously
        ImageLoader.shared.loadImage(from: urlString) { [weak self] image in
            // Update image view on main thread
            self?.image = image ?? placeholder
        }
    }
}

