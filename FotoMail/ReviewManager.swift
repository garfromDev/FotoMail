//
//  ReviewManager.swift
//  maxouf14
//
//  Created by Alistef on 27/02/2016.
//  Copyright © 2016 Alistef. All rights reserved.
//
// Based on ReviewManager from Maxouf14
// converted to Swift 3, direct access to internet.reachability added, corrigé la table de décision
// all text translated into english
// reviw link changed to avoid us store
import UIKit
import MessageUI
// DEPENDS on Reachability + ReachabilityExtension.swift

let DEBUG = false

/// Protocole pour un objet voulant gérer l'affichage des questions et les interactions avec l'utilisateur de manière custom
protocol ReviewDisplayProtocol {
    /// affiche un message avec choix OUI/NON
    func displayMessage( msg: String, negatifChoice : String?)
    /// permet à l'utilisateur de faire la revue de l'appli sur l'AppStore
    func performReview() -> Bool
    /// permet à l'utilisateur de renvoyer un feedback à l'adresse indiquée
    func performFeedback( mail : String, finalDecision :   @escaping(UserSatisfaction) -> Void)
}


    /// reaction possible de l'utilisateur
    enum UserSatisfaction : String {
        case none
        case satisfiedDidEvaluate
        case satisfiedDeclinedEvaluation
        case unsatisfiedDidFeedback
        case unsatisfiedDeclinedFeedback
    }



/** cette classe fourni un service pour gérer l'opportunité de proposer à l'utilisateur une
    revue de l'application et fournit aussi une interface par défaut pour gérer l'interaction avec l'utilisateur
    L'application doit appeller userHasAchieved() quand l'utilisateur a réussi quelque chose ou bien utilisé l'appli
    L'application doit régulièrement appeller la méthode checkReview() à un moment opportun
    Il est possible de personaliser cette interaction en fournissant un délégué répondant au protocole ReviewDisplayProtocol
    Le délégué gère alors les interactions et appelle les méthodes de l'interface
*/

/// !!!!!!!!!!!! mettre celui de votre app !!!!!!!!!!!!!!
/// l'ID de l'app obtenu dans iTunesConnect
let appId = 1210869548

@objc class Reviewmanager : NSObject, ReviewDisplayProtocol, UIAlertViewDelegate, MFMailComposeViewControllerDelegate {
    
    /// liste des clefs stockees dans les défaults
    enum UserDefaultKeys : String {
        case achievements
        case achievementsSinceLastEvaluation
        case currentDecision
        case currentDecisionDate
        case previousDecision
        case previousDecisionDate
        case firstInitDate
        case currentVersionDate
        case activationNb
        case currentActivationNb
        case previousVersion
    }
    
    /// message par défaut pour la 1ere question sur la satisfaction
//    enum msg1 : String {
//        case standard = "Est tu satisfait de l'application?"
//        case stillSatisfied = "Toujours satisfait de l'application?"
//        case newVersion = "La nouvelle version de l'appli a-t-elle corrigé ce qui ne te satisfaisait pas?"
//    }
    enum msg1 : String {
        case standard = "Are you satisfied with this app?"
        case stillSatisfied = "Still satisfied?"
        case newVersion = "Has the new release fixed what you did not like about the app?"
    }
    /// messages par défauts pour la deuxième question
//    enum msg2 : String {
//        case positif = "Veux-tu donner une évaluation?"
//        case negatif = "Peux-tu nous dire ce qui ne te satisfait pas?"
//    }
    enum msg2 : String {
        case positif = "Would you give a rating?"
        case negatif = "Could you feedback what you don't like?"
    }

    // création du signeton (cf https://thatthinginswift.com/singletons/)
    static let sharedInstance = Reviewmanager()

    // MARK: interface de paramétrage
    /// nombre d'activation de l'appli nécessaire pour qu'une reve puisse être demandée en fonction des autres conditions
    var minimumActivationNumber = DEBUG ? 1 : 5
    /// nombre d'activation de l'appli déclenchant une revue en l'absence d'autres conditions
    var maximumActivationNumber = 30
    /// temps minimum depuis la 1ere activation de la version courante (en jours)
    var minimumTimeSinceCurrentActivation : Double =  DEBUG ? 1 : 10
    /// nombre d'achievement nécessaires
    var minimumAchievementsNeeded  = 4
    /// temps écoulé nécessaire depuis un declined (en jours)
    var minimumTimeSinceDeclined : Double = DEBUG ? 1 : 50
    
    private var internetAccess = Reachability.forInternetConnection()
    
    // MARK: Interface
    
    /// en fonction de l'état passé ou présent, interoge l'utilisateur et lui fait attribuer une évaluation
    func checkReview()  {
        let ( shouldAsk, msg) = shouldAskForReview()
        guard shouldAsk && msg != nil && displayStatus == .ready else { return }
        displayStatus = .question1
        (delegate ?? self).displayMessage(msg: msg!, negatifChoice: nil) //le reste du boulot est fait par le délégué du displayer, qui est ReviewManager dans le cas par défaut
    }
    
    /// renvoi un booleen indiquant si il faut poser la question et le message
    func shouldAskForReview()->(Bool, String?) {
        guard (internetAccess?.internetAvailable())! else { return (false, nil) }
        guard currentActivationNb >= minimumActivationNumber else { return (false, nil) }
        
        switch (UserSatisfaction(rawValue: currentDecision)!, UserSatisfaction(rawValue: previousDecision)!) {
        case (.none, .none):
            return (rule1(), msg1.standard.rawValue)
        case (.satisfiedDidEvaluate, _), (.unsatisfiedDidFeedback, _), (.unsatisfiedDeclinedFeedback, _), (.satisfiedDeclinedEvaluation, .unsatisfiedDeclinedFeedback) :
            return ( false, nil)
        case (.none, .unsatisfiedDidFeedback)      where timeSince(date: previousDecisionDate) > minimumTimeSinceDeclined,
             (.none, .unsatisfiedDeclinedFeedback) where timeSince(date: previousDecisionDate) > minimumTimeSinceDeclined :
            return (rule1(), msg1.newVersion.rawValue)
        case (.none, .satisfiedDidEvaluate)        where timeSince(date: previousDecisionDate) > minimumTimeSinceDeclined,
             (.none, .satisfiedDeclinedEvaluation) where timeSince(date: previousDecisionDate) > minimumTimeSinceDeclined :
            return (rule1(), msg1.stillSatisfied.rawValue)
        case let (.satisfiedDeclinedEvaluation, previous) where ( previous == .satisfiedDidEvaluate || previous == .satisfiedDeclinedEvaluation || previous == .unsatisfiedDidFeedback ) &&  timeSince(date: previousDecisionDate) > minimumTimeSinceDeclined :
            return (true, msg1.stillSatisfied.rawValue)
        case (.satisfiedDeclinedEvaluation, .none) where timeSince(date: previousDecisionDate) > minimumTimeSinceDeclined :
            return (true, msg1.standard.rawValue)
        default :
        return (false, nil)
        }
    }
    
    /**  appellé pour indiquer que l'utilisateur a atteint un achievement
     *   la définition de l'achievement est au libre arbitre de l'applicatif */
    func userHasAchieved(){
        achievements += 1
    }
    
    /** appellé pour indiquer la décision de l'utilisateur à la premiere question (aimez vous l'appli)
        affiche le deuxième message via la méthode displayMessage() du délégué en fonction de la 1ere réponse
    */
    func userLikeDecision( decision: Bool) {
        displayStatus = decision ? .question2Positif : .question2Negatif
        (delegate ?? self).displayMessage(
            msg: decision ? msg2.positif.rawValue : msg2.negatif.rawValue ,
            negatifChoice: "Later") //"Plus tard"
    }
    
    /** appellé pour indiquerla décision de l'utilisateur à la deuxième question suite à un OUI (voulez vous évaluer?)
        lance la revue via la méthode performReview() du délégué si réponse positive
    */
    func userReviewDecision( decision: Bool) {
        displayStatus = decision ? .reviewing : .ready
        if !decision {
            userHasDecided(decision: UserSatisfaction.satisfiedDeclinedEvaluation)
            return
        }
        if (delegate ?? self).performReview() {
            userHasDecided(decision: .satisfiedDidEvaluate)
        }
        displayStatus = .ready
    }

    private let feedbackMail = "garfromDev@laposte.net"
    /// appellé pour indiquerla décision de l'utilisateur à la deuxième question suite à un NON (voulez vous laisser un feedback?)
    func userFeedbackDecision( decision : Bool) {
        displayStatus = decision ? .feedbacking : .ready
        guard decision else {
            userHasDecided(decision: UserSatisfaction.unsatisfiedDeclinedFeedback)
            return
        }

        (delegate ?? self).performFeedback(mail: feedbackMail, finalDecision :
                { (decision : UserSatisfaction) in
                    self.userHasDecided(decision: decision)
                    self.displayStatus = .ready }
            )

    }
    
    
    /// le délégué qui gère les communications avec l'utilisateur si on veut s'éloigner du comportement par défaut (boite de dialogue)
    var delegate : ReviewDisplayProtocol?
    
    // MARK: private vars
    private var defaults = UserDefaults.standard
    /// nb total d'achievement
    private var achievements : Int  = 0 {
        didSet{
            defaults.set(achievements, forKey: UserDefaultKeys.achievements.rawValue)
        } }
    /// nb d'achivement depuis derniere évaluation
    private var achievementsSinceLastEvaluation : Int = 00 {
        didSet{
            defaults.set(achievementsSinceLastEvaluation, forKey:UserDefaultKeys.achievementsSinceLastEvaluation.rawValue)
        } }
    
    /// décision de l'utilisateur concernant la version actuelle de l'appli
    private var currentDecision : String = UserSatisfaction.none.rawValue {
        didSet{
            defaults.set(currentDecision, forKey:UserDefaultKeys.currentDecision.rawValue)
        } }
    
    private var currentDecisionDate : NSDate? {
        didSet{
            defaults.set(currentDecisionDate, forKey:UserDefaultKeys.currentDecisionDate.rawValue)
        } }
    
    /// décision de l'utilisateur concernant la dernière version précédente ayant donné lieu  à décision
    private var previousDecision : String = UserSatisfaction.none.rawValue {
        didSet{
            defaults.set(previousDecision, forKey:UserDefaultKeys.previousDecision.rawValue)
        } }
    
    private var previousDecisionDate : NSDate? {
        didSet{
            defaults.set(previousDecisionDate, forKey:UserDefaultKeys.previousDecisionDate.rawValue)
        } }
    
    /// date de première activation de l'appli
    private var firstInitDate : NSDate? {
        didSet{
            defaults.set(firstInitDate, forKey:UserDefaultKeys.firstInitDate.rawValue)
        } }
    
    /// date de première utilisation de la version courante
    private var currentVersionDate : NSDate? {
        didSet{
            defaults.set(currentVersionDate, forKey:UserDefaultKeys.currentVersionDate.rawValue)
        } }
    
    /// nb total d'activation de l'appli
    private var activationNb : Int = 0{
        didSet{
            defaults.set(activationNb, forKey:UserDefaultKeys.activationNb.rawValue)
        } }
    
    /// nb d'activation de la version courante depuis la dernière décision ou activation de la version
    private var currentActivationNb : Int = 0{
        didSet{
            defaults.set(currentActivationNb, forKey:UserDefaultKeys.currentActivationNb.rawValue)
        } }
    
    /// version précédente de l'appli
    private var previousVersion : String = ""{
        didSet{
            defaults.set(previousVersion, forKey:UserDefaultKeys.previousVersion.rawValue)
        } }
    
    /// statut de l'avancement du dialogue avec l'utilisateur
    private enum DisplayStatus {
        case ready
        case question1
        case question2Positif
        case question2Negatif
        case reviewing
        case feedbacking
    }
    private var displayStatus : DisplayStatus = .ready
    /// block à rappeller après composition du mail de feddback
    private var feedbackCallback : (UserSatisfaction) -> Void = { (d : UserSatisfaction ) in  }
    
    /// initialise le ReviewManager en récupérant les valeurs sauvées si elles existente
    
    override init(){
        super.init()
        // on vérifie si les valeurs sauvées existent (l'appli a déjà été activée)
        let defaults = UserDefaults.standard
        // on s'abonne pour suivre le nombre d'activation de l'appli
        NotificationCenter.default.addObserver(self, selector: #selector(becomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        guard let _ = defaults.object(forKey: UserDefaultKeys.firstInitDate.rawValue)
            else { // 1ere activation de l'appli
                self.firstInitDate = NSDate()
                // version de l'appli
                previousVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
                return
        }
        
        getDefaults()
        //vérification de la version de l'appli
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        if version == previousVersion { return }
        
        // la version est différente, on met à jour les valeurs
        previousDecision = currentDecision
        currentDecision = UserSatisfaction.none.rawValue
        previousDecisionDate = currentDecisionDate
        currentDecisionDate = nil
        currentVersionDate = NSDate()
        currentActivationNb = 0
        previousVersion = version
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    /// appellé à chaque activation de l'application
    func becomeActive(){
        activationNb += 1
        currentActivationNb += 1
        print("ReviewManager : activation number incremented : \(activationNb)")
    }
    
    
    // MARK: private func
    
    /** appellé pour indiquer la décision finale de l'utilsateur suite  à une proposition de revue
    * */
    private  func userHasDecided(decision : UserSatisfaction){
        currentDecision = decision.rawValue
        currentDecisionDate = NSDate()
        currentActivationNb = 0 //on devra attendre un nombre d'activation de l'appli avant de reposer la question
        displayStatus = .ready
    }
    
    /// reli les défaults et initialise les variables
    private func getDefaults(){
        achievements = defaults.object(forKey: UserDefaultKeys.achievements.rawValue) as? Int ?? 0
        achievementsSinceLastEvaluation = defaults.object(forKey: UserDefaultKeys.achievementsSinceLastEvaluation.rawValue) as? Int ?? 0
        currentDecision = defaults.object(forKey: UserDefaultKeys.currentDecision.rawValue) as? String ?? UserSatisfaction.none.rawValue
        currentDecisionDate = defaults.object(forKey: UserDefaultKeys.currentDecisionDate.rawValue) as? NSDate
        previousDecision = defaults.object(forKey: UserDefaultKeys.previousDecision.rawValue) as? String ?? UserSatisfaction.none.rawValue
        previousDecisionDate = defaults.object(forKey: UserDefaultKeys.previousDecisionDate.rawValue) as? NSDate
        firstInitDate = defaults.object(forKey: UserDefaultKeys.firstInitDate.rawValue) as? NSDate
        currentVersionDate = defaults.object(forKey: UserDefaultKeys.currentVersionDate.rawValue) as? NSDate
        activationNb = defaults.object(forKey: UserDefaultKeys.activationNb.rawValue) as? Int ?? 0
        currentActivationNb = defaults.object(forKey: UserDefaultKeys.currentActivationNb.rawValue) as? Int ?? 0
        previousVersion = defaults.object(forKey: UserDefaultKeys.previousVersion.rawValue) as? String ?? ""

    }
    
    /// rend true si une demande de revue doit être effectuée
    private func rule1()->Bool{
        guard !DEBUG else { return true }

        
        return timeSince(date: currentVersionDate) > minimumTimeSinceCurrentActivation && ( (activationNb > maximumActivationNumber) || (currentActivationNb > minimumActivationNumber && achievements > minimumAchievementsNeeded))
    }
    
    /// retourne le temps écoulé en jour depuis la date, infini si la date n'existe pas
    private func timeSince( date : NSDate?) -> Double {
        guard date != nil else {
            return Double.infinity
        }
        return NSDate().timeIntervalSince(date! as Date) / 3600 / 24
    }
    
    /// retourne la version de l'app (like "1.2")
    class func appVersion()->String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }
    
    // MARK: ReviewDisplayDelegate
    
    
    func displayMessage(msg: String, negatifChoice neg : String?) {
        let name = Bundle.main.appName
        // -- partie à remplacer à cause de déprécation --
        let alrt = UIAlertView(
            title: name,
            message: msg,
            delegate: self,
            cancelButtonTitle: "Oui",
            otherButtonTitles:   neg ?? "Non")
        alrt.show()
        
        //--- partie en cours d'écriture utilisant l'AlertViewCOntroller ------
//        let alrt = UIAlertController.yesNoAlert(title   :name,
//                                                message :msg,
//                                                yesAction:{},
//                                                noAction:{}
//        )
//        //TODO: mettre les actions ici
//        //comment trouver le viewController?
//        UIApplication.shared.keyWindow?.rootViewController?.present(alrt, animated:true)
 
    }
    
 
    @discardableResult func performReview() -> Bool {
        
//        let name = Bundle.main.appName
        let appStoreLink = "itms-apps://itunes.apple.com/app/id\(appId)" //"itms-apps://itunes.apple.com/us/app/keynote/id361285480?mt=8"
        
        let url = NSURL(string: appStoreLink )
        return UIApplication.shared.openURL(url! as URL)
    }
    
    
    func performFeedback( mail mailAdresse : String, finalDecision :   @escaping (UserSatisfaction )-> Void  ) {
        // Si impossible d'envoyer de mail, on laisse tomber sans décision
        guard MFMailComposeViewController.canSendMail() else {
            finalDecision( .none )
            return }
        
        // on prépare le composeur de mail
        let mailComp = MFMailComposeViewController()
        mailComp.mailComposeDelegate = self
        mailComp.setSubject(" \(Bundle.main.appName) - Appli version \(previousVersion)  - Feedback ")
        mailComp.setToRecipients( [ mailAdresse ] )

        feedbackCallback = finalDecision
        
        // on trouve le controlleur actif et on lui fait afficher le composeur de mail
        let appDelegate =  UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController?.present(mailComp, animated: true, completion: nil)
        // le délégué du composeur de mail appellera finalDecision() via feedbackCallback
    }
    
    
// MARK: MFComposeMailControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result
        {
        case .cancelled, .failed, .saved:
            print("Feedback Mail composer Result: canceled or Failed or Saved")
            feedbackCallback( UserSatisfaction.unsatisfiedDeclinedFeedback )

        case .sent:
            print("Feedback Mail composer Result: sent")
            feedbackCallback( UserSatisfaction.unsatisfiedDidFeedback )
        
        }

        controller.dismiss(animated: true, completion: nil)
    }
    

    // MARK: UIALertviewdelegate

    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        switch displayStatus {
        case .question1:
            userLikeDecision(decision: buttonIndex == 0) //le bouton OUI est à gauche en premier
         case .question2Positif:
            userReviewDecision(decision: buttonIndex == 0) //le bouton OUI est à gauche en premier
           case .question2Negatif:
            userFeedbackDecision(decision: buttonIndex == 0) //le bouton OUI est à gauche en premier
        default: break
        }
    }
    
} //end class ReviewManager

