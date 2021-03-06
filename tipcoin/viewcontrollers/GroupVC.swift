//
//  GroupVC.swift
//  tipcoin
//
//  Created by Bergman, Yon on 7/1/15.
//  Copyright (c) 2015 CPC Ninjas. All rights reserved.
//

import Foundation
import SwiftyDrop


class GroupViewController: UIViewController {
  
  @IBOutlet private weak var groupNameLabel: UILabel!
  @IBOutlet private weak var balanceLabel: UILabel!
  
  @IBOutlet weak var tableView: UITableView! {
    didSet {
      refreshControl = UIRefreshControl()
      refreshControl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
      tableView.addSubview(refreshControl)
      tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0)
    }
  }
  var refreshControl: UIRefreshControl!
  var currentSelectedCell: MemberCell?
  
  @IBOutlet weak var tippy: UIImageView! {
    didSet{
      tippy?.startSpinning()
      refreshControl?.beginRefreshing()
    }
  }
  
  @IBAction func shareInvite(sender: AnyObject) {
    if let url = group?.inviteUrl {
      let sharingItems = [url, url.absoluteString!]
      let shareVC = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
      shareVC.excludedActivityTypes = [UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact]
      presentViewController(shareVC, animated: true, completion: nil)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.showGroupInfo()
  }
  
  override func viewWillAppear(animated: Bool) {
    if group == nil {
      performSegueWithIdentifier("showMenuInstant", sender: nil)
    }
  }
  
  deinit{
    println("- GroupVC")
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showMember" {
      if let cell = sender as? MemberCell,
        vc = segue.destinationViewController as? MemberViewController {
          cell.selected = false
          vc.member = members[cell.tag]
          vc.userMember = userMember
      }
    } else if segue.identifier == "showSelf" {
      if let vc = segue.destinationViewController as? MemberViewController,
             userMember = userMember {
        vc.member = userMember
      }
    } else if segue.identifier == "showMenu" {
      if let vc = segue.destinationViewController as? MenuViewController,
        userMember = userMember {
          vc.currentGroupMember = userMember
      }
    }
  }

  var userMember: Member? {
    didSet {
      self.group = userMember?.group
    }
  }
  
  var group: Group? {
    didSet {
      if let group = group {
        self.refresh()
      }
    }
  }
  
  func showGroupInfo() {
    if let group = group {
      groupNameLabel?.text = group.name
      balanceLabel?.text = "Your Personal Balance: \(userMember!.displayBalance)"
    }
  }
  
  var members: [Member] = [] {
    didSet {
      tableView.reloadData()
      refreshControl.endRefreshing()
      tippy.stopSpinning()
    }
  }
  
  var fetchedGroupInfo = false
  
  func refresh() {
    self.userMember?.fetchInBackgroundWithBlock() { obj, err in
      self.showGroupInfo()
    }
    if let group = group {
      tippy?.startSpinning()
      GetGroupInfo.get(group.objectId!) { group in
        self.fetchedGroupInfo = true
        self.members = group.sortedMembers
      }
    }
  }
  
  
  @IBAction func backToGroup(segue: UIStoryboardSegue) {
  }

}



extension GroupViewController: UITableViewDataSource, UITableViewDelegate, MemberCellDelegate {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if members.count == 0 {
      return tableView.dequeueReusableCellWithIdentifier("EMPTY_CELL", forIndexPath: indexPath) as! UITableViewCell
    }
    let cell = tableView.dequeueReusableCellWithIdentifier("MEMBER_CELL", forIndexPath: indexPath) as! MemberCell
    cell.tag = indexPath.row
    cell.member = members[indexPath.row]
    cell.delegate = self
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if !fetchedGroupInfo { return 0 }
    return max(members.count, 1)
  }
  
  func cellStateChanged(cell: MemberCell) {
    if cell.state == .Spot {
      self.currentSelectedCell?.resetState()
      self.currentSelectedCell = cell
    }
  }
  
  func spot(member: Member) {
    SpotOperation.run(self.userMember!, to: member) { transaction, err in
      self.refresh()
    }
  }
  
  func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
//    if let cell = self.currentSelectedCell {
//      if cell.state == .Spot {
//        cell.resetState()
//      }
//    }
  }
  
}

