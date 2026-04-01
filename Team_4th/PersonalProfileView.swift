//
//  ProfileTabView.swift
//  Team_4th
//
//  Created by mac10 on 10/27/25.
//

import SwiftUI

struct PersonalProfileData: Codable {
    let teamid: Int
    let teamname: String
    let name: String
    let email: String
    let profile_img: String?
}


struct PersonalProfileView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var teamID: Int = 0
    @State private var teamName: String = "개인 프로필"
    @State private var userName: String = "이름"
    @State private var userEmail: String = "e-mail"
    @State private var profileImageUrl: String = ""
    
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
                Text("\(userName)님의 프로필")
                    .font(.system(size: 40))
                    .bold()
                    .padding(.vertical, 10)
                
                //2 프로필 카드
                VStack(spacing: 15) {
                    HStack {
                        Text("개인")
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
        
        
    }
    
    func fetchProfile() {
        let userID = UserDefaults.standard.integer(forKey: "LoggedInUser")
        
        guard let url = URL(string: "http://localhost/ip1/personalprofile.php") else {
            print("URL Error")
            return
        }
        
        let body = "id=\(userID)"
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
            
            DispatchQueue.main.async {
                if let profile = try? JSONDecoder().decode(ProfileData.self, from: data) {
                    self.teamID = profile.teamid
                    self.teamName = profile.teamname
                    self.userName = profile.name
                    self.userEmail = profile.email
                    self.profileImageUrl = profile.profile_img ?? ""
                    
                }  else {
                    print("JSON 디코딩 실패")
                    self.teamName = "정보 없음"
                    self.userName = "정보 없음"
                    self.userEmail = "정보 없음"
                }
            }
            
        }.resume()
                    
                    
    }
    

}



struct PersonalProfilebutton: View {
    let title: String
    
    var body: some View {
        Button(action: {
            //액션
        }) {
            Text(title)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(white: 0.2))
                .cornerRadius(10)
        }
    }
    
    
}


#Preview {
    PersonalProfileView()
}



