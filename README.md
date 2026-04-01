<div align="center">

<br>

# 📋 TeamSync

### iOS 팀 협업 프로젝트 관리 애플리케이션

<br>

[![iOS](https://img.shields.io/badge/Platform-iOS-000000?style=for-the-badge&logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-F05138?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-0D96F6?style=for-the-badge&logo=swift&logoColor=white)](https://developer.apple.com/xcode/swiftui/)
[![PHP](https://img.shields.io/badge/Backend-PHP_·_MySQL-777BB4?style=for-the-badge&logo=php&logoColor=white)](https://www.php.net)

<br>

> **팀장 · 부팀장 · 팀원 3단계 역할 체계로 팀 내 권한을 분리하고, URLSession + PHP REST API 44개 엔드포인트로 팀 전체 데이터를 실시간 동기화합니다.**
>
> 팀 생성 · 가입 신청 · 승인 / 프로젝트 & 태스크 추적 / 미팅 & 공지 / 역할별 UI 완전 분리

<br>

**팀 프로젝트 4인**

<br>

</div>

---

## 📌 목차

1. [왜 만들었나](#-왜-만들었나)
2. [주요 기능](#-주요-기능)
3. [기술 스택](#️-기술-스택)
4. [화면 구성 & 네비게이션 흐름](#-화면-구성--네비게이션-흐름)
5. [핵심 구현](#-핵심-구현)
   - [로그인 → 팀 자동 진입 로직](#1-로그인--팀-자동-진입-로직)
   - [팀 가입 신청 3-state 흐름](#2-팀-가입-신청-3-state-흐름)
   - [역할별 UI 완전 분리](#3-역할별-ui-완전-분리)
   - [URLSession 네트워킹 패턴](#4-urlsession-네트워킹-패턴)
6. [API 엔드포인트 44개](#-api-엔드포인트-44개)
7. [트러블슈팅](#-트러블슈팅)
8. [팀 구성 & 역할](#-팀-구성--역할)

---

## 💡 왜 만들었나

팀 프로젝트를 진행하면서 팀장·부팀장·팀원 간 역할이 다른데도 같은 화면을 쓰는 불편함이 있었다. 팀원에게 보여선 안 되는 멤버 관리 메뉴, 팀장에게만 필요한 가입 승인 흐름이 뒤섞이면 UX와 보안 모두 나빠진다.

TeamSync는 **로그인 직후 역할을 판별**해 팀장·부팀장·팀원 각각 전혀 다른 UI를 제공한다. PHP REST API 44개 엔드포인트 위에서 URLSession과 `Codable`로 통신하며, `UserDefaults`로 세션과 현재 팀 ID를 유지한다.

---

## ✨ 주요 기능

<!--
  아래 img 태그의 src를 실제 스크린샷 경로로 교체해주세요.
  예: src="screenshots/team_home.png"
-->

<table>
<tr>
<td width="50%" valign="top">

### 👥 팀 생성 · 전환 · 가입

<!-- <img src="screenshots/team_select.png" width="100%"> -->

- 팀 생성 · 전체 팀 검색 · 가입 신청
- 즐겨찾기 기반 **로그인 직후 팀 자동 진입**
- 다중 팀 소속 지원 — 탭에서 즉시 팀 전환
- 가입 신청 상태 **3단계** 표시 (미신청 · 신청중 · 가입완료)

</td>
<td width="50%" valign="top">

### 🔐 3단계 역할 기반 UI

<!-- <img src="screenshots/role_ui.png" width="100%"> -->

- **팀장(0)**: 멤버 관리 · 가입 승인/거절 · 팀원 추방 · 부팀장 지정 · 팀장 권한 위임
- **부팀장(1)**: 멤버 조회 · 일부 관리 기능
- **팀원(2)**: 기본 프로젝트 · 태스크 · 미팅 · 공지 접근
- 역할별 프로필 뷰 완전 분리

</td>
</tr>
<tr>
<td width="50%" valign="top">

### 📁 프로젝트 & 태스크

<!-- <img src="screenshots/project_task.png" width="100%"> -->

- 팀별 프로젝트 생성 · 수정 · 완료 처리
- 프로젝트 상태 추적 (진행중 · 완료 · 기한초과)
- 태스크 생성 / 수정 / 삭제 · 마감일 설정
- 태스크 상태 관리 (TODO · 완료 · 만료)

</td>
<td width="50%" valign="top">

### 📅 미팅 · 공지 · 댓글

<!-- <img src="screenshots/meeting_notice.png" width="100%"> -->

- 미팅 일정 기록 · 조회 · 상세 정보
- 공지사항 작성 · 핀 고정
- 댓글 CRUD (작성자 본인만 수정/삭제)
- 홈 대시보드에서 최신 프로젝트 · 미팅 요약

</td>
</tr>
</table>

---

## 🛠️ 기술 스택

| 분류 | 기술 | 비고 |
|---|---|---|
| **플랫폼** | iOS | |
| **언어** | Swift | |
| **UI 프레임워크** | SwiftUI | `@State` · `@Binding` · `NavigationView` · `TabView` |
| **네트워킹** | URLSession | POST · URL-encoded form data · `Codable` JSON 디코딩 |
| **백엔드** | PHP | REST API 44개 엔드포인트 |
| **데이터베이스** | MySQL | 팀 · 멤버십 · 프로젝트 · 태스크 · 미팅 · 공지 |
| **세션** | UserDefaults | `LoggedInUser`(userId) · `SelectedTeam`(teamId) 유지 |
| **이미지** | AsyncImage | 프로필 사진 비동기 로드 |

---

## 📱 화면 구성 & 네비게이션 흐름

```
Team_4thApp (진입점)
│
└── ContentView
    ├── LoginView             ── 로그인 (userid → UserDefaults)
    │   └── getfavoriteteam.php 호출
    │       ├── teamId == 0  → TeamSelectView  (팀 선택 화면)
    │       └── teamId > 0   → TeamHomeView    (팀 홈 바로 진입)
    │
    └── SignupView            ── 회원가입 (특수문자·숫자 유효성 검사)


TabBarView (로그인 후 메인 탭)
│
├── 🏠 TeamHomeView           ── 팀 홈 대시보드
│   ├── 최신 프로젝트 요약
│   ├── 최신 미팅 요약
│   ├── 다른 팀 전환 버튼
│   └── [프로필 버튼] → ifleader.php 호출
│       ├── role=0 → LeaderProfileView       팀장 전용
│       ├── role=1 → ViceLeaderProfileView   부팀장 전용
│       └── role=2 → MemberProfileView       팀원
│
├── ✅ TaskView               ── 태스크 목록 & 상태 관리
│   ├── CreateTaskView        ── 생성
│   ├── TaskDetailView        ── 상세
│   └── ModifyTaskView        ── 수정 · 일정 재조정
│
├── 📅 MeetingsView           ── 미팅 목록
│   ├── CreateMeetingsView
│   ├── MeetingsInfoView
│   └── ModifyMeetingsView
│
├── 📢 NoticeView             ── 공지 · 댓글
│   ├── CreateCommentView
│   └── ModifyCommentView / ModifyNoticeView
│
└── ⚙️ ManagementView         ── 팀장 전용 멤버 관리
    ├── ApplicantDetailView   ── 가입 신청 승인/거절
    ├── MembersDetailView     ── 역할 변경 (부팀장 지정/해제)
    └── 팀원 추방 · 팀장 권한 위임
```

---

## 🔬 핵심 구현

### 1. 로그인 → 팀 자동 진입 로직

> 사용자가 여러 팀에 소속될 수 있는 구조에서, 로그인 직후 **즐겨찾기 팀이 있으면 바로 팀 홈으로**, 없으면 팀 선택 화면으로 분기합니다.

```swift
// LoginView.swift — 로그인 성공 직후
URLSession.shared.dataTask(with: loginRequest) { data, response, error in
    guard let data = data else { return }
    let str = String(decoding: data, as: UTF8.self)

    DispatchQueue.main.async {
        if let userid = Int(str), userid > 0 {
            // 1. userId를 세션에 저장
            UserDefaults.standard.set(userid, forKey: "LoggedInUser")

            // 2. 즐겨찾기 팀 조회 (getfavoriteteam.php)
            let body = "id=\(userid)"
            // ... URLRequest 구성 ...
            URLSession.shared.dataTask(with: favoriteTeamRequest) { data, _, _ in
                guard let data = data else { return }
                let teamStr = String(decoding: data, as: UTF8.self)

                DispatchQueue.main.async {
                    if let teamId = Int(teamStr), teamId > 0 {
                        // 즐겨찾기 팀 있음 → 팀 홈으로 바로 이동
                        UserDefaults.standard.set(teamId, forKey: "SelectedTeam")
                        isTeamHomeActive = true
                    } else {
                        // 즐겨찾기 없음 → 팀 선택 화면
                        isSucceedLogin = true
                    }
                }
            }.resume()
        }
    }
}.resume()
```

```php
// getfavoriteteam.php — 즐겨찾기 팀 조회
SELECT teams.id
FROM team_memberships
LEFT JOIN teams ON teams.id = team_memberships.teams_id
WHERE team_memberships.user_id = '$id'
  AND team_memberships.favorite = 1
  AND team_memberships.status  = 0   -- 가입 완료 상태만
ORDER BY team_memberships.created_at DESC
LIMIT 1;
```

---

### 2. 팀 가입 신청 3-state 흐름

> `alreadyapplied.php`는 **0 · 1 · 3** 세 가지 값을 반환하며, 각 상태에 따라 UI를 완전히 다르게 표시합니다.

```swift
// TeamSelectView.swift — 팀 목록에서 팀 선택 시 신청 상태 확인
let body = "userid=\(userid)&teams_id=\(teamData.id ?? 0)"
// ... URLRequest 구성 ...

URLSession.shared.dataTask(with: request) { data, _, error in
    guard let data = data else { return }
    let str = String(decoding: data, as: UTF8.self)

    DispatchQueue.main.async {
        switch str {
        case "0":
            // 미신청 → "가입 신청" 버튼 활성화
            isApplied = false; isJoined = false
        case "1":
            // 신청중 → "신청 취소" 버튼 표시
            isApplied = true
        case "3":
            // 이미 가입 → 팀 홈으로 바로 이동
            isJoined = true
        default:
            break
        }
    }
}.resume()
```

```php
// alreadyapplied.php — 신청 상태 3단계 판별
// status=1 → 승인 대기(신청중), status=0 → 승인 완료(가입)

$pending_sql = "SELECT id FROM team_memberships
                WHERE user_id='$userid' AND teams_id='$teams_id'
                AND status = 1 LIMIT 1";
if (mysqli_num_rows(mysqli_query($conn, $pending_sql)) > 0) {
    echo 1;   // 신청중
    exit;
}

$joined_sql = "SELECT id FROM team_memberships
               WHERE user_id='$userid' AND teams_id='$teams_id'
               AND status = 0 LIMIT 1";
if (mysqli_num_rows(mysqli_query($conn, $joined_sql)) > 0) {
    echo 3;   // 가입 완료
    exit;
}

echo 0;       // 미신청
```

**팀장 측 — 가입 신청 승인/거절 (processapplication.php):**

```swift
// ApplicantDetailView.swift
func processApplication(applicantId: Int, action: String) {
    let body = "applicant_id=\(applicantId)&action=\(action)"  // action: "approve" or "reject"
    // URLSession POST → 성공 시 신청자 목록 새로고침
}
```

---

### 3. 역할별 UI 완전 분리

> 로그인 상태에서 프로필 탭 진입 시 `ifleader.php`를 호출해 역할 코드(0 · 1 · 2)를 받아 각각 다른 뷰로 이동합니다. 팀원에게는 멤버 관리 탭 자체가 표시되지 않습니다.

```swift
// TeamHomeView.swift — 프로필 버튼 클릭 시 역할 판별
Button("프로필") {
    let body = "id=\(userid)&teams_id=\(teams_id)"
    // ... URLRequest 구성 ...

    URLSession.shared.dataTask(with: request) { data, _, _ in
        guard let data = data else { return }
        let role = String(decoding: data, as: UTF8.self)

        DispatchQueue.main.async {
            switch role {
            case "0":
                movetoLeaderProfile = true      // LeaderProfileView — 전체 관리
            case "1":
                movetoViceLeaderProfile = true  // ViceLeaderProfileView — 부분 관리
            default:
                movetoMemberProfile = true      // MemberProfileView — 기본 뷰
            }
        }
    }.resume()
}

// NavigationLink — 각 역할별 전용 뷰로 이동
NavigationLink(destination: LeaderProfileView(teams_id: teams_id),
               isActive: $movetoLeaderProfile) { EmptyView() }
NavigationLink(destination: ViceLeaderProfileView(teams_id: teams_id),
               isActive: $movetoViceLeaderProfile) { EmptyView() }
NavigationLink(destination: MemberProfileView(teams_id: teams_id),
               isActive: $movetoMemberProfile) { EmptyView() }
```

```php
// ifleader.php — 팀 내 역할 반환
SELECT role FROM team_memberships
LEFT JOIN teams ON team_memberships.teams_id = teams.id
WHERE team_memberships.user_id = '$userid'
  AND team_memberships.status = 0;

// 반환값: 0 = 팀장, 1 = 부팀장, 2 = 팀원, 7 = 미소속
```

**역할별 노출 기능 차이:**

| 기능 | 팀장(0) | 부팀장(1) | 팀원(2) |
|---|:---:|:---:|:---:|
| 멤버 관리 탭 | ✅ | ✅ (일부) | ❌ |
| 가입 신청 승인/거절 | ✅ | ❌ | ❌ |
| 팀원 추방 | ✅ | ❌ | ❌ |
| 부팀장 지정/해제 | ✅ | ❌ | ❌ |
| 팀장 권한 위임 | ✅ | ❌ | ❌ |
| 프로젝트 · 태스크 | ✅ | ✅ | ✅ |
| 공지 · 미팅 | ✅ | ✅ | ✅ |

---

### 4. URLSession 네트워킹 패턴

> 모든 API 요청은 동일한 패턴으로 구성됩니다. URL-encoded form data + URLSession dataTask + DispatchQueue.main.async UI 업데이트.

```swift
// 공통 패턴 — PHP 엔드포인트 POST 요청
func fetchData<T: Decodable>(_ endpoint: String,
                              body: String,
                              type: T.Type,
                              completion: @escaping (T?) -> Void) {
    guard let url = URL(string: "http://your-server/ip1/\(endpoint)") else { return }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = body.data(using: .utf8)

    URLSession.shared.dataTask(with: request) { data, _, error in
        guard let data = data, error == nil else { completion(nil); return }

        let decoder = JSONDecoder()
        let decoded = try? decoder.decode(T.self, from: data)

        DispatchQueue.main.async {
            completion(decoded)
        }
    }.resume()
}

// 사용 예 — 팀 프로젝트 목록 조회
fetchData("getprojects.php",
          body: "teams_id=\(teamsId)",
          type: [ProjectData].self) { projects in
    self.projectList = projects ?? []
}
```

**세션 유지 — UserDefaults:**

```swift
// 로그인 시 저장
UserDefaults.standard.set(userId,  forKey: "LoggedInUser")
UserDefaults.standard.set(teamId,  forKey: "SelectedTeam")

// 전역 접근
let myUserId = UserDefaults.standard.integer(forKey: "LoggedInUser")
let myTeamId = UserDefaults.standard.integer(forKey: "SelectedTeam")

// 로그아웃 시 초기화
UserDefaults.standard.removeObject(forKey: "LoggedInUser")
UserDefaults.standard.removeObject(forKey: "SelectedTeam")
```

---

## 🌐 API 엔드포인트 44개

<details>
<summary>전체 목록 펼쳐보기</summary>

| 카테고리 | 엔드포인트 | 메서드 | 반환값 |
|---|---|---|---|
| **인증** | `login.php` | POST | userId (정수) |
| | `signup.php` | POST | 1=성공, -1=이메일 중복 |
| | `accountexist.php` | POST | 계정 존재 여부 |
| **팀** | `createteam.php` | POST | 생성된 teamId |
| | `getteams.php` | POST | 전체 팀 목록 JSON |
| | `getmyteams.php` | POST | 내 팀 목록 JSON |
| | `getlatestteam.php` | POST | 최근 팀 JSON |
| | `getfavoriteteam.php` | POST | 즐겨찾기 teamId |
| | `setfavoriteteam.php` | POST | 성공 여부 |
| | `switchteam.php` | POST | 전환된 팀 JSON |
| | `applyTeam.php` | POST | 신청 결과 |
| | `alreadyapplied.php` | POST | 0=미신청, 1=신청중, 3=가입 |
| **프로젝트** | `createproject.php` | POST | 생성 결과 |
| | `getprojects.php` | POST | 프로젝트 목록 JSON |
| | `getlatestproject.php` | POST | 최신 프로젝트 JSON |
| | `projectcomplete.php` | POST | 완료 처리 결과 |
| | `ifprojectcomplete.php` | POST | 0=진행, 1=완료, 2=만료 |
| | `modifyproject.php` | POST | 수정 결과 |
| **태스크** | `create_task.php` | POST | 생성 결과 |
| | `gettasks.php` | POST | 태스크 목록 JSON |
| | `update_task_status.php` | POST | 상태 업데이트 결과 |
| | `delete_task.php` | POST | 삭제 결과 |
| **미팅** | `createmeeting.php` | POST | 생성 결과 |
| | `getmeetings.php` | POST | 미팅 목록 JSON |
| | `getlatestmeeting.php` | POST | 최신 미팅 JSON |
| | `meetinginfo.php` | POST | 미팅 상세 JSON |
| | `modifymeeting.php` | POST | 수정 결과 |
| **공지** | `createNotice.php` | POST | 생성 결과 |
| | `getNotices.php` | POST | 공지 목록 JSON |
| | `updateNotice.php` | POST | 수정 결과 |
| | `deleteNotice.php` | POST | 삭제 결과 |
| **댓글** | `createComment.php` | POST | 생성 결과 |
| | `getComments.php` | POST | 댓글 목록 JSON |
| | `updateComment.php` | POST | 수정 결과 |
| | `deleteComment.php` | POST | 삭제 결과 |
| **프로필** | `profile.php` | POST | 프로필 JSON |
| | `modifyprofile.php` | POST | 수정 결과 |
| | `uploadimage.php` | POST | 이미지 업로드 결과 |
| | `personalprofile.php` | POST | 개인 프로필 JSON |
| **멤버 관리** | `getteammembers.php` | POST | 멤버 목록 JSON (팀장용) |
| | `getteammembers_viceleader.php` | POST | 멤버 목록 (부팀장용) |
| | `processapplication.php` | POST | 승인/거절 결과 |
| | `removemember.php` | POST | 추방 결과 |
| | `ifleader.php` | POST | 0=팀장, 1=부팀장, 2=팀원 |
| | `setviceleader.php` | POST | 부팀장 지정 |
| | `unsetviceleader.php` | POST | 부팀장 해제 |
| | `transferleader.php` | POST | 팀장 권한 위임 |

</details>

---

## 🔥 트러블슈팅

### ① 로그인 후 홈 화면 기본 팀 선택 기준 부재

**문제**
사용자가 여러 팀에 동시 소속될 수 있는 구조에서, 로그인 시 어느 팀을 기본으로 표시할지 기준이 없었다. 첫 번째 가입 팀을 고정하면 실제 활동 팀과 무관하고, 매번 직접 선택하면 UX가 저하된다.

**해결**
로그인 성공 직후 `getfavoriteteam.php`로 즐겨찾기 팀을 조회해 **2경로 분기** 처리.

```swift
if let teamId = Int(teamStr), teamId > 0 {
    isTeamHomeActive = true   // 즐겨찾기 팀 있음 → 팀 홈 바로 진입
} else {
    isSucceedLogin = true     // 없음 → 팀 선택 화면
}
```

**결과**
재접속 시 마지막 즐겨찾기 팀으로 즉시 진입. 로그인 → 홈 진입 API 호출 최대 2회로 최소화.

---

### ② `onAppear` 재실행으로 팀 전환 후 이전 팀 데이터 덮어씌우기

**문제**
팀 전환 후 `TeamHomeView`가 다시 `onAppear`를 실행하면서, 전환 전 팀 ID로 다시 데이터를 조회해 방금 전환한 팀 정보가 이전 팀 데이터로 덮어씌워지는 문제.

**해결**
`TeamSwitchActive` 플래그를 도입해 팀 전환 직후에는 `onAppear`의 데이터 재조회를 건너뜀.

```swift
.onAppear {
    // 팀 전환 직후에는 onAppear 재실행으로 인한 데이터 덮어씌우기 방지
    if teamSwitchActive {
        teamSwitchActive = false
        return
    }
    loadTeamHomeData()
}
```

**결과**
팀 전환 후 전환된 팀 데이터가 올바르게 유지됨.

---

### ③ 댓글 · 공지 수정/삭제 권한 — 서버 검증 없이 UI만 제어

**문제**
댓글 수정/삭제 버튼을 작성자 본인에게만 표시했지만, API 요청 자체는 누구나 보낼 수 있어 클라이언트 UI 제어만으로는 권한이 보장되지 않는 구조.

**해결**
PHP 엔드포인트에서 `user_id` 파라미터를 받아 DB에서 작성자 여부를 검증 후 처리. 불일치 시 에러 반환.

```php
// deleteComment.php
$comment = "SELECT user_id FROM comments WHERE id='$comment_id' LIMIT 1";
$result = mysqli_query($conn, $comment);
$row = mysqli_fetch_array($result);

if ($row["user_id"] != $request_user_id) {
    echo "unauthorized";
    exit;
}
// 본인 확인 후 삭제
mysqli_query($conn, "DELETE FROM comments WHERE id='$comment_id'");
```

**결과**
클라이언트 UI 제어 + 서버 측 권한 검증 이중 적용.

---

## 👥 팀 구성 & 역할

| 팀원 | 담당 기능 |
|---|---|
| 👤 **본인** | **팀 생성 · 전환 · 가입 신청 흐름 구현**, 즐겨찾기 기반 로그인 자동 팀 진입 로직, `alreadyapplied.php` 3-state 처리, `TeamSwitchActive` 플래그 설계 |
| 팀원 A | 프로젝트 · 태스크 관리 화면 (ProjectView, TaskView 계열) |
| 팀원 B | 미팅 · 공지사항 · 댓글 기능 (MeetingsView, NoticeView 계열) |
| 팀원 C | PHP 백엔드 API 전체 · MySQL DB 설계 · `ifleader.php` 역할 시스템 |

---

<div align="center">

**iOS 팀 프로젝트 4인 | SwiftUI + PHP REST API 44개 엔드포인트**

Made with 🍎 by Team TeamSync

</div>
