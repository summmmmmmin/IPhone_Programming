//
//  ProfileTabView.swift
//  Team_4th
//
//  Created by mac10 on 10/27/25.
//

import SwiftUI


struct ApplicantDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    
    let managementID: Int
    let teamName: String
    let userName: String
    let userEmail: String
    let applicantID:Int
    let teamID: Int
    let profileImageUrl: String
    
    var onApplicationProcessed: () -> Void
    
    @State private var showingAlert = false
    @State private var alertMessage = ""

    private func profileImageView() -> some View {
        Group {
            if let url = URL(string: profileImageUrl), !profileImageUrl.isEmpty {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle()
                        .foregroundColor(.gray.opacity(0.3))
                }
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.purple)
                    .background(Color.purple.opacity(0.1))
            }
        }
        .frame(width: 140, height: 140)
        .clipShape(Circle())
    }
    
    var body: some View {
        VStack(spacing: 24) {
            
            //1 팀명
            Text(teamName)
                .font(.system(size: 40))
                .bold()
                .padding(.vertical, 10)
            
            //2 프로필 카드
            VStack(spacing: 15) {
                profileImageView()
                
                Text(userName)
                
                Divider()
                
                Text(userEmail)
                    .padding(.bottom ,30)
                
            }
            .padding()
            .background(
                Color.white
                
            )
            .border(Color.black, width: 1)
            .padding(.horizontal)
            
            
            
            //3 버튼
            VStack(spacing: 20) {
                Button(action: {
                    processApplication(status: 0, successMessage: "수락했습니다.")
                    print("수락")
                    guard let url=URL(string: "http://localhost/ip1/setfavoriteteam.php")
                    else{
                        print("url error")
                        return
                    }
                    
                    var request = URLRequest(url: url)
                    request.httpMethod="POST"
                    
                    let body="id=\(applicantID)&teamid=\(teamID)";
                    
                    let encodeData=body.data(using: String.Encoding.utf8)
                                request.httpBody=encodeData
                    
                    URLSession.shared.dataTask(with: request){[self] data,response,error in
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
                                print("successfully set favorite team")
                            }
                            else if str == "0"{
                                print("failed setting favorite team")
                            }
                        }
                    } .resume()
                }) {
                    Text("수락")
                }
                
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(10).padding(.horizontal)
                
                Button(action: {
                    processApplication(status: 2, successMessage: "거절했습니다.")
                    print("거절")
                }) {
                    Text("거절")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(10).padding(.horizontal)
                
                Button(action: {
                    processApplication(status: 4, successMessage: "차단했습니다.")
                    print("차단됨")
                }) {
                    Text("차단")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(10).padding(.horizontal)
                
            }

        }
        .alert("알림", isPresented: $showingAlert) {
            Button("확인") {
                onApplicationProcessed()
                self.dismiss()
            }
        } message: {
            Text(alertMessage)
        }
                
    }

    func processApplication(status: Int, successMessage: String) {
        
        guard let url = URL(string: "http://localhost/ip1/processapplication.php") else {
            print("URL Error")
            return
        }
        
        let body = "id=\(managementID)&status=\(status)"
        let encodeData = body.data(using: .utf8)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = encodeData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let resultString = String(data: data, encoding: .utf8) else {
                print("Invalid response data")
                return
            }
            
            print("Server Response: \(resultString)")
            
            DispatchQueue.main.async {
                self.alertMessage = successMessage
                self.showingAlert = true
            }
        }.resume()
    }
}


#Preview {
    ApplicantDetailView(
        managementID: 1,
        teamName: "팀명",
        userName: "이름",
        userEmail: "test@example.com",
        applicantID: 1,
        teamID: 1,
        profileImageUrl: "http://localhost/ip1/uploads/test_profile.jpg",
        onApplicationProcessed: {}
    )
}




