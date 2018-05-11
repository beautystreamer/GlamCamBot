import Vapor
import Console
import FluentProvider
import Jay
import Dispatch
import Foundation
import HTTP

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
        let testArray = [arguments[0]]
        
        for fbId in testArray{
            
            let price = "50"
            
            drop.send(message: "Great news, Hanna is hosting a private makeup class with four guests",
                      senderId: fbId,
                      messagingType: .NON_PROMOTIONAL_SUBSCRIPTION)
            drop.send(message: "Grab one of the two spots left.....",
                      senderId: fbId,
                      messagingType: .NON_PROMOTIONAL_SUBSCRIPTION)
            let title = "Sign up and pay $\(price) to join the class"
            
            let subtitle = ""
            let buttonYes = ["type": "postback", "title": "I'd love to", "payload": POSTBACK_YES_PAYMENT]
            let buttonNo = ["type": "postback", "title": "No thanks", "payload": POSTBACK_NO_PAYMENT]
            //let url = "https://app.box.com/shared/static/rlk1ig77xlmfon8psaohat2m0ryji471.png"
            let elements = drop.carouselElement(title: title, subtitle: subtitle, buttons: [buttonYes, buttonNo])
            drop.send(attachment: drop.genericAttachmentImageRatioSquare(elements: [elements]),
                      senderId: fbId,
                      messagingType: .NON_PROMOTIONAL_SUBSCRIPTION)
        }
    
    }
}

final class TestShopping: Command, ConfigInitializable {
    public let id = "do_shopping"
    public let help = ["This command does shopping experience"]
    public let console: ConsoleProtocol
    
    public init(console: ConsoleProtocol) {
        self.console = console
    }
    
    public convenience init(config: Config) throws {
        let console = try config.resolveConsole()
        self.init(console: console)
    }
    
    public func run(arguments: [String]) throws {
//        guard arguments.count > 0 else {
//            analytics?.logError("Missed argument: facebookId")
//            return
//        }
//
//        let fbId = arguments[0]
        
        for fbId in tailorMadeJaneShopping{
        let subscriber = drop.getSubOrUserProfileFor(senderId: fbId)
        if let response = drop.send(message: "Thanks for watching yesterday! Giveaway winners will be announced tomorrow!", senderId: fbId, messagingType: .RESPONSE), response.status != .ok {
            analytics?.logAnalytics(event: .BroadcastUndeliveredEvent, for: subscriber!)
        } else {
            analytics?.logAnalytics(event: .BroadcastDeliveredEvent, for: subscriber!)
        }
        
        drop.send(message: "In the meantime this is Tailor’s final look from yesterday's show", senderId: fbId, messagingType: .RESPONSE)
        let title = "I'm sure you'd love to know all the products Tailor used yesterday"
        let subtitle = ""
        let buttonYes = ["type": "postback", "title": "Yes", "payload": POSTBACK_SHOW_ME_PRODUCTS]
        let buttonNo = ["type": "postback", "title": "No", "payload": POSTBACK_DONT_SHOW_ME_PRODUCTS]
        let url = "https://app.box.com/shared/static/kw8hdefi95xayzrt6kjwddu5q3l0vdj1.png"
        let elements = drop.carouselElement(title: title, imageUrl: url, subtitle: subtitle, buttons: [buttonYes, buttonNo])
        drop.send(attachment: drop.genericAttachmentImageRatioSquare(elements: [elements]),
                  senderId: fbId,
                  messagingType: .RESPONSE)
            
        }
    }
}

final class TestBroadcast: Command, ConfigInitializable {
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
        for fbId in hannaLeeTestLilia{
            drop.send(message: "Check out six lucky giveaway winners", senderId: fbId, messagingType: .NON_PROMOTIONAL_SUBSCRIPTION)
            let winnersImageUrl = "https://app.box.com/shared/static/wgi9fvipjlu933cupqdmjvk83ursggxl.png"
            guard let attachmentId = drop.getAttachmentIdFor(url: winnersImageUrl) else {
                analytics?.logError("Failed to create FB attachment for \(winnersImageUrl)")
                return
            }
            drop.send(attachmentId: attachmentId, senderId: fbId, messagingType: .NON_PROMOTIONAL_SUBSCRIPTION)

            let winnersImageUrl2 = "https://app.box.com/shared/static/8a7ux3rrtvjzu5apb33aq7joevrhkga5.png"
            guard let attachmentId2 = drop.getAttachmentIdFor(url: winnersImageUrl2) else {
                analytics?.logError("Failed to create FB attachment for \(winnersImageUrl2)")
                return
            }
            drop.send(attachmentId: attachmentId2, senderId: fbId, messagingType: .NON_PROMOTIONAL_SUBSCRIPTION)

            let quickReply = ["content_type": "text", "title": "Sure, opt me in", "payload": "QUICK_REPLY_GIVEAWAYS_OPT_IN"]
            drop.send(message: "Do you want to be notified about other giveaways?",
                      senderId: fbId,
                      messagingType: .NON_PROMOTIONAL_SUBSCRIPTION,
              quickReplies: [quickReply])
        }
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


let hannalee_giveaway_may_1_30d = ["1503440883115804", "1426100020828636", "1465745073536024", "1577826605605503", "1634333039947696", "1681535525300507", "1682357761854549", "1435378149924398", "2079032792137147", "2203958566297997", "1307445859355917", "1407106632727404", "1590583771065155", "1621398364645665", "1634254766671247", "1763436230361147", "1917507414990236", "1919395264798337", "1920216874717866", "2277182348962213", "1111773228947597", "1200359743401098", "1226479004121332", "1480462505391843", "1518953108214990", "1581888261931987", "1634496303313765", "1651639004922383", "1665700220149988", "1668149806553975", "1691775244239708", "1692659830777697", "1697187960347965", "1748540835225642", "1766688893388562", "1852127834832497", "1881563945195340", "1888318921242600", "1902990976442080", "1967947763279176", "1988299721211865", "2075643985797433", "2088139027878066", "2159135127444830", "925401070917176", "977087329083231", "1208214495948859", "1219014474868367", "1227276787375138", "1267303730039141", "1327279447371713", "1346706695431508", "1462077613898018", "1500339113429217", "1520616021398037", "1536215186486905", "1536254136501812", "1547115702068142", "1555897771186836", "1563043663803021", "1563223537121392", "1567122513401695", "1567904659974428", "1569370049839912", "1576289869135743", "1594751753967602", "1596678653782621", "1597639943689921", "1606114459456678", "1610167369101841", "1612330812220024", "1622056821223029", "1638501476263070", "1647764378647005", "1650932061655012", "1651503688267071", "1656661097745024", "1663436350413508", "1671031852978584", "1673307912783511", "1686577691395666", "1691247287580827", "1699986566752943", "1708747572549956", "1719177861479745", "1721202754582392", "1725756770823446", "1734534529972382", "1737075116338945", "1737657092968679", "1739844159442919", "1740303936015687", "1741373445957548", "1779398765461074", "1788941157836661", "1807547522621769", "1818802018152691", "1819445638077179", "1826028197447892", "1834337309957082", "1841364162573120", "1856011364462614", "1863033630388135", "1880170705391677", "1889886704395266", "1896755950398290", "1897095970363299", "1903343316406806", "1916545605084746", "1919318714808619", "1925299617511268", "1938271936214023", "1941048835907617", "1945593642119943", "1970124813061494", "1971962489501029", "1997922320231926", "2039465059402163", "2048771671800084", "2054902281190694", "2146997931984768", "2389075051118490", "2410054352345575", "1197558127014427", "1204604102975650", "1207059579396930", "1237324179703816", "1277071669061913", "1316614635107062", "1327331687367668", "1336910403075382", "1349547375145474", "1391763754263668", "1400540340074865", "1403483303085937", "1410006579105325", "1437219283050604", "1451894028273081", "1455128021263761", "1459469610831643", "1466841150094409", "1468076346655055", "1487170974728353", "1489356691193249", "1507532136038865", "1516527061790112", "1517948344998388", "1519864861475035", "1520842584711003", "1539305576167756", "1556608927789238", "1556698637776291", "1559526824160327", "1580335472082332", "1582662581825635", "1590174254429456", "1599736793467365", "1601011249997788", "1603319599716953", "1611284582323583", "1618827324901737", "1620389211412502", "1624882144233614", "1624981857619468", "1625055187579205", "1630611746992068", "1630781306975379", "1633371616770227", "1638737219556556", "1639144872865278", "1639903816126780", "1641182699304054", "1643237209045752", "1644308422343958", "1648185691969423", "1651340918235123", "1652986968121019", "1653574004733890", "1654609104623681", "1655112321241389", "1659032410847839", "1660878850647724", "1661836410562356", "1661944813853096", "1664318230319161", "1666058653480570", "1668533736575258", "1669518289802851", "1669617709787106", "1670148179732323", "1672086576243348", "1672469379519072", "1672579232818560", "1673041156082461", "1676659999092190", "1677069269044684", "1684094541670855", "1686685951412335", "1687501068004966", "1690787847672472", "1693165877387195", "1693353287445996", "1693888494037336", "1700214520071072", "1701464383268125", "1703079039777854", "1703956679684036", "1707438912670912", "1708905349148264", "1711024072286668", "1711605502252682", "1711891762210563", "1717353705010490", "1721185954630885", "1722227064490817", "1722898577769573", "1729459277143056", "1731519190276334", "1731958913518538", "1734063589984198", "1735051626574157", "1735241333200733", "1737647562923122", "1738674422822225", "1743556952398753", "1750720158283724", "1750922188287258", "1752073571482091", "1754806034598719", "1757699324290552", "1759292967494685", "1764653170267301", "1765473606833012", "1769159916477694", "1770975196274442", "1772355599474423", "1775973855799238", "1776232999103390", "1780713401966957", "1786815194672070", "1794297623947108", "1796429227083099", "1803646029696360", "1803757999663472", "1808105119234837", "1808967455832465", "1812108182167665", "1818265434899634", "1818884631487785", "1822004764517310", "1822029547853325", "1824080660989905", "1833059280071325", "1835294159868946", "1839059459451715", "1839660479398066", "1841516212567808", "1845123612172918", "1861784283846040", "1863191843733595", "1864950583556524", "1865103883561163", "1869366313138540", "1873810732630558", "1874881322543519", "1875418455802648", "1881222958596313", "1882691218472882", "1882750348466905", "1884672218270202", "1885657291504939", "1887151228022637", "1894173757273095", "1895280873838449", "1896095840441373", "1896224747118955", "1907625739257053", "1909253425813941", "1909663039103894", "1912582802145556", "1916046848405427", "1917362098306039", "1918474294829929", "1919493088129365", "1929902170377378", "1930681180336908", "1933087513433236", "1934482309926895", "1936678113041029", "1941461305925773", "1942296032512161", "1942578242479020", "1943683369006884", "1944757078931998", "1947757181932932", "1949227591756656", "1953993548007577", "1954748371267292", "1956101354462476", "1965935656781067", "1970020919737575", "1977300289007968", "1997983616941074", "2007441982662842", "2010901385590143", "2024985647544165", "2027136310649381", "2038799169467074", "2050105178365420", "2073079786053899", "2079893112026210", "2081794735182357", "2083132931703802", "2087816307957284", "2089551784418694", "2102592709767704", "2115193398498040", "2163871603624744", "2165829696775412", "2174198969261957", "2181751905183508", "2234631869895481", "2332593053433028", "2345831755434399", "2395756427116505", "2474983395861908", "2541573499202200", "705957049528538", "1195231330579483", "1226401834129408", "1234575969979196", "1243729622397111", "1266400043463299", "1274540805979563", "1276282039140772", "1287411884691604", "1316447215123783", "1333868786712625", "1339563702809872", "1352530088180106", "1353868098048142", "1357769827655827", "1362563177177956", "1370574749709903", "1381160018654784", "1383551235078231", "1386401214793407", "1393399054099235", "1417398231705466", "1420369648069439", "1421493464623856", "1430934523678071", "1432323156873671", "1435916723180564", "1443311799107440", "1444726968989780", "1444841635627197", "1451496178286009", "1451932814915911", "1456112601155206", "1460411260736366", "1460928227351590", "1463081490485829", "1466122046831123", "1474567642672933", "1479544442150923", "1479560968822829", "1481965368599205", "1484376225017787", "1484739334965322", "1486055804840150", "1490322314412604", "1490407584421703", "1491473600959371", "1492819547514347", "1495870187189550", "1499203566872625", "1499287680200832", "1500024540109768", "1512605388861787", "1513720468736483", "1514335448694053", "1514581798664051", "1516118595153154", "1520141204778006", "1521244177987015", "1521319251329324", "1523807594413647", "1524985980960360", "1533253540137695", "1536907306418494", "1539880562802083", "1540290456087427", "1541991395912502", "1542305179201883", "1543361699119409", "1544369582342261", "1547200702074789", "1547854045323005", "1551348001658056", "1552253981563674", "1552771248178632", "1553650881411847", "1556075951171829", "1557018014397061", "1557207261045016", "1559305177529600", "1559508630814667", "1560357667424235", "1561192583979447", "1565760560201790", "1570679033031317", "1570882949695854", "1577807062318399", "1582447405157832", "1583350161787145", "1583689321668680", "1586504218134734", "1587651248020016", "1588343521264524", "1588582721263301", "1590629984369231", "1592270687560331", "1594073354047442", "1594310844015995", "1597223317058940", "1598613580257448", "1599571173473767", "1600876466697653", "1602104586572392", "1603061286413552", "1603070783095330", "1603308699706617", "1604637136300804", "1605610969554071", "1606231366112404", "1606568622724609", "1607434839355104", "1607692826018083", "1608131025969889", "1608404779278095", "1609736322478866", "1610421842407363", "1611665015619212", "1615380521849409", "1616097428427163", "1616859405077339", "1617243468344586", "1618627671591531", "1618669331586900", "1619173228201981", "1619903974771689", "1621560787961350", "1622542441148262", "1624566910992185", "1627528797367990", "1628146437261208", "1628390073875047", "1628538307241870", "1628949380529476", "1629637797084308", "1629719860415693", "1630631957020989", "1630943337024298", "1631079000344662", "1631991686909075", "1632718820158346", "1634432629939652", "1634535126631057", "1634620189925189", "1634987983215104", "1637835679587579", "1639317466145940", "1640024369412223", "1640600409352428", "1642763529106932", "1645196455535821", "1645675062147461", "1646516455396566", "1647081312008200", "1648151748595716", "1649087021807752", "1649572101784990", "1650151168435616", "1650277301758615", "1650882391656820", "1651250751624848", "1651945384854749", "1653387748084350", "1653473478034688", "1653574874678157", "1654791181254063", "1654989197954622", "1655255707915514", "1655783491141538", "1656092391174915", "1657269084321665", "1657460740956528", "1657955230950708", "1658656354255965", "1659734957444726", "1660503967362378", "1660556160695988", "1662322410503017", "1662558097153960", "1663183043759551", "1663206833774214", "1663837960373320", "1664207370283581", "1665386330206286", "1665496590230305", "1665972310118436", "1666012413465537", "1666560986757768", "1666674520095924", "1667554729988978", "1669067696519784", "1670619003014801", "1671194566306777", "1671553489608502", "1673012429454122", "1673454556072012", "1673745662679730", "1673903276030165", "1674486645980163", "1675145935895717", "1675588352527254", "1676388632448191", "1676637839091879", "1676879819090962", "1677197669026245", "1677377689011623", "1678079372239754", "1679090825470165", "1679482102107156", "1679719232065760", "1680461802032538", "1681113205309394", "1681951975214700", "1682059791884442", "1682767738468747", "1683320811755721", "1684457974963620", "1684913854925696", "1687163304709121", "1687233461384054", "1687514674630726", "1689877297773500", "1690406754373385", "1690544367700126", "1692148027532632", "1692345074190313", "1692512247483401", "1693012310768039", "1693267724086567", "1693552120712543", "1694554357302510", "1694970550595450", "1695784043840978", "1696730120363726", "1697251400360704", "1698304633588199", "1699378223462843", "1699631786797768", "1700564113325326", "1703119866446746", "1704584706268060", "1705771752842355", "1708118325934047", "1713307848753960", "1713629268704007", "1713760648667221", "1715035748535611", "1715166661882576", "1715893065100377", "1716729471743353", "1717110151678918", "1717478218333335", "1717679141623917", "1718354051533922", "1719740131427189", "1719880918068215", "1720066458089598", "1720091354744485", "1721012551278252", "1721559274554705", "1722258404516813", "1725228264182286", "1726065680806294", "1726911930723148", "1728843687158810", "1729202360493417", "1730098760410553", "1730225070388751", "1731184073585725", "1732154143530080", "1734795503279121", "1735219283188292", "1735281789898364", "1735789916460272", "1735982989800706", "1737854506275248", "1738689496170445", "1739174932772464", "1739451226167649", "1739980696109812", "1740079046037697", "1742286882526120", "1743564582393669", "1743608059035870", "1744644698914717", "1744912288962323", "1745013252250936", "1746863568693636", "1747557525282581", "1748733685216243", "1748920358533982", "1749111895148841", "1749774861746424", "1749812531765950", "1750124605025970", "1751502614916357", "1752016801504297", "1753358801387763", "1753366661395772", "1754163111297358", "1754213864638341", "1754460297930416", "1755907237807881", "1761135560620585", "1762012573856579", "1763558920334114", "1764351413607656", "1765492016836145", "1766486063373051", "1767032580056780", "1767940219935793", "1767976919928076", "1769297179796625", "1769742343048500", "1773038412754507", "1773618159328199", "1776166525800008", "1776364309086917", "1776473169063153", "1777683278959710", "1778250875531392", "1779106312196784", "1779909345364059", "1782005588488231", "1783215578425258", "1783846138344873", "1784906824900585", "1785025948227528", "1787284404650567", "1792512250801032", "1793443694010074", "1794548883971570", "1796308210421554", "1796359510425463", "1797840196940497", "1798297933525412", "1800753933315534", "1803540716372223", "1804010059619252", "1806748369346115", "1808803969183210", "1810536048997924", "1810796628987049", "1810907322264710", "1813159352080876", "1813688825347937", "1818359451558940", "1818687178190960", "1819605444729229", "1820057631371850", "1820979887952866", "1828121347251852", "1829606363744452", "1830658740299063", "1830879046992212", "1833896316660931", "1834175869980468", "1836919399672118", "1837406189613004", "1838509109535078", "1840938319308438", "1843757838987874", "1843782555686071", "1844512688934433", "1845044535560703", "1847741601957143", "1847820215239342", "1850824424968935", "1851796224831828", "1853704868014001", "1854476461282125", "1855772487774261", "1857023901029206", "1858075234237570", "1859374600763324", "1860074484016984", "1860291084046370", "1863391027050872", "1863669187016544", "1865082366849043", "1865225676834492", "1866056000131196", "1869492009751352", "1870187349658677", "1870854422966168", "1872013406207123", "1872030596205506", "1872080966148108", "1872372832820908", "1873199002704933", "1875150199182935", "1876329442442218", "1876472462385636", "1876634489037574", "1876651255699736", "1878355842194937", "1878553528841782", "1878614032209336", "1878751285502367", "1878859175467167", "1880166975379598", "1880809705273567", "1882246328475303", "1882271888483493", "1885025698176392", "1885504848149028", "1885787114829238", "1886136121404570", "1887317551286564", "1887732687968825", "1888012707939379", "1888340707884661", "1889718571063048", "1889994454357747", "1893872203957308", "1893998344003591", "1895324660517886", "1895968007144302", "1896110510445121", "1897342186977620", "1899754163388876", "1900270640029916", "1900949359915479", "1902469036432844", "1903788619693440", "1905370186142558", "1906378749395352", "1907777369240598", "1908631245813864", "1908686245869440", "1909056505835702", "1914878078523985", "1915272401856851", "1916240875117022", "1918532611552415", "1918697828150681", "1919259378084085", "1919384561406395", "1919779101429074", "1920682374669982", "1921224094615303", "1922298464448436", "1922528154448587", "1923885561017556", "1924319034267044", "1925156377534746", "1928130707221862", "1930362737036671", "1931517973556546", "1931872780177769", "1932591613449722", "1932864926787259", "1933375626687384", "1933417920066133", "1934140373323814", "1934150989990319", "1934760019891497", "1935353706535664", "1937038796307742", "1938695086201819", "1939130736111554", "1941582942527693", "1944707135600389", "1944805508924420", "1945576402128310", "1946113625430907", "1946208335421052", "1948521748554165", "1949060295168334", "1949650501732549", "1949757761762179", "1950619591676081", "1950642721672757", "1953179724752400", "1954021707972462", "1954974501240661", "1955120314501174", "1956351891103798", "1959887017369290", "1961177783927697", "1961646463908363", "1962011417174224", "1966813340058452", "1968239743249454", "1971465926197594", "1972670862804183", "1973051976102562", "1973194002753128", "1974625112610633", "1974894012523397", "1978494922192753", "1980402071972277", "1980824835323792", "1995302670512275", "1996573407039036", "2002731226406904", "2003570483006235", "2006801556016410", "2010770155662260", "2011782375529681", "2015416105155149", "2018399114837538", "2027553323938856", "2032672580106907", "2040813302626001", "2042121265829663", "2045135085514545", "2050484181647765", "2051457871534380", "2054400201254837", "2055787904449508", "2058165847589641", "2059386580755448", "2064050046955932", "2064806013547792", "2070011679706119", "2070444469662924", "2072320219448895", "2078700675505932", "2079707928722365", "2084277731600388", "2100603196622389", "2107129962660575", "2107521752596779", "2114129085280317", "2117043628335945", "2120078401353954", "2121812001177390", "2122170977799365", "2127500797265246", "2130513093630103", "2130672333611456", "2132983436717659", "2136994322985053", "2138196976241902", "2139168856100901", "2139603806086614", "2139762569374769", "2143874912294640", "2149486338402719", "2153974391294353", "2157924357567937", "2164741153540652", "2166435003366681", "2167107493305037", "2168968779785820", "2173370696022966", "2178848445459453", "2202186413132345", "2207094809318341", "2224074367610254", "2236140059736165", "2237849159575133", "2259863220690820", "2308260782548006", "2326764917350480", "2334727306552741", "2375077722517739", "2410444222314363", "2414191488606553", "2432876776738528", "2436242879735194", "2437350836291088", "2439213762771540", "2478228242203422", "2478746465488323", "2531371166888772", "679197758870815","681056835351381", "711339025656355", "732782766845604", "853125111478645", "899670526824388", "908948349229861", "929867540471487", "932024406922480", "952359494889174", "982817658509817", "996096483848995", "1490026004441683", "1212622392174346", "1480808868711709", "1518599604917918", "1703283119733003", "1768205673237082", "1840706899314633", "1452910868129020", "1476389732472609", "1524431234350567", "1552854668146890", "1573982732671486", "1577987655653578", "1597092563672155", "1609853845803000", "1626429750808720", "1649830805052121", "1652680924781812", "1653342074746886", "1687492171316662", "1708510632503785", "1717736071640715", "1723728454388581", "1728289543859848", "1745680448788404", "1747097818690607", "1752607618137334", "1754957614542505", "1756951820993278", "1762412400447427", "1797339186994832", "1805590032837981", "1850326234979570", "1863326887071169", "1871407799610627", "1880490732023559", "1895962960465200", "1903694823033853", "1909777682366067", "1917833178241583", "1927718957262470", "1931060236906687", "1947277448638188", "1958694937507241", "2017909654903712", "2082429255106513", "2096457477037518", "2164881850190416"]

let hannaLeeTest50 = ["1841364162573120", "1856011364462614", "1863033630388135", "1880170705391677", "1889886704395266", "1896755950398290", "1897095970363299", "1903343316406806", "1916545605084746", "1919318714808619", "1925299617511268", "1938271936214023", "1941048835907617", "1945593642119943", "1970124813061494", "1971962489501029", "1997922320231926", "2039465059402163", "2048771671800084", "2054902281190694", "2146997931984768", "2389075051118490", "2410054352345575", "1197558127014427", "1204604102975650", "1207059579396930", "1237324179703816", "1277071669061913", "1316614635107062", "1327331687367668", "1336910403075382", "1349547375145474", "1391763754263668", "1400540340074865", "1403483303085937", "1410006579105325", "1437219283050604", "1451894028273081", "1455128021263761", "1459469610831643", "1466841150094409", "1468076346655055", "1487170974728353", "1489356691193249", "1507532136038865", "1516527061790112", "1517948344998388", "1519864861475035", "1520842584711003", "1539305576167756"]
let hannaLeeTestLilia = ["1967947763279176"]
let hannaLeeTestLiliaStaging = ["1313956765373484"]
let hannaLeeTest = ["1733536976677017", "1547115702068142", "1577826605605503", "1967947763279176"]

let tailorMadeJaneShopping = ["1688956994556673", "1688004897951055", "1687518461367052", "1687458918017217", "1687437027972534", "1686680231417061", "1685905981529172", "1683110671803309", "1681164251933550", "1680608868720893", "1680114755359319", "1679226035500644", "1678229952231473", "1678191295564180", "1677611202322112", "1677206895706303", "1675340262572912", "1674360149299146", "1673675982717663", "1673418529421225", "1673188469401130", "1670611199672403", "1669688979819031", "1669675993113268", "1668506869937337", "1668246479889066", "1667081973360920", "1666276816774964", "1666033956819439", "1665293056841303", "1663259253753543", "1662814063806369", "1661603697289315", "1661024674016112", "1660872983961228", "1660422587375661", "1658882130847225", "1652977064799149", "1651500231583977", "1651180018264606", "1650537241668209", "1649959165059476", "1648360438604933", "1648077878621212", "1648060028643798", "1648022251978047", "1646513302123217", "1646329935416682", "1645324058920940", "1644642872297610", "1644361355617888", "1643571259057952", "1641453389256219", "1638400682942357", "1636405143095552", "1636384793141670", "1635457889836090", "1634695606584848", "1634581933263875", "1631018063614362", "1630595893660361", "1629624677084890", "1626161524118667", "1625548530885501", "1624882744276305", "1624098084371545", "1620155108079835", "1619373221492934", "1619320168175168", "1619293854857297", "1616477248473098", "1616240921821900", "1615889595195980", "1613782932075057", "1611762918923563", "1611095305677660", "1608760932526574", "1603516966444564", "1601163493336162", "1599256010196419", "1587750001324143", "1585943438185110", "1585737744876257", "1583328098444175", "1581150291983484", "1579349258848783", "1578492002271970", "1578359885623652", "1577320815722421", "1570842246357442", "1562304677225005", "1561223673988077", "1557875974341032", "1556165254499897", "1555171571271837", "1553404598115399", "1548911078569609", "1538541906272628", "1537842846341709", "1537277696395121", "1537098696412420", "1535776813198722", "1534954753282007", "1518621358248113", "1518101054985700", "1517826511672504", "1517711675005673", "1517463428351413", "1513431388779691", "1511058895688501", "1509116999217661", "1504654582978017", "1504261203019050", "1499753543463235", "1497155757060334", "1483255515117556", "1482412988535207", "1478935825543870", "1476655265789653", "1463696977068832", "1446844232097441", "1443774385727973", "1443232899116056", "1442912109148121", "1442528422519141", "1439350332832064", "1436270133146228", "1414768298628102", "1391011824336697", "1351038008331814", "1344486178984551", "1263863863716203", "1003642196427638"]
