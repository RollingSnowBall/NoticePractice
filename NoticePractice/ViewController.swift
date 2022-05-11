//
//  ViewController.swift
//  NoticePractice
//
//  Created by JUNO on 2022/05/11.
//

import UIKit
import FirebaseRemoteConfig
import FirebaseAnalytics

class ViewController: UIViewController {

    var remoteConfig: RemoteConfig?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        remoteConfig = RemoteConfig.remoteConfig()
        
        let setting = RemoteConfigSettings()
        setting.minimumFetchInterval = 0 // 새로운 값을 패치하는 인터벌
        
        remoteConfig?.configSettings = setting
        remoteConfig?.setDefaults(fromPlist: "RemoteConfigDefault")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getNotice()
    }
}

//RemoteConfig
extension ViewController {
    func getNotice(){
        guard let remoteConfig = remoteConfig else { return }
        
        remoteConfig.fetch { [weak self] status, _ in
            if status == .success {
                remoteConfig.activate(completion: nil)
            } else {
                print("ERROR: Config Not Fetched")
            }
            
            guard let self = self else { return }
            
            if !self.isNoticeHidden(remoteConfig){
                let noticeVC = NoticeViewController(nibName: "NoticeViewController", bundle: nil)
                
                noticeVC.modalPresentationStyle = .custom
                noticeVC.modalTransitionStyle = .crossDissolve
                
                let title = (remoteConfig["title"].stringValue ?? "").replacingOccurrences(of: "\\n", with: "\n")
                let detail = (remoteConfig["detail"].stringValue ?? "").replacingOccurrences(of: "\\n", with: "\n")
                let date = (remoteConfig["date"].stringValue ?? "").replacingOccurrences(of: "\\n", with: "\n")
                
                noticeVC.noticeContent = (title: title, detail: detail, date: date)
                self.present(noticeVC, animated: true, completion: nil)
            }else{
                self.showAlert()
            }
        }
    }
    
    func isNoticeHidden(_ remoteConfig: RemoteConfig) -> Bool {
        return remoteConfig["isHidden"].boolValue
    }
}

//A-B Testing
extension ViewController {
    func showAlert(){
        guard let remoteConfig = remoteConfig else { return }
        
        remoteConfig.fetch { [weak self] status, _ in
            if status == .success {
                remoteConfig.activate(completion: nil)
            } else {
                print("ERROR: Config Not Fetched")
            }
            
            let message = remoteConfig["message"].stringValue ?? "AA"
            
            let confirmAlert = UIAlertAction(title: "확인하기", style: .default) { _ in
                Analytics.logEvent("promotion_alert", parameters: nil)
            }
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            let alertCV = UIAlertController(title: "깜짝이벤트", message: message, preferredStyle: .alert)
            
            alertCV.addAction(confirmAlert)
            alertCV.addAction(cancelAction)
            
            self?.present(alertCV, animated: true, completion: nil)
        }
    }
}

