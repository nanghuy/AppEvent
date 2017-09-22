//
//  SearchVC.swift
//  AppEvent
//
//  Created by Kata Mr on 1/3/17.
//  Copyright © 2017 Kata Mr. All rights reserved.
//

import UIKit
import MapKit

private enum SuggestCell:String {
    case Suggest = "SearchCell"
    case SuggestCell = "searchCell"
}

class SearchVC: UIViewController {

    var searchController : UISearchController!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var clvSuggest: UICollectionView!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // set constraint
        topConstraint.constant = (navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height + 8
        bottomConstraint.constant = (tabBarController?.tabBar.frame.size.height)!
        view.layoutIfNeeded()
        
        // set collectionView
        guard let flowLayout = clvSuggest.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let width = clvSuggest.frame.size.height
        print("width",width)
        flowLayout.itemSize = CGSize(width: width, height: width)
        
        flowLayout.invalidateLayout()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // add searchBar
        self.searchController = UISearchController(searchResultsController:  nil)
        
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = true
        
        self.navigationItem.titleView = searchController.searchBar
        
        self.definesPresentationContext = true

        // Regist cell
        clvSuggest.register(UINib.init(nibName: SuggestCell.Suggest.rawValue, bundle: nil), forCellWithReuseIdentifier: SuggestCell.SuggestCell.rawValue)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func gotoMap(_ sender: AnyObject) {
        let mapVC = MapVC(nibName: "MapVC", bundle: nil)
        navigationController?.pushViewController(mapVC, animated: true)
    }
}

extension SearchVC : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SuggestCell.SuggestCell.rawValue, for: indexPath) as! SearchCell
        
        return cell
    }
}

extension SearchVC : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let detail = DetailVC(nibName: "DetailVC", bundle: nil)
        navigationController?.pushViewController(detail, animated: true)
        
    }
}

extension SearchVC : UISearchControllerDelegate {
    
}

extension SearchVC : UISearchBarDelegate {
    
}

extension SearchVC : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}


