//
//  ReachabilityExtension.swift
//  maxouf14
//
//  Created by Alistef on 25/02/2016.
//  Copyright © 2016 Alistef. All rights reserved.
//

import UIKit

/*** ajouter au tableau noConnexionMessages les éléments qui doivent être affiché en cas de perte de connexion, cachés sinon
*/

extension Reachability {
    /// rend vrai si un accès réseau (wifi ou autre) est disponible
    func internetAvailable() -> Bool {
        return self.currentReachabilityStatus() != NetworkStatus.NotReachable
    }
}

/// cette classe fourni un objet qui s'appui sur Reachability pour gérer la visibilité d'une vue
/// et le déclenchement d'action en fonction de la disponibilité d'une connexion internet
@objc class InternetAccessDisplay :NSObject {
    private weak var message : UIView?
    private weak var internetAccess : Reachability?
    private var action = { }
    
    /**
     création d'un objet InternetAccesDisplay, qui gérera l'apparition/disparition d'une vue en fonction de la disponibilité d'une connexion internet
 - Parameter internetAccess: le singleton Reacability qui émet les notifications
 - Parameter message: la vue a cacher ou afficher,
 - Parameter action: le bloc a exécuter si connexion internet présente
 */
    init(internetAccess : Reachability, message : UIView, action : @escaping () -> Void) {
        super.init()
        self.internetAccess = internetAccess
        self.message = message
        self.action = action
        NotificationCenter.default.addObserver(self, selector: #selector(updateDisplay), name: NSNotification.Name.reachabilityChanged, object: nil)
    }
    
    /**
    Si internet est accessible, on cache la vue et on déclenche l'action
     - Return true si internet accessible, false si innaccessible ou si statut impossible à vérifier
    */
    @objc func updateDisplay() -> Bool{
        //on vérifie que l'objet internetAccess existe
        guard let _ = internetAccess else { return false }
       
        // access à vrai si internet accessible
       let access   = internetAccess!.internetAvailable()
        
        //on affiche ou cache le message
        message?.isHidden = access
        
        if access { action() } //on exécute l'action si la connexion est revenue
        
        return access
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}



//protocol InternetAccessManagerProtocol {
//    var noConnexionMessages : [UIView] { get set}
//    func internetAvailable() -> Bool
//    func updateDisplay() -> Bool
//}
//
//
//class InternetAccessManager : InternetAccessManagerProtocol {
//    
//    var noConnexionMessages : [UIView] = []
//    
//    func internetAvailable() -> Bool {
//        return internetReachability.currentReachabilityStatus() != NetworkStatus.NotReachable
//    }
//    
//    func updateDisplay() -> Bool {
//        let access  = internetAvailable()
//        for v in noConnexionMessages {
//            v.hidden = access
//        }
//        return access
//    }
//    
//    // MARK: - Initialisation
//    init() {
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateDisplay", name: kReachabilityChangedNotification, object: nil)
//    }
//    
//    deinit {
//        NSNotificationCenter.defaultCenter().removeObserver(self)
//    }
//    
//    
//    // MARK: - Private func and var
//    private var internetReachability = Reachability.reachabilityForInternetConnection()
//    
//    
//}

//extension Reachability {
//    func ReachabilityCallback(target: SCNetworkReachabilityRef, info: UnsafeMutablePointer<Void>){
//        assert(info != nil, "info was NULL in ReachabilityCallback")
//        assert((info as! NSObject).isKindOfClass(Reachability), "info was wrong class in ReachabilityCallback")
//        print("sending notification with status")
//        let noteObject = info as! Reachability
//        let userInf :NSDictionary = [ "NetworkStatus" : NSNumber(integer: self.currentReachabilityStatus().rawValue ) ]
//        NSNotificationCenter.defaultCenter().postNotificationName(kReachabilityChangedNotification, object: noteObject, userInfo: userInf as [NSObject : AnyObject])
//        
//    }
//}
