//
//  ImagesCarouselViewController.swift
//  Withings
//
//  Created by Paul Erny on 10/06/2024.
//

import Foundation
import UIKit

class ImagesCarouselViewController: UIViewController {
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: CarouselLayout())
    
    var selectedImages: [ImageModel] = []
    var loadedImages = 0 {
        didSet {
            if loadedImages == selectedImages.count {
                dismissAlerView()
            }
        }
    }
    private var timer: Timer?
    var selectedIndex: Int = 0
    
    let alert = UIAlertController(title: nil, message: "Un instant...", preferredStyle: .alert)
    var isPresentingAlert = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentAlertView()
        setupView()
        setupTimer()
        setupImageFilters()
        setupAlertView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func presentAlertView() {
        if !isPresentingAlert && loadedImages < selectedImages.count {
            present(alert, animated: true)
            isPresentingAlert = true
        }
    }
    
    private func dismissAlerView() {
        if isPresentingAlert {
            alert.dismiss(animated: true)
            isPresentingAlert = false
        }
    }
    
    private func setupAlertView() {
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
    }
    
    private func setupView() {
        self.view.frame = .zero
        self.view.backgroundColor = .white
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .clear
        collectionView.contentMode = .scaleAspectFill
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isUserInteractionEnabled = false
        collectionView.isPagingEnabled = true

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
    
    private func setupTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            withTimeInterval: 3.0,
            repeats: true,
            block: { [weak self] _ in
                guard let _self = self else { return }
                _self.selectNextImage(at: _self.selectedIndex + 1)
            }
        )
    }
    
    private func selectNextImage(at index: Int) {
        let index = selectedImages.count > index ? index : 0
        guard selectedIndex != index else { return }
        selectedIndex = index
        collectionView.scrollToItem(at: IndexPath(item: selectedIndex, section: 0), at: .centeredVertically, animated: true)
    }
    
    private func setupImageFilters() {
        for (index, imageData) in selectedImages.enumerated() {
            imageData.createLargeImage(completion: { [weak self] image in
                guard let _self = self else { return }
                let filteredImage = ImageFilterer.shared.applyRandomFilter(on: image, addingFilterName: true)
                _self.selectedImages[index].image = filteredImage
                DispatchQueue.main.async {
                    _self.loadedImages += 1
                    _self.collectionView.reloadData()
                }
            })
        }
    }
}

extension ImagesCarouselViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let imageView: UIImageView = UIImageView(frame: .zero )
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        imageView.sizeToFit()
        imageView.image = selectedImages[indexPath.item].image
        cell.contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: cell.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: cell.bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: cell.trailingAnchor),
            imageView.leadingAnchor.constraint(equalTo: cell.leadingAnchor)
        ])
        return cell
    }
}

extension ImagesCarouselViewController: UICollectionViewDelegate {}
