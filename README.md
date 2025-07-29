# Challengely App - Take Home Challenge

## Table of Contents
- [Setup Instructions](#setup-instructions)
- [Test Instructions](#test-instructions)
- [Architecture Overview](#architecture-overview)
- [State Management](#state-management)
- [Performance Optimizations](#performance-optimizations)
- [Chat Implementation Details](#chat-implementation-details)

## Setup Instructions
To set up and run this project, follow these steps:

1.  **Install Xcode**: Ensure you have Xcode installed on your macOS system. You can download it from the Mac App Store.
2.  **Clone the Repository**:
    ```bash
    git clone https://github.com/Spramani/Challengely
    cd Challengely
    ```
3.  **Open in Xcode**:
    Open the `testTodo.xcodeproj` file located in the root of the cloned repository.
    ```bash
    open testTodo.xcodeproj
    ```
4.  **Select a Simulator or Device**: In Xcode, select your desired iOS simulator or a connected physical device as the run target.
5.  **Run the Application**: Click the "Run" button (looks like a play icon) in the top-left corner of Xcode, or press `Cmd + R`.

The app should now build and launch on your selected simulator or device.

## Test Instructions
This project includes unit tests and UI tests. To run them, follow these steps:

1.  **Open in Xcode**: If not already open, open the `testTodo.xcodeproj` file in Xcode.
2.  **Access Test Navigator**: In Xcode, navigate to the Test Navigator. You can do this by clicking the diamond-shaped icon in the left-hand panel (or by pressing `Cmd + 6`).
3.  **Run All Tests**: Click the "Play" button next to the target (e.g., `testTodoTests` or `testTodoUITests`) or the entire project to run all tests.
4.  **Run Specific Tests**: To run individual test classes or methods, hover over them in the Test Navigator and click the "Play" button that appears next to them.

Test results will be displayed directly within Xcode, indicating success or failure.

## Architecture Overview
The Challengely app follows a clear, modular architecture, primarily built using SwiftUI and the MVVM (Model-View-ViewModel) pattern where appropriate. The core components are structured as follows:

*   **`testTodoApp`**: The entry point of the application, responsible for setting up the initial view hierarchy, which is `ContentView`.

*   **`ContentView`**: Manages the initial user onboarding experience. This includes a welcome screen, interest selection, and difficulty setting. Upon completion of this flow, the user is directed to the `ChallengeView`.

*   **`ChallengeView`**: This is the central hub of the application after onboarding. It utilizes a `TabView` to organize three main sections:
    *   **Challenge Tab**: Displays the daily challenge, its current state (locked, revealed, in progress, completed), and provides interactive elements for users to accept and complete challenges. It is powered by `ChallengeViewModel`.
    *   **Chat Tab (`ChallengeChatView`)**: Integrates an AI-powered chat interface, allowing users to interact with a virtual assistant, likely for challenge-related queries or support.
    *   **Profile Tab (`ProfileView`)**: A dedicated section for displaying user profile information.

*   **`ChallengeViewModel`**: Implements the ViewModel for the `ChallengeView`, managing and providing challenge-specific data such as title, description, estimated time, and difficulty. It is an `ObservableObject` to enable reactive updates to the UI.

*   **`ChatViewController`**: This file contains the `ChallengeChatView` SwiftUI view, which is responsible for the chat interface. It handles message display, user input, character limits, and simulated AI responses, including a typing indicator and quick reply suggestions.

*   **`ProfileView`**: A SwiftUI view dedicated to presenting the user's profile details.

### Diagram
```mermaid
graph TD;
    App[testTodoApp] --> ContentView;
    ContentView -- Onboarding Complete --> ChallengeView;
    ChallengeView --> TabView;
    TabView --> ChallengeTab[Challenge View (mainChallengeTab)];
    TabView --> ChatTab[Chat View (ChallengeChatView)];
    TabView --> ProfileTab[Profile View (ProfileView)];
    ChallengeTab --> ChallengeViewModel;
    ChatTab --> ChatMessage;
    ChatTab --> TypingIndicatorView;
```

## State Management

This application leverages SwiftUI's built-in state management solutions, which are designed to be declarative and reactive. The primary mechanisms used are:

*   **`@State`**: Used for managing local view-specific state. For example, `ContentView` uses `@State` to track the current `OnboardingStep` and user selections for interests and difficulty. This property wrapper causes the view to re-render whenever the wrapped value changes, ensuring the UI always reflects the latest state.

*   **`@Binding`**: Provides a way to create a two-way connection between a view and a source of truth defined elsewhere. In `ChallengeChatView`, `@Binding var selectedTab: Int` allows the chat view to read and modify the `selectedTab` property of its parent `ChallengeView`, enabling tab navigation.

*   **`@StateObject`**: Utilized for managing reference type objects (like classes) that conform to `ObservableObject`. `ChallengeView` uses `@StateObject private var viewModel = ChallengeViewModel()` to create and own an instance of `ChallengeViewModel`. This ensures the ViewModel persists across view updates and that any changes to its `@Published` properties automatically trigger UI updates in `ChallengeView`.

*   **`@Published`**: A property wrapper within `ObservableObject` classes (like `ChallengeViewModel`) that automatically announces changes to any of its subscribers. When a `@Published` property changes, any views observing the `ObservableObject` are invalidated and re-rendered, ensuring data consistency across the application.

This approach provides a clear and efficient way to manage data flow and UI updates in a reactive manner, aligning with SwiftUI's paradigm. For more complex global states, a pattern like Environment Objects or a dedicated data store could be introduced, but for the current scope, these SwiftUI-native solutions are sufficient and promote code readability and maintainability.

## Performance Optimizations

Given the scope of this project, extensive low-level performance optimizations were not a primary focus. However, the application inherently benefits from SwiftUI's performance characteristics and includes several practices that contribute to a smooth user experience:

*   **SwiftUI's Optimized Rendering**: SwiftUI is designed for efficient UI rendering. It automatically re-renders only the parts of the view hierarchy that have changed, minimizing unnecessary computations and drawing operations.

*   **`LazyVGrid` for Efficient Layout**: In `ContentView`, `LazyVGrid` is used for displaying interests. This component is optimized to only render items when they are about to become visible on screen, which is crucial for performance when dealing with potentially large lists of items. This avoids rendering off-screen elements, saving memory and processing power.

*   **Explicit Animations with `withAnimation`**: Animations are carefully managed using `withAnimation` blocks. This ensures that UI transitions are smooth and performant by allowing SwiftUI to optimize the animation process. The use of `.easeInOut` and `.linear` animations with specified durations provides controlled and visually appealing transitions without over-stressing the rendering engine.

*   **Minimalistic View Hierarchy**: Views are composed with a focus on simplicity and reusability. Avoiding deeply nested or overly complex view hierarchies helps SwiftUI's rendering engine to perform more efficiently.

*   **State Management for Targeted Updates**: As detailed in the [State Management](#state-management) section, the use of `@State`, `@Binding`, and `@StateObject` ensures that only relevant views are invalidated and re-rendered when their underlying data changes. This prevents unnecessary UI updates across the entire application.

For future enhancements, potential performance optimizations could include:

*   **Image Optimization**: If the app were to include high-resolution images, techniques like image resizing, caching, and on-demand loading would be implemented.
*   **Data Fetching Optimization**: For networked applications, strategies like pagination, debouncing, and caching network requests would be considered to improve responsiveness and reduce data usage.
*   **Profiling with Instruments**: For more complex performance issues, Xcode's Instruments tool would be used to identify bottlenecks in CPU usage, memory consumption, and rendering performance.

## Chat Implementation Details
<!-- Detailed explanation of the chat interface implementation and design decisions -->




https://github.com/user-attachments/assets/6391b29e-4f63-45cf-aa7e-c47aad48e229


