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
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    
    var images: [ImageModel] = []
    var selectedImages: [ImageModel] = [] {
        didSet {
            rightBarButton.isEnabled = selectedImages.count > 1
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        rightBarButton.isEnabled = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setupCollectionView()
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
    
    
    @IBAction func onImagesSelected(_ sender: Any) {
        let carousel = ImagesCarouselViewController()
        carousel.selectedImages = selectedImages
        navigationController?.pushViewController(carousel, animated: true)
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        APIManager.shared.fetchImages(search: searchText, completion: { [weak self] response in
            guard let _self = self else { return }
            switch response {
            case .failure(let error):
                print(error) // !
            case .success(let data):
                _self.images = data.hits
                DispatchQueue.main.async {
                    _self.collectionView.reloadData()
                }
            }
        })
        searchBar.resignFirstResponder()
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCollectionViewCell
        cell.setImage(with: images[indexPath.item].previewImage)
        if selectedImages.contains(where: { $0.id == images[indexPath.item].id }) {
            cell.checkmark.isHidden = false
        } else {
            cell.checkmark.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        (collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell).checkmark.isHidden = false
        selectedImages.append(images[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        (collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell).checkmark.isHidden = true
        selectedImages.removeAll(where: { $0.id == images[indexPath.item].id })
//        selectedImages.remove(at: indexPath.item)
    }
}
