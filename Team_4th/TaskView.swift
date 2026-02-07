import SwiftUI

// 데이터 모델 및 Helper 정의

enum TaskStatus: String, CaseIterable {
    case todo = "TODO"
    case completed = "완료"
    case expired = "만료"
    
    var index: Int {
        switch self {
        case .todo: return 0
        case .completed: return 2
        case .expired: return 99
        }
    }
}

struct Task: Codable, Identifiable {
    var id: Int?
    var project_id: Int?
    var title: String?
    var description: String?
    var status: Int?
    var due_on: String?
    
    var realID: Int { id ?? 0 }
}

struct Tasks: Codable {
    var tasks: [Task]
}

struct TaskResponse: Decodable {
    let success: Bool
    let message: String?
}

extension DateFormatter {
    static let taskDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()
}



struct TaskServiceLegacy {
    enum NetworkError: Error, LocalizedError {
        case invalidURL
        case networkFailure(Error)
        case decodeError
        case serverFailure(message: String)
        
        var errorDescription: String? {
            switch self {
            case .invalidURL: return "잘못된 URL 형식"
            case .networkFailure(let err): return "네트워크 연결 실패: \(err.localizedDescription)"
            case .decodeError: return "서버 응답 디코딩 실패"
            case .serverFailure(let msg): return "서버 처리 실패: \(msg)"
            }
        }
    }

    func fetchTasks(projectID: Int, completion: @escaping (Result<Tasks, NetworkError>) -> Void) {
        // ... (fetchTasks 함수 내용 동일)
        guard let url = URL(string: "http://localhost/ip1/gettasks.php") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "project_id=\(projectID)"
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkFailure(error)))
                return
            }
            guard let data = data else {
                completion(.failure(.decodeError))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(Tasks.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(.decodeError))
            }
        }.resume()
    }

    func updateStatus(taskID: Int, newStatus: Int, newDueOn: String? = nil, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        // ... (updateStatus 함수 내용 동일)
        guard let url = URL(string: "http://localhost/ip1/update_task_status.php") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var body = "task_id=\(taskID)&status=\(newStatus)"
        if let dueOn = newDueOn {
            body += "&due_on=\(dueOn)"
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkFailure(error)))
                return
            }
            guard let data = data else {
                completion(.failure(.decodeError))
                return
            }

            do {
                let result = try JSONDecoder().decode(TaskResponse.self, from: data)
                if result.success {
                    completion(.success(()))
                } else {
                    completion(.failure(.serverFailure(message: result.message ?? "서버에서 실패를 알림")))
                }
            } catch {
                completion(.failure(.decodeError))
            }
        }.resume()
    }

    func deleteTask(taskID: Int, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        // ... (deleteTask 함수 내용 동일)
        guard let url = URL(string: "http://localhost/ip1/delete_task.php") else {
            completion(.failure(.invalidURL))
            return
        }
        
        let body = "task_id=\(taskID)"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkFailure(error)))
                return
            }
            guard let data = data else {
                completion(.failure(.decodeError))
                return
            }

            do {
                let result = try JSONDecoder().decode(TaskResponse.self, from: data)
                if result.success {
                    completion(.success(()))
                } else {
                    completion(.failure(.serverFailure(message: result.message ?? "서버에서 실패를 알림")))
                }
            } catch {
                completion(.failure(.decodeError))
            }
        }.resume()
    }
}


// 개별 할 일 목록 항목

struct TaskItem: View {
    
    var taskData: Task
    var onUpdate: () -> Void // 상태 변경/삭제 시 TaskView에 목록을 새로고침하라고 알림
    
    @State private var isProcessing = false
    private let service = TaskServiceLegacy()
    
    @State private var showingRescheduleView = false

    var isExpired: Bool {
        guard let dueString = taskData.due_on,
              let dueDate = DateFormatter.taskDateFormat.date(from: dueString) else {
            return false
        }
        return taskData.status != TaskStatus.completed.index && dueDate < Date()
    }
    
    func toggleCompletion() {
        let newStatus = (taskData.status == TaskStatus.completed.index) ? TaskStatus.todo.index : TaskStatus.completed.index
        
        guard let tID = taskData.id else { return }
        
        isProcessing = true
        
        service.updateStatus(taskID: tID, newStatus: newStatus) { result in
            DispatchQueue.main.async {
                self.isProcessing = false
                switch result {
                case .success:
                    
                    self.onUpdate()
                case .failure(let error):
                    print("상태 변경 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func deleteTask() {
        guard let tID = taskData.id else { return }
        
        isProcessing = true
        service.deleteTask(taskID: tID) { result in
            DispatchQueue.main.async {
                self.isProcessing = false
                switch result {
                case .success:
                    self.onUpdate()
                case .failure(let error):
                    print("Task 삭제 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    var body: some View {
        
        NavigationLink(destination: TaskDetailView(taskData: Binding(
            get: { self.taskData },
            set: { _ in self.onUpdate() } // 상세 뷰에서 변경 시 목록 새로고침
        ), onUpdate: onUpdate)) {
            HStack {
            
                if isExpired {
                    Text("기한만료")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 5)
                } else {
                   
                    Button(action: toggleCompletion) {
                        Image(systemName: taskData.status == TaskStatus.completed.index ? "checkmark.square.fill" : "square")
                            .foregroundColor(taskData.status == TaskStatus.completed.index ? .blue : .gray)
                    }
                    .disabled(isProcessing)
                    .buttonStyle(.plain)
                }
                
                VStack(alignment: .leading) {
                    Text(taskData.due_on ?? "마감일 미정")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(taskData.title ?? "제목 없음")
                        .font(.headline)
                        .foregroundColor(isExpired ? .red : .primary)
                    Text(taskData.description ?? "내용 없음")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.leading, 5)
                
                Spacer()
                
                if isExpired {
                    Button("재등록") {
                        self.showingRescheduleView = true
                    }
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(5)
                    .disabled(isProcessing)
                    .buttonStyle(.plain)
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(height: 70)
        .padding(.horizontal)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5), lineWidth: 1))
        .padding(.vertical, 5)
        
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                deleteTask()
            } label: {
                Label("삭제", systemImage: "trash.fill")
            }
            .disabled(isProcessing)
        }
        
        NavigationLink(
            destination: RescheduleTaskView(
                taskData: taskData,
                onReschedule: onUpdate
            ),
            isActive: $showingRescheduleView
        ) {
            EmptyView()
        }
    }
}

// taskView (프로젝트별 할 일 목록)

struct TaskView: View {
    let project_ID: Int?
    let project_Name: String
    
    @State var tasks: Tasks = Tasks(tasks: [])
    @State var currentFilter: TaskStatus = .todo
    @State var isCreateTaskActive: Bool = false
    @State var completeProjectActive: Bool = false
    
    @State private var isLoading = false
    @State private var fetchError: Error? = nil
    private let service = TaskServiceLegacy()

    
    var filteredTasks: [Task] {
        tasks.tasks.filter { task in
            let isCompleted = task.status == TaskStatus.completed.index
            var isExpired = false
            
            if let dueString = task.due_on,
               let dueDate = DateFormatter.taskDateFormat.date(from: dueString) {
                isExpired = task.status != TaskStatus.completed.index && dueDate < Date()
            }
            
            switch currentFilter {
            case .todo: return !isCompleted && !isExpired
            case .completed: return isCompleted
            case .expired: return isExpired
            }
        }
    }
    
    func fetchTasksForProject() {
        guard let pID = project_ID else { return }
        isLoading = true
        fetchError = nil
        
        service.fetchTasks(projectID: pID) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let decodedTasks):
                    self.tasks = decodedTasks
                case .failure(let error):
                    self.fetchError = error
                    print("Task 목록 로딩 실패:", error.localizedDescription)
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            

            // 필터링 버튼 UI
            HStack {
                ForEach(TaskStatus.allCases, id: \.self) { status in
                    Button(status.rawValue) { currentFilter = status }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 15)
                        .background(currentFilter == status ? Color.gray.opacity(0.2) : Color.clear)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                Spacer()
            }
            .padding(.horizontal)
            
            if isLoading {
                ProgressView("할 일 목록 로딩 중...")
            } else if fetchError != nil {
                Text("목록을 불러오는데 실패했습니다.")
                    .foregroundColor(.red)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        
                        ForEach(filteredTasks, id: \.realID) { task in
                            
                            TaskItem(taskData: task, onUpdate: fetchTasksForProject)
                        }
                       
                        if filteredTasks.isEmpty {
                            Text("현재 \(currentFilter.rawValue) 상태의 Task가 없습니다.")
                                .foregroundColor(.gray)
                                .padding(.top, 50)
                        }
                    }
                }
            }
            
            NavigationLink(destination: CreateTaskView(projectID: project_ID, onTaskCreated: fetchTasksForProject),
                           isActive: $isCreateTaskActive) { EmptyView() }
        }
        .onAppear { fetchTasksForProject() }
        
        .navigationTitle(project_Name)
        .navigationBarTitleDisplayMode(.large)
        
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("추가") { isCreateTaskActive = true }
            }
        }
        Button("완료"){
            guard let url=URL(string: "http://localhost/ip1/projectcomplete.php")
                else{
                    print("url error")
                    return
                }
            
            
            let ProjectIDValue = self.project_ID ?? 0
            //let projectIDValue = project_ID
            let body = "id=\(ProjectIDValue)"
            let encodeData = body.data(using: .utf8)
                
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
                    
                let status = String(decoding: data, as: UTF8.self)
                print("data ? \(status)")
                if status == "0"{
                    completeProjectActive=true
                    
                }
                else if status == "1"{
                }
                else {
                    completeProjectActive=true
                }
            }.resume()
            
        }
    }
}


