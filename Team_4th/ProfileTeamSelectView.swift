//
//  ProfileTeamSelect.swift
//  Team_4th
//
//  Created by mac27 on 12/15/25.
//

import SwiftUI

struct ProfileTeam: Codable{
    var id:Int?
    var name:String?
    var description:String?
}

struct ProfileTeamItem:View {
    @State var teamData : Team
    @State var ApplyTeamActive: Bool = false
    @State var ApplyTeamActiveSuccess: Bool = false
    @State var showApplyAlert = false
    @State var showApplySuccessAlert = false
    @State var showApplyFailAlert = false
    @State var isApplied = false
    @State var isJoined = false
    @State var alertMessage = "" // 메시지 변수 유지
    @State var teams_id:Int=0
    var body: some View {
        VStack{
            Text(teamData.name ?? "")
            Text(teamData.description ?? "")
            
            Button(isJoined ? "가입완료" :(isApplied ? "신청완료" : "신청하기")) {
                if !isApplied && !isJoined {
                    showApplyAlert = true
                }
            }.frame(width:150, height:25)
             .background((isJoined || isApplied) ?
                        Color.gray.opacity(0.4) :
                        Color.blue.opacity(0.2))
             .foregroundColor((isJoined || isApplied) ? .gray : .blue)
             .cornerRadius(5)
             .padding(.vertical, 3)
             .onAppear{
                 guard let url=URL(string: "http://localhost/ip1/alreadyapplied.php")
                     else{
                         print("url error")
                         return
                     }
                 
                 let userid = UserDefaults.standard.integer(forKey: "LoggedInUser")
                         
                 let body = "userid=\(userid)&teams_id=\(teamData.id ?? 0)"
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

                     DispatchQueue.main.async {
                         if str == "1"{
                             print("이미 가입신청된 팀")
                             isApplied = true
                         }
                         else if str == "3"{
                             print("이미 가입한 팀")
                             isJoined = true
                         }
                     }
                 }.resume()
             }
             .alert(isPresented: $showApplyAlert) {
                        Alert(title: Text("알림"), message: Text("가입을 신청하시겠습니까?"),
                            primaryButton: .default(Text("신청"), action:{
                            guard let url=URL(string: "http://localhost/ip1/applyTeam.php")
                                else{
                                    print("url error")
                                    return
                                }
                            
                            let userid = UserDefaults.standard.integer(forKey: "LoggedInUser")
                                    
                            let body = "userid=\(userid)&teams_id=\(teamData.id ?? 0)"
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
                                    
                                let rawStr = String(decoding: data, as: UTF8.self)
                                let str = rawStr.trimmingCharacters(in: .whitespacesAndNewlines)
                                
                                print("data ? \(str)")

                                DispatchQueue.main.async {
                                    if str == "1"{
                                        print("팀 신청 성공")
                                        alertMessage = "가입 신청이 완료되었습니다."
                                        showApplySuccessAlert = true
                                        isApplied = true
                                    }
                                    else if str == "-1"{
                                        print("신청 실패: 중복")
                                        alertMessage = "이미 신청 완료한 팀입니다."
                                        showApplyFailAlert = true
                                    }
                                    else if str == "3"{
                                        print("신청 실패: 가입")
                                        alertMessage = "이미 가입 완료한 팀입니다."
                                        showApplyFailAlert = true
                                    }
                                    else if str == "4" {
                                        print("신청 실패: 차단")
                                        alertMessage = "가입이 차단된 팀입니다."
                                        showApplyFailAlert = true
                                    }
                                }
                            }.resume()
                        }),
                            secondaryButton: .destructive(Text("취소")
                            ))
                    }
            .alert("성공", isPresented: $showApplySuccessAlert){
                Button("확인") {}
            } message: {
                Text(alertMessage)
            }
            .alert("알림", isPresented: $showApplyFailAlert){
                Button("확인") {}
            } message: {
                Text(alertMessage)
            }

        }
        .frame(width:320, height:100)
        .border(Color.gray, width: 1)
        .padding(.vertical, 5)
        
        
    }
}

struct ProfileTeams: Codable{
    var teams:[Team]
}

struct ProfileTeamSelectView: View {
    @State var isWithoutTeamActive: Bool = false
    @State var isCreateTeamActive: Bool = false
    @State var teams:Teams=Teams(teams: [Team]())
    @State var id:String=""
    @State var name:String=""
    @State var description:String=""
    
    var body: some View {
        NavigationView{
            
            VStack{
                Text("Team Select")
                    .padding(.vertical, 10)
                
                    VStack{
                        List(teams.teams, id:\.id) { contents in TeamItem(teamData: contents)}
                    }.onAppear(){
                        guard let url=URL(string: "http://localhost/ip1/getteams.php")
                        else{
                            print("url error")
                            return
                        }
                    
                        var request = URLRequest(url: url)
                        request.httpMethod="POST"
                        let body="id=\(id)&name=\(name)&description=\(description)";
                    
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
                                if let jsonTeamData = try? decoder.decode(Teams.self, from:data){
                                    teams=jsonTeamData
                                    print("???")
                                }
                            }
                        } .resume()
                    }
                
                HStack {
                    
                    Button{
                        isCreateTeamActive = true
                    } label:{
                        Text("팀 생성하기")
                    }.fullScreenCover(isPresented: $isCreateTeamActive){
                        CreateTeamView()
                    }.padding(.horizontal, 30)
                    
                    
                }
            }
            
        }
        
        
    }
}

#Preview {
    ProfileTeamSelectView()
}



