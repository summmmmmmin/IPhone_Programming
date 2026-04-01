// TeamSelectView.swift

import SwiftUI

struct Meeting: Codable{
    var id:Int?
    var team_id:Int?
    var title:String?
    var notes:String?
    var author_id: Int?
    var name: String?
    
}

struct MeetingItem:View {
    @State var meetingData : Meeting
    @State var selectMeetingActive: Bool = false
    @State var projectMessage = "" // 메시지 변수 유지
   
    var body: some View {
        VStack{
            Button(action: {
                print("회의록 항목이 클릭되었습니다: \(meetingData.title ?? "")")
                selectMeetingActive = true
                
                
            }) {
                HStack{
                    VStack{
                        Text(meetingData.title ?? "")
                        Text(meetingData.notes ?? "")
                        Text(meetingData.name ?? "")
                    }
                }
            }
        }
        
        .frame(width:320, height:100)
        .border(Color.gray, width: 1)
        .padding(.vertical, 5)
        
        NavigationLink(destination: MeetingsInfoView(meeting_ID:meetingData.id),
                       isActive: $selectMeetingActive) {
            EmptyView()
        }
        
    }
}

struct Meetings: Codable{
    var meetings:[Meeting]
}

struct MeetingsView: View {
    @State var isCreateMeetingActive: Bool = false
    @State var meetings:Meetings=Meetings(meetings: [Meeting]())
    let team_ID: Int?
    let team_Name: String
    @State var id:String=""
    @State var name:String=""
    @State var description:String=""
    @State var due_at:String=""
    
    var body: some View {
        
            
            VStack{
                Text(team_Name)
                        .font(.headline)
                        
                
                HStack{
                    Spacer()
                    
                    Button{
                        isCreateMeetingActive = true
                    } label:{
                        Text("회의록 생성")
                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 1)
                            )
                    }
                    .fullScreenCover(isPresented: $isCreateMeetingActive){
                        CreateMeetingsView(teamID:team_ID, teamName:team_Name)
                    }
                   
                    .padding(.trailing, 20)
                }
                
                    VStack{
                        List(meetings.meetings, id:\.id) { contents in MeetingItem(meetingData: contents)}
                    }.onAppear(){
                        guard let url=URL(string: "http://localhost/ip1/getmeetings.php")
                        else{
                            print("url error")
                            return
                        }
                    
                        var request = URLRequest(url: url)
                        request.httpMethod="POST"
                        
                    
                        
                        let teamIDValue = self.team_ID ?? 0
                        
                        let body="team_id=\(teamIDValue)";
                    
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
                                if let jsonTeamData = try? decoder.decode(Meetings.self, from:data){
                                    meetings=jsonTeamData
                                    print("???")
                                }
                            }
                        } .resume()
                    }
                

            }
            
        
        
        
    }
}

#Preview {
    MeetingsView(team_ID: 0, team_Name: "팀명")
}





