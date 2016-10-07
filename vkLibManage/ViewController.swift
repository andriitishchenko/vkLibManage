//
//  ViewController.swift
//  vkLibManage
//
//  Created by Andrii Tiischenko on 10/5/16.
//  Copyright © 2016 Andrii Tiischenko. All rights reserved.
//

import UIKit


public struct Consts{
    static let SCOPE = [VK_PER_FRIENDS, VK_PER_WALL, VK_PER_AUDIO];
    //[VK_PER_FRIENDS, VK_PER_WALL, VK_PER_AUDIO, VK_PER_PHOTOS, VK_PER_NOHTTPS, VK_PER_EMAIL, VK_PER_MESSAGES];
}


class ViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        VKSdk.initialize(withAppId: "5656175").register(self);
        
        VKSdk.instance().uiDelegate = self
        
        
        
        VKSdk.wakeUpSession(Consts.SCOPE) { (state, Error) in
            if state == VKAuthorizationState.authorized {
                print("!!!! AUTH !!!!!")
            }
            else
            {
                if (Error == nil) {
                    VKSdk.authorize(Consts.SCOPE)
                }
                else
                {
                    print(Error?.localizedDescription)
                }
            }
        }
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func authorize(sender: UIButton?) {
       VKSdk.authorize(Consts.SCOPE)
    }
    
    func startWorking() {
        
        print("!!! SUCCESS !!!")
        self.performSegue(withIdentifier: "PlaylistControllerSegue", sender: self)
    }
}

extension ViewController: VKSdkDelegate,VKSdkUIDelegate {
    
    
    //requaried
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        let vc:VKCaptchaViewController = VKCaptchaViewController.captchaControllerWithError(captchaError)
        vc.present(in: self.navigationController?.topViewController)
    }
    
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        self.navigationController?.topViewController?.present(controller, animated: false, completion: nil)
    }
    
    //requaried
    func vkSdkUserAuthorizationFailed() {
        
        let alertController = UIAlertController(title: "Error", message: "Access denied", preferredStyle: .alert)
        
        /*
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            
        }
        alertController.addAction(cancelAction)
        */
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            self.navigationController?.popToRootViewController(animated: false)
        }
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: false, completion: nil)
    }
    
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        if (result.token != nil) {
            self.startWorking()
        }
        else
        {
            let alertController = UIAlertController(title: "Error", message: "Access denied\n"+result.error.localizedDescription, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                self.navigationController?.popToRootViewController(animated: false)
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: false, completion: nil)
        }
    }
    
    //******
    
    func vkSdkTokenHasExpired(_ expiredToken: VKAccessToken) {
        self.authorize(sender:nil)
    }
    
    func vkSdkUserDeniedAccess(_ authorizationError: VKError) {
        print("vkSdkUserDeniedAccess: %@",authorizationError.errorText)
    }
    
    
    func vkSdkReceivedNewToken(_ newToken: VKAccessToken) {
    
    }

    
    
    
    
    
    
    
}

