public enum ReminderSound: Sendable {
    case `default`
    case critical
    case custom(name: String)
}
