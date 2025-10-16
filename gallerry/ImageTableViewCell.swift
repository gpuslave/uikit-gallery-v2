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
    
    // MARK: - Properties
    
    /// Activity indicator shown while image is loading
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .systemGray
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    /// The current image URL being loaded (used for cell reuse)
    private var currentImageURL: String?
    
    /// The current download task (used for cancellation)
    private var downloadTask: URLSessionDataTask?
    
    // MARK: - Lifecycle Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Configure the image view appearance
        galleryImageView.contentMode = .scaleAspectFill
        galleryImageView.clipsToBounds = true
        galleryImageView.layer.cornerRadius = 8.0
        galleryImageView.backgroundColor = .systemGray6  // Light gray background while loading
        
        // Add activity indicator to image view
        galleryImageView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: galleryImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: galleryImageView.centerYAnchor)
        ])
        
        // Configure title label appearance
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 1
        
        // Configure description label appearance
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .gray
        descriptionLabel.numberOfLines = 2
        
        // Cell appearance
        backgroundColor = .white
        contentView.backgroundColor = .white
    }
    
    // MARK: - Configuration Method
    
    func configure(with imageURL: String, needsClientResize: Bool, title: String, description: String) {
        // Store current URL
        self.currentImageURL = imageURL
        
        // Set text immediately
        titleLabel.text = title
        descriptionLabel.text = description
        
        // Reset and show loading
        galleryImageView.image = nil
        activityIndicator.startAnimating()
        
        // Cancel existing download
        downloadTask?.cancel()
        
        // Load image with appropriate strategy
        downloadTask = ImageLoader.shared.loadImage(
            from: imageURL,
            generateThumbnail: needsClientResize,
            thumbnailWidth: 240
        ) { [weak self] image in
            guard self?.currentImageURL == imageURL else { return }
            
            self?.activityIndicator.stopAnimating()
            
            if let image = image {
                self?.galleryImageView.image = image
            } else {
                self?.galleryImageView.image = UIImage(systemName: "photo")
                self?.galleryImageView.tintColor = .systemGray3
            }
        }
    }

    // MARK: - Cell Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Cancel any pending download
        downloadTask?.cancel()
        downloadTask = nil
        
        // Reset content
        galleryImageView.image = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
        currentImageURL = nil
        
        // Stop activity indicator
        activityIndicator.stopAnimating()
    }
}
