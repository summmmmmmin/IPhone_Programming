//
//  ProfileTabView.swift
//  Team_4th
//
//  Created by mac10 on 10/27/25.
//

import SwiftUI

struct ProfileData: Codable {
    let teamid: Int
    let teamname: String
    let name: String
    let email: String
    let profile_img: String?
}


struct MemberProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var teamID: Int = 0
    @State private var teamName: String = "팀명"
    @State private var userName: String = "이름"
    @State private var userEmail: String = "e-mail"
    @State private var profileImageUrl: String = ""
    
    @State private var showingRemoveAlert = false
    @State private var showingResultAlert = false
    @State private var resultMessage = ""
    
    @Binding var showPersonalHome: Bool
    
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
        
        NavigationStack {
            VStack(spacing: 24) {
                
                //1
                Text(teamName)
                    .font(.system(size: 40))
                    .bold()
                    .padding(.vertical, 10)
                
                //2 프로필 카드
                VStack(spacing: 15) {
                    HStack {
                        Text("팀원")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.15))
                        Spacer()
                    }
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
                    NavigationLink(destination: ModifyProfileView(onUpdateSuccess: {
                        self.fetchProfile()
                    })) {
                        Label("프로필 수정하기", systemImage: "pencil")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    

                    
                    NavigationLink(destination: ProfileTeamSelectView()) {
                        Label("팀 추가하기", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    
                    Button(action: {
                        showingRemoveAlert = true
                    }) {
                        Label("팀 탈퇴하기", systemImage: "xmark.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    
                }
                .padding(.horizontal)
                
         
                
            }
            .onAppear {
                fetchProfile()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.left")
                            Text("뒤로")
                        }
                    }
                }
            }
            
        }
        
        .alert("경고", isPresented: $showingRemoveAlert) {
            Button("탈퇴하기", role: .destructive) {
                removeTeamMembership()
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("\(teamName) 팀에서 정말로 탈퇴하시겠습니까?")
        }
        
        .alert("알림", isPresented: $showingResultAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(resultMessage)
        }
        
        
    }
    
    func fetchProfile() {
        let userid = UserDefaults.standard.integer(forKey: "LoggedInUser")
        
        guard let url = URL(string: "http://localhost/ip1/profile.php") else {
            print("URL Error")
            return
        }
        
        let body = "id=\(userid)"
        let encodeData = body.data(using: .utf8)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = encodeData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let data = data else { return }
            let str2 = String(decoding: data, as: UTF8.self)
            print(str2)
            DispatchQueue.main.async {
                if let profile = try? JSONDecoder().decode(ProfileData.self, from: data) {
                    self.teamID = profile.teamid
                    self.teamName = profile.teamname
                    self.userName = profile.name
                    self.userEmail = profile.email
                    self.profileImageUrl = profile.profile_img ?? ""
                    
                }  else {
                    print("JSON 디코딩 실패")
                    self.teamID
                    self.teamName = "정보 없음"
                    self.userName = "정보 없음"
                    self.userEmail = "정보 없음"
                }
            }
            
        }.resume()
        
        
    }
    
    func removeTeamMembership() {
        let userid = UserDefaults.standard.integer(forKey: "LoggedInUser")
            
        guard let url = URL(string: "http://localhost/ip1/removemember.php") else {
            self.resultMessage = "URL 구성에 오류가 발생했습니다."
            self.showingResultAlert = true
            return
        }
            
        let removeStatus = 3
        let body = "teams_id=\(teamID)&user_id=\(userid)&status=\(removeStatus)&remove_and_unfavorite=1"
        
        let encodeData = body.data(using: .utf8)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = encodeData
            
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.resultMessage = "팀 탈퇴 중 오류가 발생했습니다."
                    self.showingResultAlert = true
                }
                return
            }
                
            guard let data = data, let resultString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
            print("Server Response (Remove): \(resultString)")
                
            DispatchQueue.main.async {
                if resultString == "Success" {
                    self.dismiss()
                    self.showPersonalHome = true
                        
                } else {
                    self.resultMessage = "팀 탈퇴에 실패했습니다. (\(resultString))"
                    self.showingResultAlert = true
                   
                }
            }
        }.resume()
    }
    
    
}



#Preview {
    MemberProfileView(showPersonalHome: .constant(false))
}



