//
//  ImageTableViewCell.swift
//  gallerry
//
//  Created by Aleksei Nemtsev on 16.10.2025.
//

import UIKit

/// Custom table view cell for displaying gallery images
class ImageTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    /// Image view to display the gallery photo
    @IBOutlet weak var galleryImageView: UIImageView!
    
    /// Label to display the image title
    @IBOutlet weak var titleLabel: UILabel!
    
    /// Label to display image description or subtitle
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: - Lifecycle Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Configure the image view appearance
        galleryImageView.contentMode = .scaleAspectFit
        galleryImageView.clipsToBounds = true
        galleryImageView.layer.cornerRadius = 8.0
        
        // Configure title label appearance
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 1
        
        // Configure description label appearance
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .gray
        descriptionLabel.numberOfLines = 2
        
        // Set background color for the cell
        backgroundColor = .white
        contentView.backgroundColor = .white
    }
    
    // MARK: - Configuration Method
    
    /// Configures the cell with image and text data
    /// - Parameters:
    ///   - imageName: Name of the image asset
    ///   - title: Title text for the cell
    ///   - description: Description text for the cell
    func configure(with imageName: String, title: String, description: String) {
        // Set the image from assets
        galleryImageView.image = UIImage(named: imageName)
        
        // Set the title text
        titleLabel.text = title
        
        // Set the description text
        descriptionLabel.text = description
    }
    
    // MARK: - Cell Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset cell content when it's being reused
        galleryImageView.image = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
    }
}
