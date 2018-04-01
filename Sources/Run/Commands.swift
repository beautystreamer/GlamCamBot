import Vapor
import Console
import FluentProvider
import Jay
import Dispatch
import Foundation

let NOTIFICATION_HOUR = 9
let SECONDS_IN_HOUR: TimeInterval = 60 * 60

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
//        let url = "https://api.opentok.com/session/create"
    }
}

final class TestCustomCommand: Command, ConfigInitializable {
    public let id = "test_command"
    public let help = ["This command does things, like foo, and bar."]
    public let console: ConsoleProtocol
    
    public init(console: ConsoleProtocol) {
        self.console = console
    }
    
    public convenience init(config: Config) throws {
        let console = try config.resolveConsole()
        self.init(console: console)
    }
    
    public func run(arguments: [String]) throws {
//        analytics?.logDebug("run test_command")

//        Failed to get user for 1850326234979570, with response = Response
//        Failed to get user for 1717736071640715, with response = Response
//        Failed to get user for 1931060236906687, with response = Response
//        Failed to get user for 2082429255106513, with response = Response
//        Failed to get user for 1687492171316662, with response = Response
//        Failed to get user for 1556608927789238, with response = Response
//        Failed to get user for 1768205673237082, with response = Response
//        Failed to get user for 1452910868129020, with response = Response
//        Failed to get user for 1863033630388135, with response = Response
//        Failed to get user for 1490026004441683, with response = Response
//        Failed to get user for 1552854668146890, with response = Response
//        Failed to get user for 1722227064490817, with response = Response
//        Failed to get user for 1609853845803000, with response = Response
//        Failed to get user for 1781068298623141, with response = Response
//        Failed to get user for 2096457477037518, with response = Response
        // 1752607618137334
        // 1762412400447427
//        Failed to get user for 1703283119733003, with response = Response
//        Failed to get user for 1518599604917918, with response = Response
        drop.handleNewUserFlow(fb_messenger_id: "1703283119733003", user_ref: "HannaLee")
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

