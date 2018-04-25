import Foundation

class Reply {
    public static func testQuickReply() -> [String: Any] {
        return ["content_type": "text", "title": "Test", "payload": POSTBACK_GET_STARTED]
    }
    
    public static func optInNextShow() -> [String: Any] {
        // i want to be on the next show
        return ["content_type": "text", "title": "count me in!", "payload": POSTBACK_BOT_COUNT_ME_IN]
    }
    
    public static func getYes() -> [String: Any] {
        return ["content_type": "text", "title": "Yes", "payload": QUICK_REPLY_YES_PAYMENT]
    }
    
    public static func getNo() -> [String: Any] {
        return ["content_type": "text", "title": "No", "payload": QUICK_REPLY_NO_PAYMENT]
    }
    
}
