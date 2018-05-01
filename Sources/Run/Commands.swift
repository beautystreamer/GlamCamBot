import Vapor
import Console
import FluentProvider
import Jay
import Dispatch
import Foundation
import HTTP

let NOTIFICATION_HOUR = 9
let SECONDS_IN_HOUR: TimeInterval = 60 * 60

let fbIdLilia = "1967947763279176"
let fbIdDmitry = "1547115702068142"

final class CreateSessionCommand: Command, ConfigInitializable {
    public let id = "create_session"
    public let help = ["This command creates opentok session for live video user"]
    public let console: ConsoleProtocol
    
    public init(console: ConsoleProtocol) {
        self.console = console
    }
    
    public convenience init(config: Config) throws {
        let console = try config.resolveConsole()
        self.init(console: console)
    }
    
    public func run(arguments: [String]) throws {
        // no need for location
        // no need for p2p2
        let url = "https://api.opentok.com/session/create"
        let jwtHeader: [String: Any] = ["ist": "46092422",
                                        "iss": "fca937380264e661417c44e3641d7d3d36cb62db",
                                        "iat": Int(Date().timeIntervalSince1970),
                                        "exp": Int(Date().addingTimeInterval(SECONDS_IN_HOUR).timeIntervalSince1970),
                                        "jti": "borisrocks"]
        
        let data = Data(try Jay().dataFromJson(anyDictionary: jwtHeader))
//        let data Data(try! requestJSON.makeBytes()
        
        guard let jwtHeaderString = String(data: data, encoding: String.Encoding.utf8) else {
            return
        }
        print(jwtHeaderString)
        
        let headers: [HeaderKey: String] = ["Accept": "application/json",
                                            "X-OPENTOK-AUTH": jwtHeaderString]
        
        let result = try drop.client.post(url, query: [:], headers, nil, through: [])
        print(result)
    }
}

final class TestPayments: Command, ConfigInitializable {
    public let id = "test_payments"
    public let help = ["This command does payments for the shows."]
    public let console: ConsoleProtocol
    
    public init(console: ConsoleProtocol) {
        self.console = console
    }
    
    public convenience init(config: Config) throws {
        let console = try config.resolveConsole()
        self.init(console: console)
    }
    
    public func run(arguments: [String]) throws {
        guard arguments.count > 0 else {
            analytics?.logError("Missed argument: facebookId")
            return
        }
        
        let fbId = arguments[0]
        let price = "50"
        let spot = 2
        
        drop.send(message: "Hannalee has *chosen you to be on the next show!* Spring makeup",
                  senderId: fbId, 
                  messagingType: .NON_PROMOTIONAL_SUBSCRIPTION)
//        drop.send(message: "There are \(spot.string) spots left to be on the show",
//                  senderId: fbId,
//                  messagingType: .NON_PROMOTIONAL_SUBSCRIPTION)
        
        let textClaimYourSpot = "You have an hour to claim your spot for $\(price) ... There are only \(spot.string) spots left"
        let quickReplies = [Reply.getYes(), Reply.getNo()]
        drop.send(message: textClaimYourSpot,
                  senderId: fbId,
                  messagingType: .RESPONSE,
                  quickReplies: quickReplies)
    }
}

final class TestShopping: Command, ConfigInitializable {
    public let id = "do_shopping"
    public let help = ["This command does shopping experience"]
    public let console: ConsoleProtocol
    private let fbId = fbIdLilia
    
    public init(console: ConsoleProtocol) {
        self.console = console
    }
    
    public convenience init(config: Config) throws {
        let console = try config.resolveConsole()
        self.init(console: console)
    }
    
    public func run(arguments: [String]) throws {
        guard arguments.count > 0 else {
            analytics?.logError("Missed argument: facebookId")
            return
        }
        
        let fbId = arguments[0]
        
        drop.send(message: "Thanks for watching! This is Hanna's final look from today's show", senderId: fbId, messagingType: .NON_PROMOTIONAL_SUBSCRIPTION)
        let title = "I'm sure you'd love to know all the products Hanna used today"
        let subtitle = ""
        let buttonYes = ["type": "postback", "title": "Yes", "payload": POSTBACK_SHOW_ME_PRODUCTS]
        let buttonNo = ["type": "postback", "title": "No", "payload": QUICK_REPLY_NO_PAYMENT]
        let url = "https://app.box.com/shared/static/rlk1ig77xlmfon8psaohat2m0ryji471.png"
        let elements = drop.carouselElement(title: title, imageUrl: url, subtitle: subtitle, buttons: [buttonYes, buttonNo])
        drop.send(attachment: drop.genericAttachmentImageRatioSquare(elements: [elements]),
                  senderId: fbId,
                  messagingType: .NON_PROMOTIONAL_SUBSCRIPTION)
    }
}

final class TestCustomCommand: Command, ConfigInitializable {
    public let id = "test_command"
    public let help = ["This command does things, like foo, and bar."]
    public let console: ConsoleProtocol
    private let fbId = fbIdLilia
    
    public init(console: ConsoleProtocol) {
        self.console = console
    }
    
    public convenience init(config: Config) throws {
        let console = try config.resolveConsole()
        self.init(console: console)
    }
    
    public func run(arguments: [String]) throws {
        drop.send(message: "Check out three lucky giveaway winners", senderId: fbId, messagingType: .NON_PROMOTIONAL_SUBSCRIPTION)
        let winnersImageUrl = "https://app.box.com/shared/static/acu08e8dpf3gg4x3tphzllwj6ngg9xji.png"
        guard let attachmentId = drop.getAttachmentIdFor(url: winnersImageUrl) else {
            analytics?.logError("Failed to create FB attachment for \(winnersImageUrl)")
            return
        }
        drop.send(attachmentId: attachmentId, senderId: fbId, messagingType: .NON_PROMOTIONAL_SUBSCRIPTION)

        let quickReply = ["content_type": "text", "title": "Sure, opt me in", "payload": "QUICK_REPLY_GIVEAWAYS_OPT_IN"]
        drop.send(message: "Do you want to be notified about other giveaways?",
                  senderId: fbId,
                  messagingType: .NON_PROMOTIONAL_SUBSCRIPTION,
		  quickReplies: [quickReply])
    }

}

final class WhitelistDomainsCommand: Command, ConfigInitializable {
    public let id = "whitelist_domains"
    public let help = ["This command updates whitelist of domains"]
    public let console: ConsoleProtocol
    
    public init(console: ConsoleProtocol) {
        self.console = console
    }
    
    public convenience init(config: Config) throws {
        let console = try config.resolveConsole()
        self.init(console: console)
    }
    
    public func run(arguments: [String]) throws {
        drop.whiteListDomains()
    }
}

final class UpdateBotMenuCommand: Command, ConfigInitializable {
    public let id = "update_bot_menu"
    public let help = ["This command update bot menu"]
    public let console: ConsoleProtocol
        
    public init(console: ConsoleProtocol) {
        self.console = console
    }
    
    public convenience init(config: Config) throws {
        let console = try config.resolveConsole()
        self.init(console: console)
    }
    
    public func run(arguments: [String]) throws {
        console.print("running custom command...")
        drop.reinitializeMenu()
    }
}

final class CountSubscribersCommand: Command, ConfigInitializable {
    public let id = "count_subscribers"
    
    public let help = ["This command counts number of users that are subscribed and count of users that are unsubscribed and posts it to kibana product index as \"total_subscribed\" and \"total_unsubscribed\""]
    public let console: ConsoleProtocol
    
    public init(console: ConsoleProtocol) {
        self.console = console
    }
    
    public convenience init(config: Config) throws {
        let console = try config.resolveConsole()
        self.init(console: console)
    }
    
    func countSubscribers() {
        let sevenDaysAgo = Int(Date().addingTimeInterval(-7 * 24 * SECONDS_IN_HOUR).timeIntervalSince1970)
        guard let countOfUsers = Subscriber.countOfSubscribers(),
            let countOfSubscribed = Subscriber.countOfSubscribersWith(status: .subscribed),
            let countOfUsersIgnoringBroadcastsForAWeek = Subscriber.countSubscribedUsersIgnoringBroadcastAfter(broadcastDate: sevenDaysAgo) else {
                analytics?.logError("Failed to get count of users and subscribers.")
                return
        }
        let countOfUnsubscribed = countOfUsers - countOfSubscribed
        
        analytics?.logEvent(event: .TotalSubscribed, withIntValue: countOfSubscribed)
        analytics?.logEvent(event: .TotalUnsubscribed, withIntValue: countOfUnsubscribed)
        analytics?.logEvent(event: .TotalUsersIgnoringBroadcastsForWeek, withIntValue: countOfUsersIgnoringBroadcastsForAWeek)
        
        analytics?.logDebug("Count of subscribed users = \(countOfSubscribed), \ncount of unsubscribed users = \(countOfUnsubscribed)")
    }
    
    public func run(arguments: [String]) throws {
        let date = Date()
        analytics?.logDebug("Running command=\(id), time is now \(date)")
        countSubscribers()
        
        // Make delay for send async request to analytics
        sleep(5)
        
        analytics?.logDebug("Done with \(self.id) command!")
    }
}

let joshAlexMuaImageLink = "https://app.box.com/shared/static/b7d2guezk70rax0k2edc7hjpl9alhumt.png"

//"1382813958485356","1413288802110676","1443873859058366","1471007193003552","1499805296809695","1499805296809695","1555685434548776","1555685434548776","1559708084149340","1577826605605503","1577826605605503","1577826605605503","1577826605605503","1577826605605503",
let joshalexMuaLottery =
    Set(["1599264263524145","1599264263524145","1599264263524145","1599264263524145","1614992838556085","1624098084371545","1625057720945731","1643817302372204","1645899538813290","1645899538813290","1661377593976374","1664689510288780","1664689510288780","1683599085058257","1686232888134692","1692215764199196","1693331197428031","1704046489676910","1726631007416353","1735000543209612","1735542326493114","1735542326493114","1744816045577579","1760060750699734","1776783965715558","1777779448911976","1785598134836301","1798793153474901","1798793153474901","1871086532966321","1876079029077585","1880666645311084","1882384051772829","1891554460915444","1900561850017399","1909999345741079","1958139237543112","2041725519200875","2119792954712361","2160551300623493"])

let tailorMadeJaneLottery =
["1275083239258901", "1306278182807319", "1325317957569456", "1350342191732293", "1357020151064133", "1382813958485356", "1388019701302312", "1399042983535414", "1399625000141839", "1402989676474452", "1427003040761153", "1433020753469850", "1462049117257107", "1462062757237653", "1465145736930332", "1471170009677747", "1472481092874615", "1476655265789653", "1480381918737215", "1482412988535207", "1491202651006486", "1499995026778245", "1519204328191754", "1520197651443355", "1525590847567414", "1531295270325909", "1531583963612269", "1542410295858352", "1547115702068142", "1556165254499897", "1556314221132395", "1559415070824097", "1573025766130089", "1575744322522707", "1577320815722421", "1577826605605503", "1585333758187021", "1591960007589144", "1592582004172006", "1599319596852224", "1601291379908443", "1602403566546902", "1604098742972952", "1608760932526574", "1608924485852760", "1609122869194574", "1616777818399335", "1619293854857297", "1622238937872409", "1624098084371545", "1628825570570304", "1631018063614362", "1631990156886866", "1632740896845332", "1634169840006459", "1634436253305574", "1636127899774693", "1636574099761206", "1639619309407782", "1641440915951879", "1641752582567005", "1642826982502509", "1644667365618574", "1645899538813290", "1651011574989679", "1655569357845646", "1657080064406919", "1658658284202433", "1659014817521073", "1659290754187696", "1664812423599396", "1665293056841303", "1667871283293763", "1671285352960838", "1679509755446145", "1680547775373128", "1683599085058257", "1701517669941994", "1717120711683369", "1727055457370775", "1731987800227958", "1733536976677017", "1739945116044656", "1747038242020598", "1747546088641570", "1753973814663155", "1757507790994589", "1758145427541009", "1761647753898261", "1776815922376971", "1777974858925404", "1794241000628661", "1794356477294297", "1798065490270220", "1802700216461007", "1811138725602950", "1814115901980832", "1815182758528015", "1820526751310907", "1830730796959083", "1832085963528818", "1832105683477092", "1832632280121021", "1835909569763625", "1848948318526081", "1863048053767745", "1863210417056341", "1870963382916317", "1872196546184618", "1875386705866313", "1877911382219451", "1879808918709492", "1881175061916473", "1886627201355511", "1888379331236308", "1889196924485669", "1889610427737976", "1892648600746058", "1899085613437807", "1899989030071596", "1907383592669501", "1915150231870882", "1918799534860387", "1922381724439189", "1931375603539432", "1944798325593973", "1952111171489387", "1956709437704349", "1963056013765399", "1969776149731607", "1976538275722134", "1997755566921416", "1999917086717344", "2005946796146445", "2017571608257369", "2022447257770810", "2032525140105736", "2062376190469600", "2064864153553862", "2077157932324447", "2099460360071614", "2111803388860044", "2118351004848965", "2137719549587893", "2139942096023959", "2224218154285629", "2281322795241452", "2300840879941579", "2329159467098065", "2329671537058920", "2422405001119158", "682106715246933", "684541965003484", "880882122036355", "886894961435378"]
