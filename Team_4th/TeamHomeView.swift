//
//  TeamHomeView.swift
//  Team_4th
//
//  Created by mac10 on 10/27/25.
//

import SwiftUI


struct MyTeam: Codable{
    var id:Int?
    var name:String?
    var description:String?
}

struct ProjectData: Codable {
    let id:Int
    let team_id: Int
    let name: String
    let description: String}


struct ProjectContainer: Codable {
    let projects: [ProjectData]
}


struct LatestMeetingData: Codable {
    let id:Int
    let team_id: Int
    let title: String
    let notes: String
}


struct LatestMeetingContainer: Codable {
    let latestmeetings: [LatestMeetingData]
}



struct MyTeamItem:View {
    @State var myteamData : MyTeam
    @State var switchTeamActive: Bool = false
    @Binding var teamSwitchActive: Bool
    @Binding var switchteam: SwitchTeam
    var body: some View {
        Button {
            switchTeamActive = true
        } label: {
            VStack{
                Text(myteamData.name ?? "")
            }
        }.alert(isPresented: $switchTeamActive) {
            Alert(title: Text("알림"), message: Text("해당 팀으로 이동하시겠습니까?"),
                primaryButton: .default(Text("이동"), action:{
                guard let url=URL(string: "http://localhost/ip1/switchteam.php")
                else{
                    print("url error")
                    return
                }
                
                let userid = UserDefaults.standard.integer(forKey: "LoggedInUser")
                
                var request = URLRequest(url: url)
                request.httpMethod="POST"
                let body = "userid=\(userid)&teams_id=\(myteamData.id ?? 0)"
                let encodeData=body.data(using: .utf8)
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
                        if let jsonTeamData = try? decoder.decode(SwitchTeam.self, from:data){
                            DispatchQueue.main.async {
                                switchteam = jsonTeamData
                                teamSwitchActive = true
                                }
                            print("???")
                        }
                    }
                } .resume()
            }),
                secondaryButton: .destructive(Text("취소")
                ))
        }
        .frame(width:320, height:50)
        .border(Color.gray, width: 1)
        .padding(.vertical, 5)
        
        
    }
}

struct MyTeams: Codable{
    var myteams:[MyTeam]
}

struct LatestTeam: Codable{
    var latestteam:[MyTeam]
}

struct SwitchTeam: Codable{
    var switchteam:[MyTeam]
}


struct TeamHomeView: View {
    @State private var name: String = "aaaa"
    @State private var description: String = "aaaa"
    @State private var projectname: String = "aaaa"
    @State private var projectdescription: String = "aaaa"
    @State private var meetingtitle: String = "aaaa"
    @State private var meetingnotes: String = "aaaa"
    @State private var id: String = ""
    @State private var teams_id: Int = 0
    @State var movetoLeaderProfile: Bool = false
    @State var movetoViceLeaderProfile: Bool = false
    @State var movetoMemberProfile: Bool = false
    @State var movetoPersonalHome: Bool = false
    @State var myTeamListActive: Bool = false
    @State var TeamSwitchActive: Bool = false
    @State var movetoMeetingsView: Bool = false
    @State var movetoProjectView: Bool = false
    @State var movetoNoticeView: Bool = false
    @State var movetoHomeView: Bool = false
    @State private var activeTeamID: Int?
    @State private var activeTeamName: String=""
    @State var myteams:MyTeams=MyTeams(myteams: [MyTeam]())
    @State var latestteam:LatestTeam=LatestTeam(latestteam: [MyTeam]())
    @State var switchteam:SwitchTeam=SwitchTeam(switchteam: [MyTeam]())
    
    func loadlatestproject(){
        guard let teamID = activeTeamID, teamID != 0 else {
                print("fail")
                return
            }

        print("팀 ID:", teamID)
        guard let url=URL(string: "http://localhost/ip1/getlatestproject.php")
        else{
            print("url error")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod="POST"
        

        
        let body="team_id=\(teamID)";

        let encodeData=body.data(using: String.Encoding.utf8)
        request.httpBody=encodeData

        URLSession.shared.dataTask(with: request){data,response,error in
            if let error = error{
                print(error)
                return
            }
            guard let data = data else { return }
            let str2 = String(decoding: data, as: UTF8.self)
            print(str2)
            DispatchQueue.main.async {
                if let container = try? JSONDecoder().decode(ProjectContainer.self, from: data),
                   let project = container.projects.first {
                    self.projectname = project.name
                    self.projectdescription = project.description
                    
                }  else {
                    print("JSON 디코딩 실패")
                    self.projectname = ""
                    self.projectdescription = ""
                }
            }

        } .resume()
    }
    func loadlatestmeeting(){
        guard let teamID = activeTeamID, teamID != 0 else {
                print("fail")
                return
            }

        print("팀 ID:", teamID)
        guard let url=URL(string: "http://localhost/ip1/getlatestmeeting.php")
        else{
            print("url error")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod="POST"
        

        
        let body="team_id=\(teamID)";

        let encodeData=body.data(using: String.Encoding.utf8)
        request.httpBody=encodeData

        URLSession.shared.dataTask(with: request){data,response,error in
            if let error = error{
                print(error)
                return
            }
            guard let data = data else { return }
            let str2 = String(decoding: data, as: UTF8.self)
            print(str2)
            DispatchQueue.main.async {
                if let container = try? JSONDecoder().decode(LatestMeetingContainer.self, from: data),
                   let latestmeeting = container.latestmeetings.first {
                    self.meetingtitle = latestmeeting.title
                    self.meetingnotes = latestmeeting.notes
                    
                }  else {
                    print("JSON 디코딩 실패")
                    self.meetingtitle = ""
                    self.meetingnotes = ""
                }
            }

        } .resume()
    }
    
    var body: some View {
        NavigationView{
            VStack {
                if(myTeamListActive){
                    VStack{
                        List(myteams.myteams, id: \.id) { contents in MyTeamItem(myteamData: contents, teamSwitchActive: $TeamSwitchActive, switchteam: $switchteam)}
                        Button("개인 홈"){
                            movetoPersonalHome = true
                        }
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
                    if TeamSwitchActive {
                        activeTeamID = switchteam.switchteam.first?.id ?? 0
                        activeTeamName = switchteam.switchteam.first?.name ?? ""
                            }
                    else {
                        activeTeamID = latestteam.latestteam.first?.id ?? 0
                        activeTeamName = latestteam.latestteam.first?.name ?? ""
                    }
                    
                } label: {
                    VStack{
                        Text(activeTeamName)
                            .font(.title)
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                    }.onAppear(){
                        guard let url=URL(string: "http://localhost/ip1/getlatestteam.php")
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
                                if let jsonTeamData = try? decoder.decode(LatestTeam.self, from:data){
                                    latestteam=jsonTeamData
                                    if !TeamSwitchActive {
                                        self.activeTeamID = self.latestteam.latestteam.first?.id ?? 0
                                        self.activeTeamName = self.latestteam.latestteam.first?.name ?? "팀 미선택"
                                    }
                                    print("???")
                                }
                            }
                        } .resume()
                    }
                    
                }
                Spacer()
                
                Button {
                    movetoProjectView=true
                }
                label: {
                    VStack(alignment: .leading){
                        Text("과제")
                            .foregroundColor(.black)
                            .font(.headline)
                        Divider()
                        VStack(spacing: 4) {
                            Text(projectname)
                                .font(.subheadline)
                                .foregroundColor(.black)
                            Text(projectdescription)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                    }.onAppear {
                        loadlatestproject()
                    }
                    .onChange(of: activeTeamID) { _ in
                        loadlatestproject()
                    }
                    
                }
                .padding()
                .frame(maxWidth: 370, alignment: .leading)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                    )
                
                Button {
                    movetoMeetingsView=true
                }
                label: {
                    VStack(alignment: .leading){
                        Text("회의록")
                            .foregroundColor(.black)
                            .font(.headline)
                        Divider()
                        VStack(spacing: 4) {
                            Text(meetingtitle)
                                .font(.subheadline)
                                .foregroundColor(.black)
                            Text(meetingnotes)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                    }.onAppear {
                        loadlatestmeeting()
                    }
                    .onChange(of: activeTeamID) { _ in
                        loadlatestmeeting()
                    }
                    
                }
                .padding()
                .frame(maxWidth: 370, alignment: .leading)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                    )
                
                
                .fullScreenCover(isPresented: $TeamSwitchActive){
                    TeamHomeView()
                }
                
                .fullScreenCover(isPresented: $movetoPersonalHome){
                    PersonalHomeView()
                }
                .fullScreenCover(isPresented: $movetoLeaderProfile){
                    LeaderProfileView()
                }
                .fullScreenCover(isPresented: $movetoViceLeaderProfile){
                    ViceLeaderProfileView(showPersonalHome: $movetoPersonalHome)
                }
                .fullScreenCover(isPresented: $movetoMemberProfile){
                    MemberProfileView(showPersonalHome: $movetoPersonalHome)
                }
                
                
                
                
                Spacer()
                
                HStack {
                    Button("홈"){
                        movetoHomeView=true
                    }.padding(.horizontal, 10)
                    
                    Divider()
                    Button("프로젝트"){
                        movetoProjectView=true
                    }.padding(.horizontal, 10)
                    NavigationLink(destination: ProjectView(team_ID: activeTeamID,team_Name: activeTeamName),
                                   isActive: $movetoProjectView) {
                        EmptyView()
                    }
                    Divider()
                    Button("회의록"){
                        movetoMeetingsView=true
                    }.padding(.horizontal, 10)
                    NavigationLink(destination: MeetingsView(team_ID: activeTeamID,team_Name: activeTeamName),
                                   isActive: $movetoMeetingsView) {
                        EmptyView()
                    }
                    Divider()
                    Button("공지"){
                        movetoNoticeView=true
                    }
                    .padding(.horizontal, 10)
                    NavigationLink(destination: NoticeView(),
                                   isActive: $movetoNoticeView) {
                        EmptyView()
                    }
                    
                    Divider()
                    Button("프로필"){
                        guard let url=URL(string: "http://localhost/ip1/ifleader.php")
                            else{
                                print("url error")
                                return
                            }
                        
                        let userid = UserDefaults.standard.integer(forKey: "LoggedInUser")
                        
                                
                        let body = "id=\(userid)&teams_id=\(teams_id))"
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
                                
                            let role = String(decoding: data, as: UTF8.self)
                            print("data ? \(role)")
                            if role == "0"{
                                movetoLeaderProfile = true
                                print("팀장")
                            }
                            else if role == "1"{
                                movetoViceLeaderProfile = true
                                print("부팀장")
                            }
                            else {
                                movetoMemberProfile = true
                                print("팀원")
                            }
                        }.resume()
                    }.padding(.horizontal, 20)
                        .fullScreenCover(isPresented: $movetoLeaderProfile){
                            LeaderProfileView()
                        }
                        .fullScreenCover(isPresented: $movetoViceLeaderProfile){
                            ViceLeaderProfileView(showPersonalHome: $movetoPersonalHome)
                        }
                        .fullScreenCover(isPresented: $movetoMemberProfile){
                            MemberProfileView(showPersonalHome: $movetoPersonalHome)
                        }
                }
                .frame(height: 20)
            }
        }
    }
    
}

#Preview {
    TeamHomeView()
}


