//
//  SideMenu.swift
//  OOPBusMaps
//
//  Created by Jasmin Abou Aldan on 11/12/14.
//  Copyright (c) 2014 Jasmin Abou Aldan. All rights reserved.
//

import UIKit

/**********************************************************************************************************/
//MARK: - Delegate
protocol SideMenuDelegate{
    func sideMenuDidSelectButtonAtIndex(section:Int, index: Int)
   
}

/**************************************************************************************************************/
//MARK: - SideMenu Class
class SideMenu: NSObject, SideMenuTableViewControllerDelegate {
    
    /**********************************************************************************************************/
    //MARK: Variable declaration
    let menuWidth: CGFloat = 250.0
    let sideMenuTableViewTopInsert: CGFloat = 64.0
    let sideMenuContainerView: UIView = UIView()
    let sideMenuTableViewController: SideMenuTableViewController = SideMenuTableViewController()
    var originalView: UIView!
    var delegate: SideMenuDelegate?
    var isSideMenuOpen: Bool = false
    var heighAd: CGFloat = 0.0

    
    /**********************************************************************************************************/
    //MARK: Class init
    override init(){
        originalView = UIView()
        super.init()
    }
    
    init(sourceView: UIView, menuItems: Array<String>){
        super.init()
        originalView = sourceView
        sideMenuTableViewController.tableData = menuItems
        createSideMenu()
    }
    
    /**********************************************************************************************************/
    //MARK: Method for creating menu
    ///Method that creates menu on screen
    
    func createSideMenu(){
        
        sideMenuContainerView.frame = CGRectMake(isSideMenuOpen ? 0 : -menuWidth, originalView.frame.origin.y, menuWidth, originalView.frame.size.height-heighAd)
        sideMenuContainerView.backgroundColor = UIColor.whiteColor()
        sideMenuContainerView.layer.shadowOffset = CGSizeMake(-2.0, -2.0) //sjene
        sideMenuContainerView.layer.shadowRadius = 2.0
        sideMenuContainerView.layer.shadowOpacity = 0.125
        sideMenuContainerView.layer.shadowPath = UIBezierPath(rect: sideMenuContainerView.bounds).CGPath
        
        originalView.addSubview(sideMenuContainerView)
        
        sideMenuTableViewController.delegate = self
        sideMenuTableViewController.tableView.frame = CGRectMake(0, 0, sideMenuContainerView.bounds.width, sideMenuContainerView.bounds.height)
        sideMenuTableViewController.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        sideMenuTableViewController.tableView.backgroundColor = UIColor.clearColor()
        sideMenuTableViewController.tableView.contentInset = UIEdgeInsetsMake(sideMenuTableViewTopInsert, 0, 0, 0)
        
        sideMenuTableViewController.tableView.reloadData()
        
        sideMenuContainerView.addSubview(sideMenuTableViewController.tableView)
        
    }
    
    /**********************************************************************************************************/
    //MARK: Method for controling open or close the menu
    ///showSideMenu are opening or closing the menu
    /// - Parameter shouldOpen: Takes Bool value if menu shoud be opened or closed
    
    func showSideMenu(shouldOpen: Bool){
        
        isSideMenuOpen = shouldOpen
        
        var destinationFrame: CGRect
        
        destinationFrame = CGRectMake(shouldOpen ? 0 : -menuWidth, 0, menuWidth, sideMenuContainerView.frame.size.height)
        UIView.animateWithDuration(0.4, animations: {() -> Void in
            self.sideMenuContainerView.frame = destinationFrame
        })
    }

    func sideMenuControlDidSelectRow(indexPath: NSIndexPath) {
        delegate?.sideMenuDidSelectButtonAtIndex(indexPath.section, index: indexPath.row)
    }
   
}
