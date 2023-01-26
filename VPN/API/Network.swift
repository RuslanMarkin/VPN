//
//  File.swift
//  VPN
//
//  Created by Ruslan on 26.01.23.
//

import Foundation
import Swift
import SwiftUI
import NetworkExtension


class ServerList: ObservableObject {
    @Published var servers: [Server]
    
    init() {
        // initialize the server list, this can be done by fetching them from a remote server or a local storage
        self.servers = [Server(name: "Server 1", protocolConfiguration: NEVPNProtocolIKEv2()),
                        Server(name: "Server 2", protocolConfiguration: NEVPNProtocolIKEv2()),
                        Server(name: "Server 3", protocolConfiguration: NEVPNProtocolIKEv2())]
    }
}



struct Server {
    var name: String
    var protocolConfiguration: NEVPNProtocol
}
