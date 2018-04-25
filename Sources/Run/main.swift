import Console
import Fluent
import MySQLProvider
import LeafProvider

/// We have isolated all of our App's logic into
/// the App module because it makes our app
/// more testable.
///
/// In general, the executable portion of our App
/// shouldn't include much more code than is presented
/// here.
///
/// We simply initialize our Droplet, optionally
/// passing in values if necessary
/// Then, we pass it to our App's setup function
/// this should setup all the routes and special
/// features of our app
///
/// .run() runs the Droplet's commands, 
/// if no command is given, it will default to "serve"
//    "stripeKey": "pk_test_NQ93FNErcyg9BCE7iutKH8fb", for production
let config = try Config()
try config.setup()
config.addConfigurable(command: WhitelistDomainsCommand.init, name:"whitelist_domains")
config.addConfigurable(command: UpdateBotMenuCommand.init, name:"update_bot_menu")
config.addConfigurable(command: TestCustomCommand.init, name: "test_command")
config.addConfigurable(command: CreateSessionCommand.init, name: "create_session")
config.addConfigurable(command: TestPayments.init, name: "test_payments")
config.addConfigurable(command: TestShopping.init, name: "do_shopping")
config.addConfigurable(command: CountSubscribersCommand.init, name: "count_subscribers")

try config.addProvider(LeafProvider.Provider.self)
try config.addProvider(MySQLProvider.Provider.self)
config.preparations.append(MediaUpload.self)
config.preparations.append(Subscriber.self)
config.preparations.append(StripeCustomer.self)
config.preparations.append(StripeCharge.self)

let drop = try Droplet(config)
drop.view.shouldCache = true
try drop.setup()
//to test payments 
//let test = TestPayments(console: drop.console)
//try test.run(arguments: [])
try drop.run()

