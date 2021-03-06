//
//  splash.swift
//  tipcoin
//
//  Created by Bergman, Yon on 6/24/15.
//  Copyright (c) 2015 CPC Ninjas. All rights reserved.
//

import Foundation
import ParseFacebookUtilsV4

class SplashViewController: UIViewController {
  
  @IBOutlet var tiledBgView: TiledBackgroundView!
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var inviteDiscloser: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    startLoading()
    println("+ SplashVC")
  }
  
  deinit{
    println("- SplashVC")
  }
  
  func startLoading(){
    tiledBgView.animate()
    if PFUser.currentUser() != nil {
      getUserData()
    } else {
      showLogin()
    }
  }
  
  func showLogin() {
    tiledBgView.stopAnimation()
    UIView.animateWithDuration(0.2, animations: {
      self.loginButton.alpha = 1
    })
    if InviteManager.sharedInstance.hasInvite() {
      inviteDiscloser.hidden = false
    }
  }

  @IBAction func didClickLogin(sender: AnyObject) {
    tiledBgView.animate()
    loginButton.alpha = 0
    inviteDiscloser.hidden = true
    PFFacebookUtils.logInInBackgroundWithReadPermissions([]) {
      (user: PFUser?, error: NSError?) -> Void in
      if let user = user {
        self.getUserData()
      } else {
        println("Uh oh. The user cancelled the Facebook login.")
      }
    }
  }
  
  func getUserData() {
    let request = FBSDKGraphRequest(graphPath: "me", parameters: nil)
    request.startWithCompletionHandler() { connection, result, error in
      let firstName = result["first_name"] as! String
      let lastName = result["last_name"] as! String
      let displayName = result["name"] as! String
      let fbId = result["id"] as! String
      let avatarUrl = "http://graph.facebook.com/\(fbId)/picture"
      
      let userInfo = UserInfo(firstName: firstName, lastName: lastName, displayName: displayName, avatarUrl: avatarUrl)
      UpdateUserOperation().run(userInfo) { result,err in
        if let user = result as? PFUser {
          
        }
      }
      if let user = PFUser.currentUser() {
        if user["avatarUrl"] == nil {
          user.fetchInBackground()
        }
      }
      if InviteManager.sharedInstance.hasInvite() {
        InviteManager.sharedInstance.joinGroup() { group, err in
          self.navigateToNext()
        }
      } else {
        self.navigateToNext()
      }

    }
  }
  
  private func navigateToNext() {
    self.performSegueWithIdentifier("showMenu", sender: nil)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showGroup" {
//      if let vc = segue.destinationViewController as GroupViewController {
//      }
    }
  }
  
  @IBAction func goBackToSplash(segue: UIStoryboardSegue) {
    startLoading()
  }

}