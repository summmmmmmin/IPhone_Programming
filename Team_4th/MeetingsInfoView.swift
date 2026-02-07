//
//  MeetingsInfoView.swift
//  Team_4th
//
//  Created by mac10 on 10/27/25.
//

import SwiftUI

struct MeetingData: Codable {
    let id:Int
    let title: String
    let notes: String
    let name: String
}


struct MeetingContainer: Codable {
    let meetings: [MeetingData]
}

struct MeetingsInfoView: View {
    let meeting_ID: Int?
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var Name: String = ""
    var body: some View {
        NavigationView{
            VStack{
                Text("제목 : \(title)")
                Text("작성자 : \(Name)")
                Text("내용 : \(notes)")
            }.onAppear(){
                guard let url=URL(string: "http://localhost/ip1/meetinginfo.php")
                else{
                    print("url error")
                    return
                }
            
                var request = URLRequest(url: url)
                request.httpMethod="POST"
                
            
                
                let meetingIDValue = self.meeting_ID ?? 0
                
                let body="id=\(meetingIDValue)";
            
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
                        if let container = try? JSONDecoder().decode(MeetingContainer.self, from: data),
                                       let meeting = container.meetings.first {
                            self.Name = meeting.name
                            self.title = meeting.title
                            self.notes = meeting.notes
                            
                        }  else {
                            print("JSON 디코딩 실패")
                            self.Name = "정보 없음"
                            self.title = "정보 없음"
                            self.notes = "정보 없음"
                        }
                    }

                } .resume()
            }
        }
    }
}

#Preview {
    MeetingsInfoView(meeting_ID: 0)
}
