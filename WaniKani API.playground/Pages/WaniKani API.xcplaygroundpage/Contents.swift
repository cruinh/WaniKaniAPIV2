import Foundation
import PlaygroundSupport
import UIKit

let API_KEY = "45fdec99-a452-4dba-b169-55e042b0a4d9"

struct PagesInfo : Codable {
    var next_url : String?
    var previous_url : String?
    var per_page : Int
}

struct CharacterImage : Codable {
    var content_type : String
    var url : String
}

protocol ResourceCollection : Codable {
    associatedtype DataType: Resource
    var object : String { get }
    var url : String { get }
    var pages : PagesInfo { get }
    var total_count : Int { get }
    var data_updated_at : String { get }
    var data : [DataType] { get }
}

protocol Resource : Codable {
    associatedtype DataType: Codable
    var id : Int? { get }
    var object : String { get }
    var url : URL { get }
    var data_updated_at : String { get }
    var data : DataType { get }
}

protocol Endpoint : Codable {
    static var endpoint : String {get}
    static func matches(response: URLResponse) -> Bool
}

extension Endpoint where Self : ResourceCollection {
    //NOTE: expecting matching URLs to CONTAIN the value of 'endpoint' somewhere (probably not at the end)
    static func matches(response: URLResponse) -> Bool {
        guard let url : URL = response.url else { return false }
        return url.absoluteString.contains(endpoint)
    }
}

extension Endpoint where Self : Resource {
    //NOTE: expecting matching URLs to END WITH the value of 'endpoint'
    static func matches(response: URLResponse) -> Bool {
        guard let url : URL = response.url else { return false }
        return url.absoluteString.hasSuffix(endpoint)
    }
}

struct User : Endpoint, Resource {
    static var endpoint: String = "/user"
    
    var id : Int?
    var object : String
    var url : URL
    var data_updated_at : String
    var data : UserData
    
    struct UserData : Codable {
        var username : String
        var level : Int
        var started_at : String
        var subscribed : Bool
        var current_vacation_started_at : Date?
    }
}

struct SubjectsIndex : ResourceCollection, Endpoint { 
    static var endpoint: String = "/subjects"
    
    var object : String
    var url : String
    var pages : PagesInfo
    var total_count : Int
    var data_updated_at : String
    var data : [Subject]
}

struct MeaningInfo : Codable {
    var meaning : String
    var primary : Bool?
}

struct ReadingInfo : Codable {
    var reading : String
    var primary : Bool?
}

struct Subject : Endpoint, Resource {
    static var endpoint: String = "/subjects"
    
    var id: Int?
    var object : String
    var url : URL
    var data_updated_at : String
    var data : SubjectData
    struct SubjectData : Codable {
        var level : Int
        var created_at : String
        var slug : String?
        var character : String?
        var character_images: [CharacterImage]? //radicals only
        var meanings : [MeaningInfo]? //kanji or vocab
        var readings : [ReadingInfo]? //kanji or vocab
        var parts_of_speech: [String]? //vocab
        var subject_component_ids: [Int]? //kanji or vocab
        var document_url : String
    }
}

struct AssignmentsIndex : Endpoint, ResourceCollection {
    static var endpoint: String = "/assignments"
    
    var object : String
    var url : String
    var pages : PagesInfo
    var total_count : Int
    var data_updated_at : String
    var data : [Assignment]
}

struct Assignment : Resource {
    var id : Int?
    var object : String
    var url : URL
    var data_updated_at : String
    var data : AssignmentData
    
    struct AssignmentData : Codable {
        var subject_id : Int
        var subject_type : String
        var level : Int
        var srs_stage : Int
        var srs_stage_name : String
        var unlocked_at : String?
        var started_at : String?
        var passed_at : String?
        var burned_at : String?
        var available_at : String?
        var passed: Bool
        var resurrected: Bool
    }
}

struct ReviewStatisticsIndex: ResourceCollection, Endpoint {
    static var endpoint: String = "/review_statistics"
    
    var object : String
    var url : String
    var pages : PagesInfo
    var total_count : Int
    var data_updated_at : String
    var data : [ReviewStatistics]
}

struct ReviewStatistics: Resource, Endpoint {
    static var endpoint: String = "/review_statistics"
    
    var id : Int?
    var object: String
    var url : URL
    var data_updated_at : String
    var data : ReviewStatisticsData
    
    struct ReviewStatisticsData : Codable {
        var created_at : String
        var subject_id : Int
        var subject_type : String
        var meaning_correct : Int
        var meaning_incorrect : Int
        var meaning_max_streak : Int
        var meaning_current_streak : Int
        var reading_correct : Int
        var reading_incorrect : Int
        var reading_max_streak : Int
        var reading_current_streak : Int
        var percentage_correct : Int
    }
}

struct StudyMaterialsIndex : Endpoint, ResourceCollection {
    static var endpoint: String = "/study_materials"
    
    var object : String
    var url : String
    var pages : PagesInfo
    var total_count : Int
    var data_updated_at : String
    var data : [StudyMaterial]
}

struct StudyMaterial : Endpoint, Resource {
    static let endpoint: String = "/study_materials"
    
    var id : Int?
    var object: String
    var url : URL
    var data_updated_at : String
    var data : StudyMaterialData
    
    struct StudyMaterialData : Codable {
        var created_at : String
        var subject_id : Int
        var subject_type : String
        var meaning_note : String?
        var reading_note : String?
        var meaning_synonyms : [String]
    }
}

struct Summary : Endpoint {
    static let endpoint: String = "/summary"
    
    var object : String
    var url : String
    var data_updated_at : String
    var data : SummaryData
    
    struct SummaryData : Codable {
        var review_subject_ids: [Int]
        var lesson_subject_ids: [Int]
        var reviews_per_hour : [ReviewSummary]
    }
    
    struct ReviewSummary : Codable {
        var available_at : String
        var subject_ids : [Int]
    }
    
    //NOTE: expecting matching URLs to END WITH the value of 'endpoint'
    static func matches(response: URLResponse) -> Bool {
        guard let url : URL = response.url else { return false }
        return url.absoluteString.hasSuffix(endpoint)
    }
}

struct ReviewsIndex : Endpoint, ResourceCollection {
    static var endpoint: String = "/reviews"
    
    var object : String
    var url : String
    var pages : PagesInfo
    var total_count : Int
    var data_updated_at : String
    var data : [Review]
}

struct Review : Endpoint, Resource {
    static let endpoint: String = "/reviews"
    
    var id : Int?
    var object: String
    var url : URL
    var data_updated_at : String
    var data : ReviewData
    
    struct ReviewData : Codable {
        var created_at : String
        var assignment_id : Int
        var starting_srs_stage : Int
        var starting_srs_stage_name : String
        var incorrect_meaning_answers : Int?
        var incorrect_reading_answers : Int?
    }
}

struct LevelProgressionIndex : Endpoint, ResourceCollection {
    static var endpoint: String = "/level_progression"
    
    var object : String
    var url : String
    var pages : PagesInfo
    var total_count : Int
    var data_updated_at : String
    var data : [LevelProgression]
}

struct LevelProgression : Endpoint, Resource {
    static let endpoint: String = "/level_progression"
    
    var id : Int?
    var object: String
    var url : URL
    var data_updated_at : String
    var data : ReviewData
    
    struct ReviewData : Codable {
        var created_at : String
        var level : Int
        var unlocked_at : String?
        var started_at : String?
        var passed_at : String?
        var completed_at : String?
        var abandoned_at : String?
    }
}

struct Account : Codable {
    static let storageKey : String = "waniKaniAccount"
    var user : User?
    var summary : Summary?
    var subjectsIndex : SubjectsIndex?
    var assignmentsIndex : AssignmentsIndex?
    var reviewStatisticsIndex : ReviewStatisticsIndex?
    var studyMaterialsIndex : StudyMaterialsIndex?
    var reviewsIndex : ReviewsIndex?
    var levelProgressionIndex : LevelProgressionIndex?
}

struct ResponseHandler<T:Endpoint> {
    func decode(_ response: URLResponse, _ data: Data) throws -> T? {
        if T.matches(response: response) {
            let stringData = String(data: data, encoding: .utf8)
            return try Decoder<T>.decode(data,response)
        } else {
            return nil
        }
    }
}

struct Decoder<T:Endpoint> {
    static func decode(_ data: Data?, _ response: URLResponse?) throws -> T? {
        guard let data = data, let response = response else { return nil}
        
        let jsonDecoder = JSONDecoder()
        let result = try jsonDecoder.decode(T.self, from: data) as? T
        return result
    }
    
    static func defaultOutput(forData data: Data?) -> String {
        guard let data = data else { return "(empty response)" }
        return String(data: data, encoding: .utf8) ?? "(error decoding data)"
    }
}

class WaniKaniSDK {
    var apiKey : String
    var account = Account()
//      let endpoints : [String] = ["\(User.endpoint)","\(SubjectsIndex.endpoint)","\(AssignmentsIndex.endpoint)","\(ReviewStatistics.endpoint),"\(StudyMaterialsIndex.endpoint),\(Summary.endpoint),\(ReviewsIndex.endpoint)"]
    let endpoints : [String] = ["\(ReviewsIndex.endpoint)"]
    var outstandingRequests = [URL: URLSessionDataTask]()
    var refreshCompletion : ((Error?)->Void)?
    var responseLoggingAction : ((String?)->Void)?
    var decodeErrorAction : ((Error?)->Void)?
    var rawResponses = [URL:Data]()
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func refreshAccount(completion: ((Error?)->Void)?) {
        self.refreshCompletion = completion
        for endpoint in endpoints {
            if let task = makeRequest(endpoint: endpoint, completion: responseHandler) {
                if let url = task.originalRequest?.url {
                    outstandingRequests[url] = task
                }
            }
        }
    }
    
    func responseHandler(_ response: URLResponse?, _ data: Data?, _ error:Error?) {
        var message = "\n[==RESPONSE==]:\(String(describing:response))"
        message = message + "\n[==DATA==]:\(String(describing:data))"
        if let error = error {
            message = message + "\n[==ERROR==]:\(String(describing:error))"
        }
        if let data = data, let text = String(data: data, encoding: .utf8) {
            message = message + "\n[==TEXT==]: " + text
        }
        responseLoggingAction?(message)
        
        DispatchQueue.main.async { [weak self] in
            do {
                try self?.populateAccount(response: response, data: data)
            }
            catch {
                self?.decodeErrorAction?(error)
            }
            
            if let response = response {
                self?.endTask(forResponse: response)
            }
        }
    }
    
    func endTask(forResponse response: URLResponse) {
        if let url = response.url {
            outstandingRequests.removeValue(forKey: url)
        }
        if outstandingRequests.count == 0, let completion = refreshCompletion {
            completion(nil)
            refreshCompletion = nil
        }
    }
    
    private func makeRequest(endpoint: String, showResponse: Bool = false, completion: ((URLResponse?, Data?, Error?)->Void)? = nil) -> URLSessionDataTask? {
        
        let urlSession = URLSession.shared
        let urlString = "https://www.wanikani.com/api/v2" + endpoint
        
        if let url = URL(string: urlString) {
            var urlRequest = URLRequest(url: url)
            urlRequest.addValue("Token token=\(apiKey)", forHTTPHeaderField: "Authorization")
            
            let task = urlSession.dataTask(with: urlRequest, completionHandler: { [weak self] (data, response, error) in
                completion?(response, data, error)
            })
            task.resume()
            return task
        } else {
            return nil
        }
    }
    
    func populateAccount(response response: URLResponse?, data data: Data?) throws {
        guard let data = data, let response = response else { return }
        
        if let dto = try ResponseHandler<User>().decode(response, data) { 
            account.user = dto
            return
        }
        if let dto = try ResponseHandler<SubjectsIndex>().decode(response, data) { 
            account.subjectsIndex = dto
            return
        }
        if let dto = try ResponseHandler<AssignmentsIndex>().decode(response, data) { 
            account.assignmentsIndex = dto
            return
        }
        if let dto = try ResponseHandler<ReviewStatisticsIndex>().decode(response, data) { 
            account.reviewStatisticsIndex = dto
            return
        }
        if let dto = try ResponseHandler<StudyMaterialsIndex>().decode(response, data) {
            account.studyMaterialsIndex = dto
            return
        }
        if let dto = try ResponseHandler<Summary>().decode(response, data) {
            account.summary = dto
            return
        }
        if let dto = try ResponseHandler<ReviewsIndex>().decode(response, data) {
            account.reviewsIndex = dto
            return
        }
        if let dto = try ResponseHandler<LevelProgressionIndex>().decode(response, data) {
            account.levelProgressionIndex = dto
            return
        }
    }
}

class APIViewController : UIViewController {
    let textView = UITextView()
    let toolsView = UIView()
    var waniKani : WaniKaniSDK?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "WaniKani API"
        
        enableResponseLogging(false)
        enableDecoderErrorLogging(false)
        
        _setupUI()
    }
    
    func responseLoggingEnabled() -> Bool {
        return (waniKani?.responseLoggingAction != nil)
    }
    
    func enableResponseLogging(_ enable: Bool = true) {
        if enable {
            waniKani?.responseLoggingAction = appendToTextView
        } else {
            waniKani?.responseLoggingAction = nil
        }
    }
    
    func decoderErrorLoggingEnabled() -> Bool {
        return (waniKani?.decodeErrorAction != nil)
    }
    
    func enableDecoderErrorLogging(_ enable: Bool = true) {
        if enable {
            waniKani?.decodeErrorAction = appendToTextView
        } else {
            waniKani?.decodeErrorAction = nil
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshAccount()
    }
    
    func refreshAccount() {
        guard waniKani?.outstandingRequests.count == 0 else { return }
        textView.text = nil
        waniKani?.refreshAccount() { [weak self] (error) in
            if let error = error {
                let errorText = String(describing:error)
                self?.appendToTextView(string:errorText)
            } else if let account = self?.waniKani?.account {
                self?.appendToTextView(account:account)
                self?.storeAccountDataInSwiftPlayground()
            }
        }
    }
    
    func storeAccountDataInSwiftPlayground() {
        //If PlaygroundKeyValueStore is an "unresolved identifier", just comment out the content of this function.  It's meant for the iOS Swift Playgrounds app.
//        do {
//            let accountData = try JSONEncoder().encode(account)
//            PlaygroundKeyValueStore.current[Account.storageKey] = .data(accountData)
//        } catch {
//            simpleAlert(title: "Error", message: "Failed to encode account for storage")
//        }
    }
    
    private func _setupUI() {
        toolsView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolsView)
        view.addSubview(textView)
        
        var viewsDict = ["toolsView":toolsView, "textView":textView]
        var constraints = [NSLayoutConstraint]()
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[toolsView]-0-|", options: [], metrics: nil, views: viewsDict))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[textView]-0-|", options: [], metrics: nil, views: viewsDict))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[toolsView(50)]-0-[textView]-0-|", options: [], metrics: nil, views: viewsDict))
        view.addConstraints(constraints)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Menu", style: .plain, target: self, action: #selector(menuButtonTapped))
    }
    
    @objc func menuButtonTapped() {
        let actionSheet = UIAlertController(title: "Menu", message: nil, preferredStyle: .alert)
        actionSheet.addAction(UIAlertAction(title: "Toggle Request Logging", style: .default) { [ weak self ](alertAction) in
            guard self != nil else { return }
            if self?.responseLoggingEnabled() == true {
                self?.enableResponseLogging(false)
                self?.simpleAlert(title: "OK", message: "Response Logging Disabled")
            } else {
                self?.enableResponseLogging(true)
                self?.simpleAlert(title: "OK", message: "Response Logging Enabled")
            }
        })
        actionSheet.addAction(UIAlertAction(title: "Toggle Decoder Error Logging", style: .default) { [ weak self ](alertAction) in
            guard self != nil else { return }
            if self?.decoderErrorLoggingEnabled() == true {
                self?.enableDecoderErrorLogging(false)
                self?.simpleAlert(title: "OK", message: "Decoder Error Disabled")
            } else {
                self?.enableDecoderErrorLogging(true)
                self?.simpleAlert(title: "OK", message: "Decoder Error Enabled")
            }
        })
        actionSheet.addAction(UIAlertAction(title: "Refresh", style: .default) { [weak self] (alertAction) in 
            self?.refreshAccount()
        })
        present(actionSheet, animated: true, completion: nil)
    }
    
    func appendToTextView(string: String?) {
        guard let string = string else { return }
        DispatchQueue.main.async { [weak self] in
            var text = self?.textView.text ?? ""
            text = text + "\n\n" + string
            self?.textView.text = text
        }
    }
    
    func appendToTextView(error: Error?) {
        guard let error = error else { return }
        let errorString = "[==ERROR==]:" + String(describing:error)
        appendToTextView(string:errorString)
    }
    
    func appendToTextView(data: Data?) {
        guard let data = data else { return }
        var text = String(data: data, encoding: .utf8)
        appendToTextView(string:text)
    }
    
    func appendToTextView(account: Account?) {
        guard let account = account else { return }
        var text = textView.text ?? ""
        text = text + "\n\nAccount Info: "
        if let user = account.user {
            text = text + "\n\n User: \(user)"
        }
        if let subjectsIndex = account.subjectsIndex {
            text = text + "\n\n Subjects Index: \(subjectsIndex)"
        }
        if let assignments = account.assignmentsIndex {
            text = text + "\n\n Assignments Index: \(assignments)"
        }
        if let reviewStatisticsIndex = account.reviewStatisticsIndex {
            text = text + "\n\nReview Statistics:"
            text = text + "\n\t\(reviewStatisticsIndex)"
        }
        if let studyMaterialsIndex = account.studyMaterialsIndex {
            text = text + "\n\nStudy Materials Index:"
            text = text + "\n\t" + String(describing:studyMaterialsIndex)
        }
        if let summary = account.summary {
            text = text + "\n\nSummary:"
            text = text + "\n\t" + String(describing:summary)
        }
        textView.text = text
    }
    
    func simpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}

var vc = APIViewController()
vc.waniKani = WaniKaniSDK(apiKey: API_KEY)
var navController = UINavigationController(rootViewController: vc)
PlaygroundPage.current.liveView = navController

//TODO : \/\/\/-USE THIS PATTERN-\/\/\/
//  func doSomething<T>(type: T.Type) {
//      switch type {
//      case is String.Type:
//          print("It's a String")
//      case is Int.Type:
//          print("It's an Int")
//      default:
//          print("Wot?")
//      }
//  }
