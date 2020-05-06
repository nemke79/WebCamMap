//
//  NetworkSpeedProviderDelegate.swift
//  WebCamMap
//
//  Created by Nemanja Petrovic on 05/05/2020.
//  Copyright © 2020 Nemanja Petrovic. All rights reserved.
//

import Foundation


protocol NetworkSpeedProviderDelegate: class {
    func callWhileSpeedChange(networkStatus: NetworkStatus)
   }


public enum NetworkStatus :String
{case poor; case good; case disConnected}
