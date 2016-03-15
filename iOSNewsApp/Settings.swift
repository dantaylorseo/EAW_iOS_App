//
//  Settings.swift
//  EvertonNewsApp
//
//  Created by Dan Taylor on 21/01/2016.
//  Copyright © 2016 Dan Taylor. All rights reserved.
//

import Foundation

class Settings: NSObject {
    
    var rssUrl: String!
    var jsonStoriesUrl: String!
    var leagueUrl: String!
    var fixturesUrl: String!
    var productId: String!
    var appid: String!
    var client: String!
    var barTint: Int!
    
    override init() {
        
        // MARK: - URLs
        self.rssUrl         = "https://www.evertonarentwe.com/feedadmin/xmlfeeds/rss-6.xml"
        self.jsonStoriesUrl = "https://www.evertonarentwe.com/feedadmin/xmlfeeds/rss-6.json"
        self.leagueUrl      = "http://api.football-data.org/v1/soccerseasons/398/leagueTable"
        self.fixturesUrl    = "http://dev.everton-news.co.uk/fixtures.json"
    
        // MARK: - In App Purchases
        self.productId = "EAWPremium"
    
        // MARK: - Parse Keys
        self.appid = "SGX1W9g0yI5nIAcYoMg04oob6iAuOuKxjvHupexO"
        self.client = "IxG7LMPdWMC8puNHYS4HL4K4p2AYJhtC36uN5fIc"
        
        self.barTint = 0x113081
        
    }
    
}