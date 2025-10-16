//
//  GalleryTableViewController.swift
//  gallerry
//
//  Created by Aleksei Nemtsev on 16.10.2025.
//

import UIKit

/// Gallery table view controller with remote image loading from VK URLs
class SimpleGalleryTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    /// Array of image URLs from VK
    /// VK URLs contain multiple sizes (as= parameter) - iOS will request appropriate size
    private let imageURLs = [
        "https://sun9-4.vkuserphoto.ru/s/v1/if2/0ZZRC55m2Dx2PErnGDD8Dbsj2XdkhvutYLQbooufdkn4g-x7I1_nT-7GgjsD7tLnoWnDQlSzXiyVa4YQT2awXr1A.jpg?quality=95&as=32x21,48x32,72x48,108x72,160x107,240x160,360x240,480x320,540x360,640x427,720x480,1080x720,1280x853,1440x960,2560x1707&from=bu&cs=2560x0",
        "https://assets.science.nasa.gov/content/dam/science/missions/hubble/releases/2015/01/STScI-01EVT2MSVNZ3QDHZDHNZMQ3927.jpg",
        "https://sun9-61.vkuserphoto.ru/s/v1/ig2/3c2hvP6ty0P6CB7AsgxO6W6ELCthxTgxix-9jwVEjtvc57E2FsvCiqrR5mZEIvzYC_msax_xmGLqRUG6J2nXqig9.jpg?quality=95&as=32x57,48x85,72x128,108x192,160x284,240x427,360x640,480x853,540x960,640x1138,720x1280,1080x1920,1280x2276,1440x2560&from=bu&cs=1440x0",
        "https://assets.science.nasa.gov/content/dam/science/missions/hubble/releases/2015/01/STScI-01EVT2P98FBWHNC1NV0E8WM1FW.tif/jcr:content/renditions/17384x5558.jpg",
        "https://assets.science.nasa.gov/content/dam/science/missions/hubble/releases/2025/04/STScI-01JQCCTHRH3G9SQJ5QR84GEP0M.tif/jcr:content/renditions/Full%20Res%20(For%20Display).png"
    ]
    
    /// Array of titles corresponding to images
    private let imageTitles = [
        "Evrone",
        "Andromeda 1",
        "Landscape",
        "Andromeda 2",
        "Hubble Walk"
    ]
    
    /// Array of descriptions
    private let imageDescriptions = [
        "Corporate meeting of IT firm",
        "Compass and Scale Image of PHAT Mosaic",
        "Look at the river from a cliff during summer time",
        "Hubble traces densely packed stars extending from the innermost hub of the galaxy",
        "Mosaic of Hubble 35th Anniversary Targets"
    ]
    
    /// Cell reuse identifier - MUST match Storyboard identifier
    private let cellIdentifier = "SimpleImageCell"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set navigation title
        self.title = "Photo Gallery"
        
        // Configure table view
        tableView.rowHeight = 150
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGroupedBackground
        tableView.tableFooterView = UIView()
        
        // Add refresh control for cache clearing
        setupRefreshControl()
        
        print("[Gallery] View loaded with \(imageURLs.count) images")
    }
    
    // MARK: - Setup Methods
    
    /// Sets up pull-to-refresh control
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    /// Handles pull-to-refresh action
    @objc private func handleRefresh() {
        print("[Gallery] Refreshing - clearing cache")
        
        // Clear image cache
        ImageLoader.shared.clearCache()
        
        // Reload table
        tableView.reloadData()
        
        // End refreshing after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageURLs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ImageTableViewCell else {
            fatalError("Unable to dequeue ImageTableViewCell")
        }
        
        let originalURL = imageURLs[indexPath.row]
        
        // Get thumbnail strategy (VK URLs get modified, others need client-side resize)
        let strategy = URLHelper.getThumbnailStrategy(from: originalURL, targetWidth: 240)
        
        // Configure cell with appropriate strategy
        cell.configure(
            with: strategy.url,
            needsClientResize: strategy.needsResize,
            title: imageTitles[indexPath.row],
            description: imageDescriptions[indexPath.row]
        )
        
        return cell
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let originalURL = imageURLs[indexPath.row]
        
        // Get full-size URL (uses largest available size)
        let fullSizeURL = URLHelper.getFullSizeURL(from: originalURL)
        
        let title = imageTitles[indexPath.row]
        let description = imageDescriptions[indexPath.row]
        
        print("[Gallery] Selected: \(title)")
        
        // Create detail view with FULL SIZE URL
        let detailVC = ImageDetailViewController(
            imageURL: fullSizeURL,
            title: title,
            description: description
        )
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("[Gallery] Memory warning - clearing cache")
        ImageLoader.shared.clearCache()
    }
}
