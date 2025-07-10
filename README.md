# GitHub Users App

A modern iOS application built with SwiftUI that provides an intuitive interface for browsing GitHub users and exploring their repositories. The app leverages GitHub's REST API v3 to deliver a seamless user experience with advanced features like favorites, search, and API key configuration.

## 📱 Features

### ✅ **Core Features (Requirements)**

#### 🧾 **User List Screen**

- **GitHub User Discovery**: Browse and search through GitHub users
- **Profile Display**: Each user row shows profile avatar and username
- **Seamless Navigation**: Tap any user to view their detailed profile and repositories
- **Real-time Search**: Search functionality with live API integration
- **Infinite Scrolling**: Pagination support for browsing large user lists

#### 📦 **User Repository Screen**

- **Comprehensive User Profile**: Displays user avatar, username, full name, followers, and following count
- **Repository Listing**: Shows non-forked repositories with:
  - Repository name
  - Programming language
  - Star count ⭐
  - Description
- **WebView Integration**: Tap any repository to open in embedded web browser
- **Repository Search**: Filter repositories by name, language, or description

### 🚀 **Additional Features (Beyond Requirements)**

#### 🔑 **API Key Configuration System**

- **Easy Setup**: One-tap access to API key configuration via settings icon
- **Rate Limit Enhancement**: Increases API rate limit from 60 to 5,000 requests/hour
- **Visual Status Indicators**: Clear display of current rate limit status
- **Secure Storage**: Local-only storage with UserDefaults encryption
- **User-Friendly Interface**: Step-by-step guidance with clear instructions

#### ⭐ **Favorites/Bookmarks System**

- **User Bookmarking**: Save favorite users with heart icon
- **Dedicated Favorites Screen**: Quick access to bookmarked users
- **Persistent Storage**: Favorites saved locally and persist between app sessions
- **Search Favorites**: Filter bookmarked users with real-time search
- **Batch Operations**: Clear all favorites with confirmation dialog

#### 🔍 **Advanced Search & Filtering**

- **Smart Search**: Intelligent search with API throttling to prevent rate limiting
- **Repository Filtering**: Search within user's repository list
- **Empty State Management**: Elegant handling of no results scenarios
- **Search History**: Maintains search context and state

#### 📄 **Performance Optimizations**

- **Infinite Scrolling**: Smooth pagination for both users and repositories
- **Lazy Loading**: Efficient memory management with `LazyVStack`
- **Image Caching**: Optimized avatar loading with fallback support
- **Task Cancellation**: Proper async task management to prevent memory leaks

#### 🎨 **Modern UI/UX**

- **Custom Design System**: Consistent colors, typography, and spacing
- **Dark/Light Mode**: Full support for iOS appearance preferences
- **Pull-to-Refresh**: Intuitive refresh functionality
- **Loading States**: Comprehensive loading and error state handling
- **Accessibility**: Basic accessibility labels for key interactive elements

#### 🌐 **Enhanced WebView Experience**

- **Embedded Browser**: Built-in WebView with navigation controls
- **External Browser Option**: Quick access to Safari for full browsing
- **Loading Management**: Proper loading states and error handling
- **Navigation Stack**: Seamless back navigation integration

## 🏗️ Architecture

### **Clean Architecture Pattern**

The app follows Clean Architecture principles with clear separation of concerns:

```
├── Core/
│   ├── Models/           # Data models and entities
│   ├── Networking/       # HTTP client and API endpoints
│   ├── Services/         # Business logic and API services
│   ├── Protocols/        # Abstractions and interfaces
│   └── DI/              # Dependency injection container
├── Features/
│   ├── UserList/        # User listing functionality
│   ├── UserRepository/  # Repository browsing functionality
│   └── Favorites/       # Favorites management
├── UI/
│   ├── Components/      # Reusable UI components
│   ├── DesignSystem/    # UI constants and styles
│   └── Modifiers/       # Custom SwiftUI modifiers
```

### **Design Patterns**

#### **MVVM (Model-View-ViewModel)**

- **Separation of Concerns**: Clear separation between UI, business logic, and data
- **Reactive Programming**: Uses Combine for reactive updates
- **Testability**: ViewModels are easily testable with dependency injection

#### **Protocol-Oriented Programming**

- **Abstraction**: Protocols define clear contracts for services
- **Dependency Injection**: Enables easy mocking and testing
- **Flexibility**: Easy to swap implementations

#### **Repository Pattern**

- **Data Layer Abstraction**: Clean separation between data access and business logic
- **Caching Strategy**: Efficient data management with local storage
- **Error Handling**: Centralized error management

### **Key Components**

#### **Networking Layer**

- **HTTPClient**: Generic HTTP client with proper error handling
- **Endpoint Protocol**: Type-safe API endpoint definitions
- **Network Error Handling**: Comprehensive error management with user-friendly messages

#### **Services**

- **GitHubAPIService**: Handles all GitHub API interactions
- **FavoritesService**: Manages user bookmarks with persistence
- **Router**: Centralized navigation management

#### **Dependency Injection**

- **DependencyContainer**: Manages service lifecycles and dependencies
- **Singleton Pattern**: Ensures single instance of core services
- **Environment Objects**: SwiftUI environment integration

## 🧪 Testing

### **Test Coverage**

- **Unit Tests**: Comprehensive testing of ViewModels and Services
- **Integration Tests**: End-to-end user flow testing
- **Mock Objects**: Complete mocking infrastructure for reliable testing
- **API Testing**: Network layer testing with mock responses

### **Test Structure**

```
GitHubUsersAppTests/
├── Models/              # Model validation tests
├── Networking/          # HTTP client tests
├── Services/           # Service logic tests
├── ViewModels/         # ViewModel behavior tests
├── Mocks/              # Mock objects and test helpers
└── IntegrationTests/   # Complete user flow tests
```

### **Testing Strategy**

- **Dependency Injection**: Easy mocking of dependencies
- **Async Testing**: Proper testing of async/await patterns
- **State Management**: Testing of complex state transitions
- **Error Scenarios**: Comprehensive error handling validation

## 🔧 Technical Requirements

### **Development Environment**

- **Xcode**: 15.0 or later
- **iOS**: 16.0 or later
- **Swift**: 5.9 or later
- **SwiftUI**: 4.0 or later

### **Dependencies**

- **No External Libraries**: Built entirely with native iOS frameworks
- **Foundation**: Core functionality and data management
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming and data binding
- **WebKit**: Embedded web browser functionality

### **API Integration**

- **GitHub REST API v3**: Full compliance with GitHub API standards
- **Rate Limiting**: Intelligent handling of API rate limits
- **Authentication**: Optional Personal Access Token support
- **Error Handling**: Comprehensive API error management

## 🚀 Getting Started

### **Installation**

1. Clone the repository
2. Open `GitHubUsersApp.xcodeproj` in Xcode
3. Build and run the project on iOS Simulator or device

### **API Key Setup (Optional)**

1. Create a GitHub Personal Access Token:
   - Go to GitHub Settings → Developer settings → Personal access tokens
   - Generate a new token with `public_repo` scope
2. In the app, tap the gear icon in the navigation bar
3. Enter your API key and save
4. Restart the app to activate the enhanced rate limit

### **Usage**

1. **Browse Users**: Search for GitHub users or browse the default list
2. **View Repositories**: Tap any user to see their repositories
3. **Bookmark Favorites**: Use the heart icon to save users
4. **Access Favorites**: Tap the heart icon in navigation to view bookmarks
5. **Repository Details**: Tap any repository to view in embedded browser

## 📊 Performance Metrics

### **API Efficiency**

- **Rate Limit Management**: 60 requests/hour (unauthenticated) or 5,000 requests/hour (with API key)
- **Request Optimization**: Intelligent caching and throttling
- **Pagination**: Efficient data loading with 20 items per page

### **Memory Management**

- **Lazy Loading**: Efficient list rendering with `LazyVStack`
- **Image Caching**: Optimized avatar loading and caching
- **Task Cancellation**: Proper cleanup of async operations

### **User Experience**

- **Loading States**: Responsive UI with loading indicators
- **Error Recovery**: Automatic retry mechanisms
- **Offline Handling**: Graceful degradation when network is unavailable

## 🛠️ Configuration

### **Build Configurations**

- **Debug**: Development build with extensive logging
- **Release**: Optimized production build

### **Environment Variables**

- `GITHUB_API_KEY`: Optional environment variable for API key
- Development settings available in `DependencyContainer`

## 📝 Code Quality

### **Code Standards**

- **Swift Style Guide**: Follows Apple's Swift coding conventions
- **Documentation**: Comprehensive inline documentation
- **Error Handling**: Proper error propagation and user feedback
- **Memory Safety**: ARC compliance and leak prevention

### **Architecture Benefits**

- **Maintainability**: Clear separation of concerns
- **Testability**: High test coverage with dependency injection
- **Scalability**: Easy to add new features and modify existing ones
- **Reusability**: Modular components for code reuse

## 🎯 Future Enhancements

### **Planned Features**

- **Repository Filtering**: Advanced filtering options
- **User Profiles**: Extended user information display
- **Contribution Graphs**: Visual representation of user activity
- **Export Functionality**: Export favorites and repository lists

### **Technical Improvements**

- **Core Data Integration**: Enhanced local storage capabilities
- **Push Notifications**: Repository activity notifications
- **Widget Support**: iOS widget for favorite users
- **iPad Optimization**: Enhanced iPad user experience

## 📄 License

This project is developed as an assignment and follows standard iOS development practices. The code is structured for educational and demonstration purposes.

## 🤝 Contributing

This project demonstrates modern iOS development practices including:

- Clean Architecture principles
- SwiftUI best practices
- Combine reactive programming
- Comprehensive testing strategies
- Professional code organization

---

**Built with ❤️ using SwiftUI and modern iOS development practices**
