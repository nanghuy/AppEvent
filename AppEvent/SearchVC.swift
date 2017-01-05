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

private let numberOfItemPerRowPortrait : CGFloat = 3.0
private let numberOfItemPerRowLandscape : CGFloat = 5.0
private let leftAndRightPaddingsPortrait: CGFloat = 8.0 * ( numberOfItemPerRowPortrait + 1 )
private let leftAndRightPaddingsLandscape: CGFloat = 8.0 * ( numberOfItemPerRowLandscape + 1 )

class SearchVC: UIViewController {

    var searchController : UISearchController!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var clvSuggest: UICollectionView!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        topConstraint.constant = (navigationController?.navigationBar.frame.size.height)!
        bottomConstraint.constant = (tabBarController?.tabBar.frame.size.height)!
        view.layoutIfNeeded()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let flowLayout = clvSuggest.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let width = ( CGRectGetWidth(clvSuggest.frame) - leftAndRightPaddingsLandscape ) / numberOfItemPerRowLandscape
        flowLayout.itemSize = CGSizeMake(width, width)
        
        flowLayout.invalidateLayout()
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
        clvSuggest.registerNib(UINib.init(nibName: SuggestCell.Suggest.rawValue, bundle: nil), forCellWithReuseIdentifier: SuggestCell.SuggestCell.rawValue)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
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

}

extension SearchVC : UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SuggestCell.SuggestCell.rawValue, forIndexPath: indexPath) as! SearchCell
        
        return cell
    }
}

extension SearchVC : UICollectionViewDelegate {
    
}

extension SearchVC : UISearchControllerDelegate {
    
}

extension SearchVC : UISearchBarDelegate {
    
}

extension SearchVC : UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }
}


