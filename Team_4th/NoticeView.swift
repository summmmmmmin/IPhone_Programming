//김재희 12월 13일 업데이트
//성공

import SwiftUI
import Foundation


// PHP에서 받은 문자열 날짜created_at
extension String {
    func toDate(format: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        let formatter = DateFormatter()
      
        formatter.dateFormat = format
     
        formatter.timeZone = TimeZone.current
        return formatter.date(from: self)
    }
}


//Notice, TeamInfo, Comment

struct Notice: Codable {
    var id: Int?
    var team_id: Int?
    var author_id: Int? // 작성자 ID
    
    // PHP에서 JOIN으로 가져온 작성자 이름
    var author_name: String?
    
    var title: String?
    var body: String?
    var is_pinned: Int?
    
    // PHP에서 가져온 생성 시간 (String 형태로 받음)
    var created_at: String?
}

struct Notices: Codable {
    var notices: [Notice]
}

struct TeamInfo: Decodable {
    let teams_id: Int
    let teams_name: String
}

struct Comment: Codable {
    var id: Int?
    var uniqueID: Int {
        return id ?? Int.random(in: 1...100000)
    }
    var notice_id: Int?
    var user_id: Int?      // 댓글 작성자 ID
    var content: String?
    var nickname: String?  // 댓글 작성자 닉네임-> 조인함
}

// 글 개별 뷰
struct CommentRow: View {
    let comment: Comment
    let currentUserID: Int
    let onEditTapped: (Comment) -> Void
    let onDeleteTapped: (Comment) -> Void
    
    var isAuthor: Bool {
        return comment.user_id == currentUserID && currentUserID > 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(comment.nickname ?? "익명").font(.subheadline).bold()
                if isAuthor {
                    Text("(나)").font(.caption).foregroundColor(.blue)
                }
                Spacer()
                
                // 수정/삭제 버튼 (작성자에게만 표시)
                if isAuthor {
                    Button("수정") {
                        onEditTapped(comment)
                    }
                    .font(.caption)
                    .foregroundColor(.orange)
                    
                    Text("|").font(.caption).foregroundColor(.gray)
                    
                    Button("삭제") {
                        onDeleteTapped(comment)
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
            }
            Text(comment.content ?? "내용 없음").font(.body)
                .padding(.leading, 5)
        }
        .padding(.vertical, 5)
    }
}


//댓글 섹션 뷰

struct CommentSectionView: View {
    let noticeID: Int?
    let currentUserID: Int
    let currentUserName: String
    
    @State private var comments: [Comment] = []
    @State private var newCommentContent: String = ""
    @State private var editingComment: Comment? = nil
    
    @State private var showingDeleteCommentAlert = false
    @State private var commentToDelete: Comment? = nil
    
    @State private var loadError: Bool = false //  로드 오류 상태
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("댓글 (\(comments.count))").font(.headline)
                .padding(.horizontal)
                
            //댓글 목록
            if loadError {
             
                Text("⚠️ 댓글을 불러오는 데 실패했습니다. 서버 상태를 확인해 주세요.")
                    .foregroundColor(.red)
                    .padding(.horizontal)
            } else if comments.isEmpty {
                Text("아직 댓글이 없습니다.").foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                ForEach(comments, id: \.uniqueID) { comment in
                    CommentRow(
                        comment: comment,
                        currentUserID: currentUserID,
                        onEditTapped: { comment in
                            self.editingComment = comment
                            self.newCommentContent = comment.content ?? ""
                        },
                        onDeleteTapped: { comment in
                            self.commentToDelete = comment
                            self.showingDeleteCommentAlert = true
                        }
                    )
                    .padding(.horizontal)
                    Divider()
                }
            }
        }
        .onAppear {
            loadComments() // 댓글 뷰가 나타날 때 댓글 로드
        }
        
        //댓글삭제확인알람
        .alert("댓글 삭제", isPresented: $showingDeleteCommentAlert) {
            Button("삭제", role: .destructive) {
                if let comment = commentToDelete {
                    deleteComment(commentId: comment.id ?? 0)
                }
                commentToDelete = nil
            }
            Button("취소", role: .cancel) {
                commentToDelete = nil
            }
        } message: {
            Text("정말로 이 댓글을 삭제하시겠습니까?")
        }
        
        // 댓글 입력과 수정
        .safeAreaInset(edge: .bottom) {
            VStack {
                if editingComment != nil {
                    // 수정 모드 메시지
                    HStack {
                        Text("댓글 수정 중...").font(.caption).foregroundColor(.orange)
                        Spacer()
                        Button("취소") {
                            editingComment = nil
                            newCommentContent = ""
                        }.font(.caption).foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
                HStack {
                    TextField(editingComment == nil ? "댓글을 입력하세요..." : "수정할 내용을 입력하세요...", text: $newCommentContent)
                        .textFieldStyle(.roundedBorder)
                    
                    Button(editingComment == nil ? "등록" : "수정") {
                        if editingComment == nil {
                            createComment()
                        } else {
                            updateComment()
                        }
                    }
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(newCommentContent.isEmpty ? Color.gray : (editingComment == nil ? Color.blue : Color.orange))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(newCommentContent.isEmpty)
                }
                .padding(.horizontal).padding(.vertical, 8)
                .background(Color.secondary.opacity(0.1))
            }
        }
    }
    
    // CRUD
    
    func loadComments() {
        guard let id = noticeID, id > 0 else { return }
        guard let url = URL(string: "http://localhost/ip1/getComments.php") else { return }

        let body = "notice_id=\(id)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            do {
                let decodedComments = try JSONDecoder().decode([Comment].self, from: data)
                DispatchQueue.main.async {
                    self.comments = decodedComments
                    self.loadError = false // 성공 시 오류 상태 초기화
                }
            } catch {
                let rawStr = String(decoding: data, as: UTF8.self)
                print("댓글 디코딩 오류:", error)
                print("서버 원시 데이터:", rawStr)
                DispatchQueue.main.async {
                    self.comments = []
                    self.loadError = true // 오류 상태 설정
                }
            }
        }.resume()
    }
    
    func createComment() {
        guard let id = noticeID, id > 0, !newCommentContent.isEmpty else { return }
        guard let url = URL(string: "http://localhost/ip1/createComment.php") else { return }
        
        let encodedContent = newCommentContent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let body = "notice_id=\(id)&user_id=\(currentUserID)&content=\(encodedContent)"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            let result = String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
            
            DispatchQueue.main.async {
                if result == "1" {
                    newCommentContent = ""
                    loadComments()
                } else {
                    print("댓글 작성 실패 (서버 응답): \(result)")
                }
            }
        }.resume()
    }
    
    func updateComment() {
        guard let commentToEdit = editingComment, let commentID = commentToEdit.id, commentID > 0 else { return }
        guard !newCommentContent.isEmpty else { return }
        guard let url = URL(string: "http://localhost/ip1/updateComment.php") else { return }
        
        let encodedContent = newCommentContent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let body = "id=\(commentID)&content=\(encodedContent)"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            let result = String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
            
            DispatchQueue.main.async {
                if result == "1" {
                    editingComment = nil
                    newCommentContent = ""
                    loadComments()
                } else {
                    print("댓글 수정 실패 (서버 응답): \(result)")
                }
            }
        }.resume()
    }

    func deleteComment(commentId: Int) {
        guard commentId > 0 else { return }
        guard let url = URL(string: "http://localhost/ip1/deleteComment.php") else { return }
        
        let body = "id=\(commentId)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            let result = String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
            
            DispatchQueue.main.async {
                if result == "1" {
                    loadComments()
                } else {
                    print("댓글 삭제 실패 (서버 응답): \(result)")
                }
            }
        }.resume()
    }
}

//  게시글 정보 뷰 - 작성자 이름 및 시간 표시 로직 추가

struct NoticeInfoView: View {
    @Environment(\.dismiss) var dismiss
    @State var noticeData: Notice
    
    let currentUserID = UserDefaults.standard.integer(forKey: "LoggedInUser")
    let currentUserName = UserDefaults.standard.string(forKey: "LoggedInUserName") ?? "익명"
    
    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    
    var onUpdateOrDeleteSuccess: (() -> Void)? = nil
    
    var isAuthor: Bool {
        return noticeData.author_id == currentUserID && currentUserID > 0
    }
    
    func updateNoticeData(updatedNotice: Notice) {
        self.noticeData = updatedNotice
        self.onUpdateOrDeleteSuccess?()
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 게시글 본문 섹션
                VStack(alignment: .leading, spacing: 10) {
                    Text(noticeData.title ?? "제목 없음").font(.largeTitle).bold()
                    
                    //수정/추가된 부분 작성자 이름과 시간 표시함 단위도 바꿧심
                    HStack {
                        // 작성자 이름 표시 PHP에서 author_name으로 가져옴
                        Text("작성자: \(noticeData.author_name ?? "알 수 없음")")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            
                        Spacer()
                            
                       
                        if let dateString = noticeData.created_at,
                           let date = dateString.toDate() {
                            HStack(spacing: 4) {
                                Text(date, style: .date) // 예: 2025년 12월 14일
                                Text(date, style: .time) // 예: 오후 8:50
                            }
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        } else {
                            Text(noticeData.created_at ?? "")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.bottom, 5) // 제목과 내용 사이에 여백 추가
                    
                    Divider()
                    
                    Text(noticeData.body ?? "내용 없음").font(.body)
                }
                .padding(.horizontal)

                Divider()
                
                // 댓글 섹션을 CommentSectionView로 호출
                CommentSectionView(
                    noticeID: noticeData.id,
                    currentUserID: currentUserID,
                    currentUserName: currentUserName
                )
            }
        }
        .navigationTitle(noticeData.is_pinned == 1 ? "고정 게시글 상세" : "일반 게시글 상세")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isAuthor {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button("수정") { showingEditSheet = true }
                        Button("삭제") { showingDeleteAlert = true }.foregroundColor(.red)
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditNoticeView(
                noticeToEdit: noticeData,
                onEditSuccess: updateNoticeData
            )
        }
        .alert("게시글 삭제", isPresented: $showingDeleteAlert) {
            Button("삭제", role: .destructive) { deleteNotice() }
            Button("취소", role: .cancel) {}
        } message: {
            Text("정말로 이 게시글을 삭제하시겠습니까?")
        }
    }
    
    // 게시글 삭제 로직 /서버
    func deleteNotice() {
        guard let noticeID = noticeData.id, noticeID > 0 else { return }
        
        guard let url = URL(string: "http://localhost/ip1/deleteNotice.php") else {
            print(" 삭제 URL 오류"); return
        }

        let body = "id=\(noticeID)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("게시글 삭제 요청 실패: 서버 응답 데이터 없음"); return
            }
            let result = String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
            
            DispatchQueue.main.async {
                if result == "1" {
                    print("게시글 \(noticeID) 삭제 성공")
                    self.dismiss()
                    self.onUpdateOrDeleteSuccess?()
                } else {
                    print("게시글 삭제 실패: 서버 응답: \(result)")
                }
            }
        }.resume()
    }
}

//게시글 생성 뷰
struct CreateNoticeView: View {
    @State var teamID: Int
    let teams_name: String
    let authorID: Int
    let onNoticeCreated: () -> Void
    
    @State private var noticeTitle: String = ""
    @State private var noticeContent: String = ""
    @State private var isPinned: Bool = true
    
    @Environment(\.dismiss) var dismiss
    
    @State private var showResultAlert = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Toggle("게시글 상단 고정", isOn: $isPinned)
                    .padding(.horizontal)
                
                TextField("제목을 입력하세요", text: $noticeTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle()).padding(.horizontal)
                
                TextEditor(text: $noticeContent)
                    .frame(height: 200)
                    .border(Color.gray.opacity(0.5), width: 1).padding(.horizontal)
                
                Button("등록하기") {
                    createNotice()
                }
                .padding().frame(maxWidth: .infinity)
                .background(Color.blue).foregroundColor(.white).cornerRadius(10)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("게시글 작성")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("닫기") { dismiss() }
                }
            }
            .alert(alertTitle, isPresented: $showResultAlert) {
                Button("확인") {
                    if alertTitle == "성공" {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // 서버 통신: 게시글/공지 등록
    func createNotice() {
        guard !noticeTitle.isEmpty && !noticeContent.isEmpty else {
            alertTitle = "경고"; alertMessage = "제목과 내용을 모두 입력해주세요."; showResultAlert = true; return
        }
        
        guard authorID > 0 else {
            alertTitle = "오류"; alertMessage = "사용자 ID를 찾을 수 없습니다. 다시 로그인해 주세요."; showResultAlert = true; return
        }
        
        guard let url = URL(string: "http://localhost/ip1/createNotice.php") else { return }
        
        let pinType = isPinned ? 1 : 0
        
        let encodedTitle = noticeTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedContent = noticeContent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        let body = "teams_id=\(teamID)&title=\(encodedTitle)&content=\(encodedContent)&author_id=\(authorID)&is_pinned=\(pinType)"
        let encodeData = body.data(using: .utf8)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = encodeData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            let result = String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
            
            DispatchQueue.main.async {
                if result == "1" {
                    self.alertTitle = "성공"; self.alertMessage = "게시글이 성공적으로 등록되었습니다."
                    self.onNoticeCreated()
                } else {
                    self.alertTitle = "등록 실패"; self.alertMessage = "게시글 등록에 실패했습니다. (서버 응답: \(result))"
                }
                self.showResultAlert = true
            }
        }.resume()
    }
}

//게시글 수정 뷰
struct EditNoticeView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var noticeToEdit: Notice
    let onEditSuccess: (Notice) -> Void
    
    @State private var noticeTitle: String
    @State private var noticeContent: String
    @State private var isPinned: Bool
    
    @State private var showResultAlert = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    init(noticeToEdit: Notice, onEditSuccess: @escaping (Notice) -> Void) {
        _noticeToEdit = State(initialValue: noticeToEdit)
        self.onEditSuccess = onEditSuccess
        
        _noticeTitle = State(initialValue: noticeToEdit.title ?? "")
        _noticeContent = State(initialValue: noticeToEdit.body ?? "")
        _isPinned = State(initialValue: noticeToEdit.is_pinned == 1)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Toggle("게시글 상단 고정 ", isOn: $isPinned)
                    .padding(.horizontal)
                
                TextField("제목을 입력하세요", text: $noticeTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle()).padding(.horizontal)
                
                TextEditor(text: $noticeContent)
                    .frame(height: 200)
                    .border(Color.gray.opacity(0.5), width: 1).padding(.horizontal)
                
                Button("수정 완료") {
                    updateNotice()
                }
                .padding().frame(maxWidth: .infinity)
                .background(Color.orange).foregroundColor(.white).cornerRadius(10)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("게시글 수정")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") { dismiss() }
                }
            }
            .alert(alertTitle, isPresented: $showResultAlert) {
                Button("확인") {
                    if alertTitle == "성공" {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // 공지 수정
    func updateNotice() {
        guard !noticeTitle.isEmpty && !noticeContent.isEmpty else {
            alertTitle = "경고"; alertMessage = "제목과 내용을 모두 입력해주세요."; showResultAlert = true; return
        }
        guard let noticeID = noticeToEdit.id, noticeID > 0 else {
            alertTitle = "오류"; alertMessage = "게시글 ID를 찾을 수 없습니다."; showResultAlert = true; return
        }
        
        guard let url = URL(string: "http://localhost/ip1/updateNotice.php") else { return }
        
        let pinType = isPinned ? 1 : 0
        
        let encodedTitle = noticeTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedContent = noticeContent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        // 수정된 데이터와 게시글 ID를 서버에 전송
        let body = "id=\(noticeID)&title=\(encodedTitle)&content=\(encodedContent)&is_pinned=\(pinType)"
        let encodeData = body.data(using: .utf8)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = encodeData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            let result = String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
            
            DispatchQueue.main.async {
                if result == "1" {
                    self.alertTitle = "성공"; self.alertMessage = "게시글이 성공적으로 수정되었습니다."
                    
                    // 새로고침을 위한 데이터 업데이트
                    var updatedNotice = noticeToEdit
                    updatedNotice.title = noticeTitle
                    updatedNotice.body = noticeContent
                    updatedNotice.is_pinned = pinType
                    
                    // author_name과 created_at은 수정되지 않으므로 그대로 유지됨
                    self.onEditSuccess(updatedNotice)
                    
                } else {
                    self.alertTitle = "수정 실패"; self.alertMessage = "게시글 수정에 실패했습니다. (서버 응답: \(result))"
                }
                self.showResultAlert = true
            }
        }.resume()
    }
}


// 게시판 목록 뷰
struct NoticeView: View {
    @State var currentTeamID: Int = 0
    @State var currentTeamName: String = "팀 정보를 불러오는 중..."
    
    @State private var noticesData: Notices = Notices(notices: [])
    @State private var showCreateNotice = false
    
    var pinnedPosts: [Notice] {
        noticesData.notices.filter { $0.is_pinned == 1 }
    }
    
    var generalPosts: [Notice] {
        noticesData.notices.filter { $0.is_pinned == 0 || $0.is_pinned == nil }
    }
    
    func reloadNotices() {
        loadTeamNotices(teamID: currentTeamID)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("게시판 목록")
                    .font(.title2).padding(.vertical, 10)
                
                if currentTeamID > 0 {
                    List {
                        // 고정된 게시글 섹션
                        if !pinnedPosts.isEmpty {
                            Section(header: Text("📌 상단 고정 게시글")) {
                                ForEach(pinnedPosts, id: \.id) { notice in
                                    NavigationLink(destination: NoticeInfoView(noticeData: notice, onUpdateOrDeleteSuccess: self.reloadNotices)) {
                                        VStack(alignment: .leading) {
                                            Text(notice.title ?? "제목 없음").font(.headline)
                                            Text(notice.body ?? "내용 없음").font(.subheadline).lineLimit(1)
                                        }
                                        .foregroundColor(.red) // 고정된 게시글 강조
                                    }
                                }
                            }
                        }
                        
                        // 일반 게시글 섹션
                        if !generalPosts.isEmpty {
                            Section(header: Text("📝 일반 게시글")) {
                                ForEach(generalPosts, id: \.id) { post in
                                    NavigationLink(destination: NoticeInfoView(noticeData: post, onUpdateOrDeleteSuccess: self.reloadNotices)) {
                                        VStack(alignment: .leading) {
                                            Text(post.title ?? "제목 없음").font(.headline)
                                            Text(post.body ?? "내용 없음").font(.subheadline).lineLimit(1)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .refreshable {
                        loadTeamNotices(teamID: currentTeamID)
                    }
                } else if currentTeamID == -1 {
                    Text("소속된 팀이 없습니다.")
                } else {
                    ProgressView(currentTeamName)
                }
            }
            .navigationTitle(currentTeamID > 0 ? currentTeamName : "팀 게시판")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreateNotice = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                    .disabled(currentTeamID <= 0)
                }
            }
        }
        .onAppear {
            fetchUserTeamID()
        }
        .sheet(isPresented: $showCreateNotice) {
            let loggedInUserID = UserDefaults.standard.integer(forKey: "LoggedInUser")
            CreateNoticeView(
                teamID: currentTeamID,
                teams_name: currentTeamName,
                authorID: loggedInUserID,
                onNoticeCreated: self.reloadNotices
            )
        }
    }
    
    //로그인 사용자 팀 ID/이름 가져오기 (getUsersTeamID.php)
    func fetchUserTeamID() {
        let userid = UserDefaults.standard.integer(forKey: "LoggedInUser")
        
        guard userid > 0 else {
            self.currentTeamID = -1
            self.currentTeamName = "로그인 필요"
            return
        }

        guard let url = URL(string: "http://localhost/ip1/getUsersTeamID.php") else {
            self.currentTeamName = "서버 URL 오류"
            return
        }
        
        let body = "userid=\(userid)"
        let encodeData = body.data(using: .utf8)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = encodeData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data else { return }
                
                do {
                    let result = try JSONDecoder().decode(TeamInfo.self, from: data)
                    
                    if result.teams_id > 0 {
                        self.currentTeamID = result.teams_id
                        self.currentTeamName = result.teams_name
                        self.loadTeamNotices(teamID: result.teams_id)
                    } else {
                        self.currentTeamID = -1
                        self.currentTeamName = "소속된 팀 없음"
                    }
                } catch {
                    let rawStr = String(decoding: data, as: UTF8.self)
                    print("JSON 디코딩 오류 또는 서버 응답: \(rawStr), Error: \(error)")
                    self.currentTeamID = -1
                    self.currentTeamName = "정보 로드 실패 (서버 응답 형식 확인 필요)"
                }
            }
        }.resume()
    }
    
    // 공지 목록 불러오기 (getNotices.php)
    func loadTeamNotices(teamID: Int) {
        guard teamID > 0 else { return }
        
        guard let url = URL(string: "http://localhost/ip1/getNotices.php") else {
            print("공지 목록 URL Error")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let body = "teams_id=\(teamID)"
        let encodeData = body.data(using: .utf8)
        request.httpBody = encodeData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data else { return }
                
                do {
                    let decoder = JSONDecoder()
                    // PHP에서 보낸 author_name과 created_at이 포함된 데이터를 디코딩
                    let result = try decoder.decode(Notices.self, from: data)
                    self.noticesData = result
                } catch {
                    let rawStr = String(decoding: data, as: UTF8.self)
                    print("디코딩 오류 또는 서버 응답: \(rawStr)")
                    self.noticesData = Notices(notices: [])
                }
            }
        }.resume()
    }
}

// MARK: - 8. 프리뷰
#Preview {
    NoticeView()
}


