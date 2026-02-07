CREATE TABLE meeting_attendees (id int(4) NOT NULL AUTO_INCREMENT, meeting_id int(4) NOT NULL, user_id int(4) NOT NULL, created_at datetime DEFAULT now() NOT NULL comment '참여시 시 ', PRIMARY KEY (id), UNIQUE INDEX (id));
CREATE TABLE meetings (id int(4) NOT NULL AUTO_INCREMENT, team_id int(4) NOT NULL, author_id int(4) NOT NULL, title varchar(100), notes text NOT NULL, held_at datetime NULL, created_at datetime DEFAULT now() NOT NULL, updated_at datetime NULL, status int(1) DEFAULT 1 NOT NULL comment '0 작성완료
1 공개
2 삭제 ...  ', PRIMARY KEY (id), UNIQUE INDEX (id));
CREATE TABLE notice_comments (id int(4) NOT NULL AUTO_INCREMENT, notice_id int(4) NOT NULL, author_id int(4) NOT NULL, body text, created_at datetime DEFAULT now() NOT NULL, status int(1) DEFAULT 0 NOT NULL comment '0 공개
1 비공개 ...  ', PRIMARY KEY (id), UNIQUE INDEX (id));
CREATE TABLE notices (id int(4) NOT NULL AUTO_INCREMENT, team_id int(4) NOT NULL, author_id int(4) NOT NULL, is_pinned tinyint(1) DEFAULT 0, title varchar(180), body text, created_at datetime DEFAULT now() NOT NULL, updated_at datetime NULL, status int(1) DEFAULT 1 NOT NULL comment '0 작성완료
1 공개
2 삭제 ...  등', PRIMARY KEY (id), UNIQUE INDEX (id));
CREATE TABLE projects (id int(4) NOT NULL AUTO_INCREMENT, team_id int(4) NOT NULL, name varchar(150), description text NOT NULL, due_at datetime NOT NULL comment '완료시 ', achieved tinyint(1) DEFAULT 0, created_at datetime DEFAULT now() NOT NULL, status int(1) DEFAULT 0 comment '프로젝트 상태 변경

0 진행중
1 완료
2 보류
3 취소
4 삭 ', updated_at int(11), PRIMARY KEY (id), UNIQUE INDEX (id));
CREATE TABLE tags (id int(4) NOT NULL AUTO_INCREMENT, name varchar(40), PRIMARY KEY (id), UNIQUE INDEX (id));
CREATE TABLE task_assignees (id int(4) NOT NULL AUTO_INCREMENT, task_id int(4) NOT NULL, user_id int(4) NOT NULL, created_at datetime DEFAULT now() NOT NULL, PRIMARY KEY (id), UNIQUE INDEX (id));
CREATE TABLE task_tags (id int(4) NOT NULL AUTO_INCREMENT, task_id int(4) NOT NULL, tag_id int(4) NOT NULL, created_at datetime DEFAULT now() NOT NULL, PRIMARY KEY (id), UNIQUE INDEX (id));
CREATE TABLE tasks (id int(4) NOT NULL AUTO_INCREMENT, project_id int(4) NOT NULL, title varchar(180), description text NOT NULL, status int(1) DEFAULT 0 comment '투두 진행 상태

0 진행중
1 완료
2 보류
3 취소
4 삭제', start_on datetime NOT NULL, due_on datetime NOT NULL, achieved tinyint(1) DEFAULT 0, created_at datetime DEFAULT now() NOT NULL, updated_at datetime NULL, PRIMARY KEY (id), UNIQUE INDEX (id));
CREATE TABLE team_memberships (id int(4) NOT NULL AUTO_INCREMENT, user_id int(4) NOT NULL, role int(1) comment '역할리스트

0 팀장
1 부팀장
2 팀원 ... 등', status int(1) comment '승인, 승인대기중, 거절, 탈퇴, 차단 등의 상태', favorite tinyint(1) DEFAULT 0, created_at datetime DEFAULT now() NOT NULL, teams_id int(4) NOT NULL, updated_at datetime NULL, PRIMARY KEY (id), UNIQUE INDEX (id));
CREATE TABLE teams (id int(4) NOT NULL AUTO_INCREMENT, name varchar(120) NOT NULL, description text, owner_id int(4) NOT NULL, created_at datetime DEFAULT now() NOT NULL, updated_at datetime NULL, status int(1) DEFAULT 0 NOT NULL comment '0 시작전(생성완료)
1 시작
2 잠시 중단 ...  ', PRIMARY KEY (id), UNIQUE INDEX (id));
CREATE TABLE users (id int(4) NOT NULL AUTO_INCREMENT, email varchar(190) NOT NULL, password varchar(255) NOT NULL, name varchar(100) NOT NULL, profile_img varchar(255), created_at datetime DEFAULT now() NOT NULL, status int(1) comment '0 가입중
1 가입완료
2 탈퇴 ...  ', updated_at datetime NULL, recent_login datetime NULL, PRIMARY KEY (id), UNIQUE INDEX (id));
ALTER TABLE team_memberships ADD INDEX FKteam_membe670474 (user_id), ADD CONSTRAINT FKteam_membe670474 FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE teams ADD INDEX FKteams965468 (owner_id), ADD CONSTRAINT FKteams965468 FOREIGN KEY (owner_id) REFERENCES users (id);
ALTER TABLE projects ADD INDEX FKprojects222071 (team_id), ADD CONSTRAINT FKprojects222071 FOREIGN KEY (team_id) REFERENCES teams (id);
ALTER TABLE tasks ADD INDEX FKtasks437184 (project_id), ADD CONSTRAINT FKtasks437184 FOREIGN KEY (project_id) REFERENCES projects (id);
ALTER TABLE task_assignees ADD INDEX FKtask_assig349704 (task_id), ADD CONSTRAINT FKtask_assig349704 FOREIGN KEY (task_id) REFERENCES tasks (id);
ALTER TABLE task_assignees ADD INDEX FKtask_assig905259 (user_id), ADD CONSTRAINT FKtask_assig905259 FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE task_tags ADD INDEX FKtask_tags201741 (task_id), ADD CONSTRAINT FKtask_tags201741 FOREIGN KEY (task_id) REFERENCES tasks (id);
ALTER TABLE task_tags ADD INDEX FKtask_tags781585 (tag_id), ADD CONSTRAINT FKtask_tags781585 FOREIGN KEY (tag_id) REFERENCES tags (id);
ALTER TABLE meetings ADD INDEX FKmeetings185566 (team_id), ADD CONSTRAINT FKmeetings185566 FOREIGN KEY (team_id) REFERENCES teams (id);
ALTER TABLE meetings ADD INDEX FKmeetings449695 (author_id), ADD CONSTRAINT FKmeetings449695 FOREIGN KEY (author_id) REFERENCES users (id);
ALTER TABLE meeting_attendees ADD INDEX FKmeeting_at846771 (meeting_id), ADD CONSTRAINT FKmeeting_at846771 FOREIGN KEY (meeting_id) REFERENCES meetings (id);
ALTER TABLE meeting_attendees ADD INDEX FKmeeting_at465532 (user_id), ADD CONSTRAINT FKmeeting_at465532 FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE notices ADD INDEX FKnotices298185 (team_id), ADD CONSTRAINT FKnotices298185 FOREIGN KEY (team_id) REFERENCES teams (id);
ALTER TABLE notices ADD INDEX FKnotices437685 (author_id), ADD CONSTRAINT FKnotices437685 FOREIGN KEY (author_id) REFERENCES users (id);
ALTER TABLE notice_comments ADD INDEX FKnotice_com25323 (notice_id), ADD CONSTRAINT FKnotice_com25323 FOREIGN KEY (notice_id) REFERENCES notices (id);
ALTER TABLE notice_comments ADD INDEX FKnotice_com953234 (author_id), ADD CONSTRAINT FKnotice_com953234 FOREIGN KEY (author_id) REFERENCES users (id);
ALTER TABLE team_memberships ADD INDEX FKteam_membe544409 (teams_id), ADD CONSTRAINT FKteam_membe544409 FOREIGN KEY (teams_id) REFERENCES teams (id);
