import Foundation

enum Language: String, CaseIterable {
    case english = "en"
    case polish = "pl"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .polish: return "Polski"
        }
    }
}

struct LocalizedString {
    static func str(_ key: String, language: Language) -> String {
        let strings: [String: [Language: String]] = [
            "Life Planner": [
                .english: "Life Planner",
                .polish: "Life Planner"
            ],
            "Home": [
                .english: "Home",
                .polish: "Strona główna"
            ],
            "Habits": [
                .english: "Habits",
                .polish: "Nawyki"
            ],
            "Groups": [
                .english: "Groups",
                .polish: "Grupy"
            ],
            "Settings": [
                .english: "Settings",
                .polish: "Ustawienia"
            ],
            "Login": [
                .english: "Login",
                .polish: "Logowanie"
            ],
            "Today's Tasks": [
                .english: "Today's Tasks",
                .polish: "Zadania na dziś"
            ],
            "No tasks": [
                .english: "No tasks",
                .polish: "Brak zadań"
            ],
            "Today's Habits": [
                .english: "Today's Habits",
                .polish: "Nawyki na dzisiaj"
            ],
            "No habits today": [
                .english: "No habits today",
                .polish: "Brak nawyków na dziś"
            ],
            "Add Task": [
                .english: "Add Task",
                .polish: "Dodaj zadanie"
            ],
            "Task Title": [
                .english: "Task Title",
                .polish: "Tytuł zadania"
            ],
            "Date": [
                .english: "Date",
                .polish: "Data"
            ],
            "Start Time": [
                .english: "Start Time",
                .polish: "Czas rozpoczęcia"
            ],
            "End Time": [
                .english: "End Time",
                .polish: "Czas zakończenia"
            ],
            "Color": [
                .english: "Color",
                .polish: "Kolor"
            ],
            "Cancel": [
                .english: "Cancel",
                .polish: "Anuluj"
            ],
            "Save": [
                .english: "Save",
                .polish: "Zapisz"
            ],
            "Tasks": [
                .english: "Tasks",
                .polish: "Zadania"
            ],
            "Close": [
                .english: "Close",
                .polish: "Zamknij"
            ],
            "No tasks for this day": [
                .english: "No tasks for this day",
                .polish: "Brak zadań na ten dzień"
            ],
            "Add Habit": [
                .english: "Add Habit",
                .polish: "Dodaj nawyk"
            ],
            "Habit Name": [
                .english: "Habit Name",
                .polish: "Nazwa nawyku"
            ],
            "Goal": [
                .english: "Goal",
                .polish: "Cel"
            ],
            "days": [
                .english: "days",
                .polish: "dni"
            ],
            "New Habit": [
                .english: "New Habit",
                .polish: "Nowy nawyk"
            ],
            "Notifications": [
                .english: "Notifications",
                .polish: "Powiadomienia"
            ],
            "Default duration": [
                .english: "Default duration",
                .polish: "Domyślny czas trwania"
            ],
            "min": [
                .english: "min",
                .polish: "min"
            ],
            "Reset Settings": [
                .english: "Reset Settings",
                .polish: "Zresetuj ustawienia"
            ],
            "Version 1.0.0": [
                .english: "Version 1.0.0",
                .polish: "Wersja 1.0.0"
            ],
            "Language": [
                .english: "Language",
                .polish: "Język"
            ],
            "Appearance": [
                .english: "Appearance",
                .polish: "Wygląd"
            ],
            "Theme": [
                .english: "Theme",
                .polish: "Motyw"
            ],
            "Classic Beige": [
                .english: "Classic Beige",
                .polish: "Klasyczny Beż"
            ],
            "Soft Rose": [
                .english: "Soft Rose",
                .polish: "Delikatna Róża"
            ],
            "Earthy Green": [
                .english: "Earthy Green",
                .polish: "Ziemista Zieleń"
            ],
            "Progress": [
                .english: "Progress",
                .polish: "Postęp"
            ],
            // Dodaj do słownika:
            "Email": [
                .english: "Email",
                .polish: "Email"
            ],
            "Password": [
                .english: "Password",
                .polish: "Hasło"
            ],
            "Create Account": [
                .english: "Create Account",
                .polish: "Utwórz konto"
            ],
            "Confirm Password": [
                .english: "Confirm Password",
                .polish: "Potwierdź hasło"
            ],
            "Nickname": [
                .english: "Nickname",
                .polish: "Pseudonim"
            ],
            "Profile": [
                .english: "Profile",
                .polish: "Profil"
            ],
            "Credentials": [
                .english: "Credentials",
                .polish: "Dane logowania"
            ],
            "Passwords do not match": [
                .english: "Passwords do not match",
                .polish: "Hasła nie są identyczne"
            ],
            "Logout": [
                .english: "Logout",
                .polish: "Wyloguj"
            ],
            "No user data": [
                .english: "No user data",
                .polish: "Brak danych użytkownika"
            ],
            "Email Verification": [
                .english: "Email Verification",
                .polish: "Weryfikacja email"
            ],
            "We've sent a verification email to your address. Please check your inbox and verify your email.": [
                .english: "We've sent a verification email to your address. Please check your inbox and verify your email.",
                .polish: "Wysłaliśmy email weryfikacyjny na Twój adres. Sprawdź skrzynkę i zweryfikuj email."
            ],
            "Resend Verification": [
                .english: "Resend Verification",
                .polish: "Wyślij ponownie"
            ],
            "Email not verified": [
                .english: "Email not verified",
                .polish: "Email niezweryfikowany"
            ],
            "You are not logged in": [
                .english: "You are not logged in",
                .polish: "Nie jesteś zalogowany"
            ],
            "Log in to access all features": [
                .english: "Log in to access all features",
                .polish: "Zaloguj się, aby uzyskać dostęp do wszystkich funkcji"
            ],
            "Welcome back": [
                .english: "Welcome back",
                .polish: "Witaj ponownie"
            ],
            "Or continue with": [
                .english: "Or continue with",
                .polish: "Lub kontynuuj przez"
            ],
            "Don't have an account?": [
                .english: "Don't have an account?",
                .polish: "Nie masz konta?"
            ],
            "Sign Up": [
                .english: "Sign Up",
                .polish: "Zarejestruj się"
            ],
            "Google": [
                .english: "Google",
                .polish: "Google"
            ]
        ]
        
        return strings[key]?[language] ?? key
    }
}
