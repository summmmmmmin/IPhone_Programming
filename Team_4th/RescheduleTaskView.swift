import SwiftUI

// TaskView.swift에 정의된 TaskResponse, TaskStatus, DateFormatter.taskDateFormat, TaskServiceLegacy 접근 가능하다고 가정

struct RescheduleTaskView: View {
    @Environment(\.dismiss) var dismiss
    
    let taskData: Task
    let onReschedule: () -> Void
    
    @State private var newSelectedDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var newSelectedTime: Date = Date()
    @State private var isProcessing: Bool = false
    
    private let service = TaskServiceLegacy()

    var finalNewDueDateString: String? {
        let calendar = Calendar.current
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: newSelectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: newSelectedTime)
        
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        combinedComponents.second = timeComponents.second ?? 0
        
        if let combinedDate = calendar.date(from: combinedComponents) {
            return DateFormatter.taskDateFormat.string(from: combinedDate)
        }
        return nil
    }
    
    func finalizeReschedule() {
        guard let newDueOnString = finalNewDueDateString,
              let tID = taskData.id else { return }
        
        isProcessing = true
        
        service.updateStatus(taskID: tID, newStatus: TaskStatus.todo.index, newDueOn: newDueOnString) { result in
            DispatchQueue.main.async {
                self.isProcessing = false
                switch result {
                case .success:
                    self.onReschedule()
                    self.dismiss()
                case .failure(let error):
                    print("재등록 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                
                Text("만료 Task 재등록")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("원본 Task")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("제목: \(taskData.title ?? "제목 없음")")
                        .font(.headline)
                    Text("내용: \(taskData.description ?? "내용 없음")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                Group {
                    Text("새 마감 날짜")
                        .font(.headline)
                    
                    DatePicker("날짜 선택", selection: $newSelectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                    
                    Text("새 마감 시간")
                        .font(.headline)
                    DatePicker("시간 선택", selection: $newSelectedTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                }
                .padding(.horizontal)
                
                Spacer(minLength: 20)
            }
        }
        .navigationTitle("Task 재등록")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isProcessing ? "처리 중..." : "재등록 완료") { finalizeReschedule() }
                    .disabled(isProcessing)
            }
        }
    }
}
