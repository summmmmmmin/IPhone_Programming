//
//  TabBarView.swift
//  Team_4th
//
//  Created by mac10 on 10/27/25.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView {
            TeamHomeView().tabItem {
                Text("홈")
            }
            ProjectView(team_ID: 0, team_Name: "팀명").tabItem {
                Text("할일")
            }
            MeetingsView(team_ID: 0, team_Name: "").tabItem {
                Text("회의록")
            }

        }
    }
}

#Preview {
    TabBarView()
}
