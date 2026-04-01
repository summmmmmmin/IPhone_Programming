//
//  ManagementView.swift
//  Team_4th
//
//  Created by mac10 on 10/27/25.
//

import SwiftUI

struct Management: Codable{
    var id:Int?
    var user_id:Int?
    var team_id:Int?
    var name:String?
    var email:String?
    var role:String?
    var profile_img:String?
}

struct ManagementItem:View {
    @State var managementData : Management
    let teamName: String
    var onApplicationProcessed: () -> Void
    
    var body: some View {
        NavigationLink(destination: ApplicantDetailView(
            managementID: managementData.id ?? 0,
            teamName: teamName,
            userName: managementData.name ?? "이름 없음",
            userEmail: managementData.email ?? "이메일 없음",
            applicantID: managementData.user_id ?? 1,
            teamID: managementData.team_id ?? 1,
            profileImageUrl: managementData.profile_img ?? "",
            onApplicationProcessed: onApplicationProcessed)) {
            Text(managementData.name ?? "")
        }
    }
}

struct Managements: Codable{
    var managements:[Management] = []
}

struct ManagementView: View {
    @State var teamname:String=""
    @State var teams_id:Int = 0
    @State var name:String=""
    @State var managements:Managements=Managements(managements: [Management]())
    @State var members:Managements=Managements(managements: [Management]())
    
    let onLeadershipTransferred: () -> Void
    
    func loadApplicants() {
        guard let url=URL(string: "http://localhost/ip1/management_apply.php")
        else{
            print("url error")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        
        let userid = UserDefaults.standard.integer(forKey: "LoggedInUser")
        
        let body="user_id=\(userid)&teams_id=\(teams_id)";
        
        let encodeData=body.data(using: String.Encoding.utf8)
        request.httpBody=encodeData
        
        URLSession.shared.dataTask(with: request){ data,response,error in
            if let error = error{
                print(error)
                return
            }
            guard let data = data else{
                return
            }
            
            DispatchQueue.main.async {
                do{
                    let str2 = String(decoding: data, as: UTF8.self)
                    print("--------신청 목록: \(str2)")
                    let decoder = JSONDecoder()
                    if let jsonTeamData = try? decoder.decode(Managements.self, from:data){
                        self.managements=jsonTeamData
                        print("신청 목록 불러오기 성공")
                    }
                }
            }
        } .resume()
    }
    
    func loadMembers() {
        guard let url=URL(string: "http://localhost/ip1/getteammembers.php")
        else{
            print("url error")
            return
        }
                
        var request = URLRequest(url: url)
        request.httpMethod="POST"
                
        let body="teams_id=\(teams_id)";
                
        let encodeData=body.data(using: String.Encoding.utf8)
        request.httpBody=encodeData
                
        URLSession.shared.dataTask(with: request){ data,response,error in
            if let error = error{
                print(error)
                return
            }
            guard let data = data else{
                return
            }
                    
            DispatchQueue.main.async {
                do{
                    let str2 = String(decoding: data, as: UTF8.self)
                    print("--------팀원 목록: \(str2)")
                    let decoder = JSONDecoder()
                    if let jsonTeamData = try? decoder.decode(Managements.self, from:data){
                        self.members=jsonTeamData
                    }
                }
            }
        } .resume()
    }
    
    var applicationListSection: some View {
        Section(header: Text("신청 목록")) {
            ForEach(managements.managements, id:\.id) { contents in
                ManagementItem(managementData: contents, teamName: teamname, onApplicationProcessed: {
                    self.loadApplicants()
                    self.loadMembers()
                })
            }
        }
    }
    
    var memberListSection: some View {
        Section(header: Text("팀원 목록")) {
            ForEach(members.managements, id: \.id) { member in
                
                let roleInt = Int(member.role ?? "") ?? 2
                
                NavigationLink(destination: MembersDetailView(
                    teamID: teams_id,
                    memberID: member.user_id ?? 0,
                    memberMembershipID: member.id ?? 0,
                    teamName: teamname,
                    memberName: member.name ?? "이름 없음",
                    memberEmail: member.email ?? "이메일 없음",
                    memberRole: roleInt,
                    profileImageUrl: member.profile_img ?? "",
                    onLeadershipTransferred: onLeadershipTransferred,
                    onMembershipUpdated: {
                        self.loadApplicants()
                        self.loadMembers()
                    }
                )) {
                    Text(member.name ?? "이름 없음")
                }
            }
        }
    }
    
    var body: some View {
        
        NavigationStack {
            
            List {
                applicationListSection
                memberListSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("\(teamname) 팀원 관리")
            
        }
        .onAppear(){
            self.loadApplicants()
            self.loadMembers()
        }
    }
}
 
struct ManagementView_Previews: PreviewProvider {
    static var previews: some View {
        ManagementView(teamname: "팀명", teams_id: 1, onLeadershipTransferred: {})
    }
}


