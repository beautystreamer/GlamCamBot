import Foundation

class Reply {
    public static func testQuickReply() -> [String: Any] {
        return ["content_type": "text", "title": "Test", "payload": POSTBACK_GET_STARTED]
    }
    
    public static func optInNextShow() -> [String: Any] {
        // i want to be on the next show
        return ["content_type": "text", "title": "count me in!", "payload": POSTBACK_BOT_COUNT_ME_IN]
    }
}
