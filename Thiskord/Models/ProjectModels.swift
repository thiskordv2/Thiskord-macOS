import Foundation

struct Project: Decodable, Hashable {
    let id: Int
    let name: String
    let description: String
}

struct Channel: Decodable, Hashable {
    let id: Int?
    let name: String
    let projectId: Int?
    let description: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case projectId = "id_project_channel"
    }

    var displayName: String {
        "# \(name)"
    }
}

struct UserAccount: Decodable, Hashable {
    let userId: Int?
    let userName: String?
    let userMail: String?
    let userPicture: String?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case userName = "user_name"
        case userMail = "user_mail"
        case userPicture = "user_picture"
    }
}

struct Sprint: Decodable, Hashable {
    let sprintId: Int
    let sprintGoal: String
    let sprintBeginDate: String
    let sprintEndDate: String
    let projectId: Int

    enum CodingKeys: String, CodingKey {
        case sprintId = "sprint_id"
        case sprintGoal = "sprint_goal"
        case sprintBeginDate = "sprint_begin_date"
        case sprintEndDate = "sprint_end_date"
        case projectId = "id_project_sprint"
    }
}

struct SprintTask: Decodable, Hashable {
    let taskId: Int
    let taskTitle: String
    let taskDesc: String?
    let isSubtask: Bool?
    let taskStatus: String
    let idCreator: Int?
    let idResp: Int?
    let projectId: Int?
    let parentTaskId: Int?
    let sprintId: Int?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case taskTitle = "task_title"
        case taskDesc = "task_desc"
        case isSubtask = "is_subtask"
        case taskStatus = "task_status"
        case idCreator = "id_creator"
        case idResp = "id_resp"
        case projectId = "id_project_task"
        case parentTaskId = "id_parent_task"
        case sprintId = "id_sprint"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
