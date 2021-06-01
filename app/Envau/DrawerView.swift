//
//  DrawerView.swift
//  Envau
//
//  Created by Tim Sandgren on 2021-05-31.
//  Copyright © 2021 Abstraqata. All rights reserved.
//

import SwiftUI
import MapKit
import Drawer
import UIKit

struct DrawerView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 25.7617,
            longitude: 80.1918
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 10,
            longitudeDelta: 10
        )
        
    )
    
    var body: some View {
        
        ZStack {
            Map(coordinateRegion: $region)

            Drawer {
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(.white)
                        .shadow(radius: 100)
                    
                    VStack(alignment: .center) {
                        Spacer().frame(height: 4.0)
                        RoundedRectangle(cornerRadius: 3.0)
                            .foregroundColor(.gray)
                            .frame(width: 30.0, height: 6.0)
                        Spacer()
                    }
                }
            }.frame(minWidth: 100, idealWidth: .infinity
, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 70, idealHeight: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
        
        // idealWidth: UIScreen.main.bounds.size.width
        
    }
        
}


struct SwiftUIView_Previews_B: PreviewProvider {
    static var previews: some View {
        DrawerView()
    }
}
