//
//  GalleryTableViewController.swift
//  gallerry
//
//  Created by Aleksei Nemtsev on 16.10.2025.
//

import UIKit

/// Gallery table view controller using custom cells from storyboard
class SimpleGalleryTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    /// Array of image names
    private let imageNames = ["photo1", "photo2", "photo3", "photo4", "photo5"]
    
    /// Array of titles corresponding to images
    private let imageTitles = ["Sunset Beach", "Mountain Peak", "City Lights",
                               "Forest Path", "Ocean Waves"]
    
    private let imageDescriptions = [
        "Beautiful sunset at the beach with orange sky",
        "Snow-capped mountain peak at sunrise",
        "Urban cityscape at night with bright lights",
        "Peaceful walking path through green forest",
        "Crashing waves on rocky coastline"
    ]
    
    /// Cell reuse identifier - MUST match the identifier in Storyboard
    private let cellIdentifier = "SimpleImageCell"

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set navigation title
        self.title = "Simple Gallery"
        
        // DO NOT register - the cell is already in storyboard
        // tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        // Configure table view
        tableView.rowHeight = 150
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue YOUR CUSTOM cell from storyboard
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ImageTableViewCell else {
            fatalError("Unable to dequeue ImageTableViewCell")
        }
        
        // Configure the custom cell using your configure method
        cell.configure(
            with: imageNames[indexPath.row],
            title: imageTitles[indexPath.row],
            description: imageDescriptions[indexPath.row]
        )
        
        return cell
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Get the selected image data
        let imageName = imageNames[indexPath.row]
        let title = imageTitles[indexPath.row]
        let description = imageDescriptions[indexPath.row]
        
        // Get the image
        guard let image = UIImage(named: imageName) else {
            print("Error: Could not load image named \(imageName)")
            return
        }
        
        // Create the detail view controller
        let detailVC = ImageDetailViewController(
            image: image,
            title: title,
            description: description
        )
        
        // Push it onto the navigation stack
        navigationController?.pushViewController(detailVC, animated: true)
        
        // Debug log
        print("Selected: \(title)")
    }
}

