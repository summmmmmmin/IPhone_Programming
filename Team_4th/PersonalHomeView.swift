//
//  TeamHomeView.swift
//  Team_4th
//
//  Created by mac10 on 10/27/25.
//

import SwiftUI



struct PersonalHomeView: View {
    @State private var name: String = "aaaa"
    @State private var description: String = "aaaa"
    @State private var id: String = ""
    @State private var teams_id: Int = 0
    @State var movetoHomeView: Bool = false
    @State var movetoProjectView: Bool = false
    @State var movetoMeetingsView: Bool = false
    @State var movetoPersonalProfile: Bool = false
    @State var myTeamListActive: Bool = false
    @State var TeamSwitchActive: Bool = false
    @State var myteams:MyTeams=MyTeams(myteams: [MyTeam]())
    @State var latestteam:LatestTeam=LatestTeam(latestteam: [MyTeam]())
    @State var switchteam:SwitchTeam=SwitchTeam(switchteam: [MyTeam]())
    var body: some View {
        NavigationView{
            VStack {
                if(myTeamListActive){
                    VStack{
                        List(myteams.myteams, id: \.id) { contents in MyTeamItem(myteamData: contents, teamSwitchActive: $TeamSwitchActive, switchteam: $switchteam)}
                    }.onAppear(){
                        guard let url=URL(string: "http://localhost/ip1/getmyteams.php")
                        else{
                            print("url error")
                            return
                        }
                        
                        let userid = UserDefaults.standard.integer(forKey: "LoggedInUser")
                        
                        var request = URLRequest(url: url)
                        request.httpMethod="POST"
                        let body="id=\(userid)&name=\(name)&description=\(description)";
                        
                        let encodeData=body.data(using: String.Encoding.utf8)
                        request.httpBody=encodeData
                        
                        URLSession.shared.dataTask(with: request){data,response,error in
                            if let error = error{
                                print(error)
                                return
                            }
                            guard let data = data else{
                                return
                            }
                            
                            do{
                                let str2 = String(decoding: data, as: UTF8.self)
                                print(str2)
                                let decoder = JSONDecoder()
                                if let jsonTeamData = try? decoder.decode(MyTeams.self, from:data){
                                    myteams=jsonTeamData
                                    print("???")
                                }
                            }
                        } .resume()
                    }
                }
                Button {
                    myTeamListActive.toggle()
                    
                } label: {
                    VStack{
                        if(TeamSwitchActive){
                            Text(switchteam.switchteam.first?.name ?? "")
                                
                            Text(switchteam.switchteam.first?.description ?? "")
                        }
                        else{
                            Text("\(name)님의 홈")
                        }
                    }.onAppear(){
                        guard let url=URL(string: "http://localhost/ip1/personalhome.php")
                            else{
                                print("url error")
                                return
                            }
                        
                        let userid = UserDefaults.standard.integer(forKey: "LoggedInUser")
                        
                                
                        let body = "id=\(userid))"
                        let encodeData=body.data(using: .utf8)
                            
                        var request = URLRequest(url: url)
                        request.httpMethod="POST"
                        request.httpBody=encodeData
                        URLSession.shared.dataTask(with: request){data,response,error in
                            if let error = error{
                                print(error)
                                return
                            }
                            guard let data = data else{
                                return
                            }
                                
                            let str = String(decoding: data, as: UTF8.self)
                            print("data ? \(str)")
                            name = str
                            
                        }.resume()
                    }
                }
                .fullScreenCover(isPresented: $TeamSwitchActive){
                    TeamHomeView()
                }
                

                HStack {
                    Button("홈"){
                        movetoHomeView=true
                    }.padding(.horizontal, 20)
                    Button("프로젝트"){
                        movetoProjectView=true
                    }.padding(.horizontal, 20)
                    .fullScreenCover(isPresented: $movetoProjectView){
                        ProjectView(team_ID: teams_id, team_Name: name)
                    }
                    Button("프로필"){
                        movetoPersonalProfile=true
                    }.padding(.horizontal, 20)
                    .fullScreenCover(isPresented: $movetoPersonalProfile){
                        PersonalProfileView()
                    }
                }
            }
            
        }
    }
    
}

#Preview {
    PersonalHomeView()
}




