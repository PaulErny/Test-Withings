//
//  ViewController.swift
//  Withings
//
//  Created by Paul Erny on 10/06/2024.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var pixabayLogo: UIImageView!

    var images: [ImageModel] = []
    var selectedImages: [ImageModel] = [] {
        didSet {
            rightNavBarButton.isEnabled = selectedImages.count > 1
        }
    }
    var pageNumber: Int = 0
    var searchBarText: String = ""
    var isQuerying = false
    let rightNavBarButton = UIBarButtonItem()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        setupNavBar()
        setupPixabayLogo()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setupCollectionView()
    }
    
    private func setupPixabayLogo() {
        pixabayLogo.image = UIImage(named: "Pixabay")
        pixabayLogo.clipsToBounds = true
        pixabayLogo.layer.cornerRadius = pixabayLogo.bounds.width / 2
    }
    
    private func setupNavBar() {
        rightNavBarButton.title = "OK"
        rightNavBarButton.isEnabled = false
        rightNavBarButton.style = .plain
        rightNavBarButton.action = #selector(onImagesSelected)
        rightNavBarButton.target = self
        
        navigationItem.rightBarButtonItem = rightNavBarButton
        navigationItem.title = "Test Withings"
    }
    
    private func setupCollectionView() {
        // --- layout ---
        let layout =  UICollectionViewFlowLayout()
        let cellsPerRow: CGFloat = 3
        let lineSpacing: CGFloat = 5
        let interItemSpacing: CGFloat = 5
        
        let itemWidth = ( collectionView.frame.width - (cellsPerRow - 1) * interItemSpacing) / cellsPerRow
        let itemHight = itemWidth
        layout.itemSize = CGSize(width: itemWidth, height: itemHight)
        layout.sectionInset = UIEdgeInsets.zero
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = lineSpacing
        layout.minimumInteritemSpacing = interItemSpacing
        collectionView.setCollectionViewLayout(layout, animated: true)
        // --- other ---
        collectionView.allowsMultipleSelection = true
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    @objc func onImagesSelected() {
        let carousel = ImagesCarouselViewController()
        carousel.selectedImages = selectedImages
        navigationController?.pushViewController(carousel, animated: true)
    }
    
    private func queryImages() {
        guard !isQuerying else { return } // avoid queueing queries for the same data
        isQuerying = true
        APIManager.shared.fetchImages(search: searchBarText, page: pageNumber + 1, completion: { [weak self] response in
            guard let _self = self else { return }
            switch response {
            case .failure(let error):
                print(error) // !
                _self.isQuerying = false
            case .success(let data):
                _self.images.append(contentsOf: data.hits)
                _self.pageNumber += 1
                DispatchQueue.main.async {
                    _self.collectionView.reloadData()
                    _self.isQuerying = false
                }
            }
        })
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchBarText = searchBar.text else { return }
        self.searchBarText = searchBarText
        queryImages()
        searchBar.resignFirstResponder()
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCollectionViewCell
        images[indexPath.item].createPreviewImage(completion: { image in
            DispatchQueue.main.async {
                cell.setImage(with: image)
            }
        })
        if selectedImages.contains(where: { $0.id == images[indexPath.item].id }) {
            cell.checkmark.isHidden = false
        } else {
            cell.checkmark.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // request next page if needed
        if !images.isEmpty && indexPath.item == images.count - 1 {
            queryImages()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        (collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell).checkmark.isHidden = false
        selectedImages.append(images[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        (collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell).checkmark.isHidden = true
        selectedImages.removeAll(where: { $0.id == images[indexPath.item].id })
    }
}
