//
//  ImageDetailViewController.swift
//  gallerry
//
//  Created by Aleksei Nemtsev on 16.10.2025.
//

import UIKit

/// View controller to display a single image in full view with pinch-to-zoom
class ImageDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    /// The image to display
    var image: UIImage?
    
    /// Title for the navigation bar
    var imageTitle: String?
    
    /// Description for the image
    var imageDescription: String?
    
    // MARK: - UI Elements
    
    /// Scroll view to enable zooming
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.minimumZoomScale = 1.0
        sv.maximumZoomScale = 4.0
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    /// Image view to display the full image
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .systemBackground
        return iv
    }()
    
    /// Label to show description below the image
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background color
        view.backgroundColor = .systemBackground
        
        // Set navigation title
        self.title = imageTitle ?? "Image Detail"
        
        // Set scroll view delegate
        scrollView.delegate = self
        
        // Setup UI
        setupUI()
        
        // Configure with data
        configure()
        
        // Add double tap gesture for quick zoom
        addDoubleTapGesture()
    }
    
    // MARK: - Setup Methods
    
    /// Sets up the user interface
    private func setupUI() {
        // Add scroll view
        view.addSubview(scrollView)
        
        // Add image view to scroll view
        scrollView.addSubview(imageView)
        
        // Add description label
        view.addSubview(descriptionLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Scroll view - takes most of the screen
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -20),
            
            // Image view - inside scroll view
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            // Description label - at the bottom
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            descriptionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            descriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
    }
    
    /// Configures the view with the image and description
    private func configure() {
        imageView.image = image
        descriptionLabel.text = imageDescription
    }
    
    /// Adds double tap gesture for quick zoom in/out
    private func addDoubleTapGesture() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }
    
    /// Handles double tap to zoom in/out
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            // Zoom out to minimum
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            // Zoom in to 2x at the tap location
            let tapLocation = gesture.location(in: imageView)
            let zoomRect = zoomRectForScale(scale: 2.0, center: tapLocation)
            scrollView.zoom(to: zoomRect, animated: true)
        }
    }
    
    /// Calculates the zoom rectangle for a given scale and center point
    private func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width = imageView.frame.size.width / scale
        let newCenter = scrollView.convert(center, from: imageView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    // MARK: - Initialization
    
    /// Convenience initializer with all data
    convenience init(image: UIImage?, title: String?, description: String?) {
        self.init()
        self.image = image
        self.imageTitle = title
        self.imageDescription = description
    }
}

// MARK: - UIScrollViewDelegate

extension ImageDetailViewController: UIScrollViewDelegate {
    
    /// Tells the delegate which view to zoom
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    /// Called when the user is actively zooming
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // Center the image when it's smaller than the scroll view
        centerImage()
    }
    
    /// Centers the image when it's smaller than the scroll view bounds
    private func centerImage() {
        let boundsSize = scrollView.bounds.size
        var frameToCenter = imageView.frame
        
        // Center horizontally
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }
        
        // Center vertically
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }
        
        imageView.frame = frameToCenter
    }
}
