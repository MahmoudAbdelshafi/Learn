# Learn

## Run Requirements 
 * IOS16.0
 * XCode Version 14.2

 ## OVERVIEW
- Learn is a simple iOS App built using MVVM Clean Architecture, SwiftUI and UIKit.

  ## High Level Layers
* **Domain Layer** = Entities + Use Cases + Repositories Interfaces.
* **Data Repositories Layer** = Repositories Implementations + API (Network) + Persistence DB.
* **Presentation Layer (MVVM)** = ViewModels + Views.

## Data Flow
* 1. `View(UI)` calls method from `ViewModel`.
* 2. `ViewModel` executes Use Case.
* 3. `Use Case` combines data from User and Repositories.
* 4. Each Repository returns data from a Remote Data `(Network)`
* 5. Information flows back to the `View(UI)` where we display the lessons data.

## Dependency Direction
* `Presentation Layer` `->` `Domain Layer` `<-` `Data Repositories Layer`
* `Presentation Layer (MVVM)` = `ViewModels(Presenters)` + `Views(UI)`
* `Domain Layer` = `Entities` + `Use Cases` + `Repositories Interfaces`
* `Data Repositories Layer` = `Repositories Implementations` + `API(Network)` + `Persistence DB`


##### Domain Layer
* contains Entities, FetchLessonsUseCase which fetches the lessons data.
* contains Data Repositories Interfaces which are needed for Dependency Inversion.


##### Presentation Layer
* Containts the ViewModels with the necessary data and its logic.
* `ViewModels` have all the reactive `combine` properties.
* `Views` build with `SwiftUI` and `UIKit`


**`ViewModel`** Contains the view controller business logic apstracted with INPUT and OUTPUT Protocol.
* `Note` UI cannot have access to business logic or application logic (Business Models and UseCases), only ViewModels can do it. This is the separation of concerns. We cannot pass business models directly to the View (UI). This why we are mapping Business Models into ViewModel inside ViewModel and pass them to the View.

* Containts Flow `Coordinator` for presentation logic.
* `Note` Flow Coordinator for presentation logic, to reduce View Controllers’ size and responsibility.


##### Data Layer
* Contains `Repositories` Implementaion, It conforms to interfaces defined inside Domain Layer.
* `Note`  Data Layer conforms to interfaces defined inside Domain Layer in order to achieve (Dependency Inversion).

* Contains the `DTO` and mapping objects.
* `Note` Data Transfer Objects DTO is used as intermediate object for mapping from JSON response into Domain. Also for mapping data to the persistent storage.

* Contains `NetworkTarget` that holds the apis configurations for each target

##### Infrastructure Layer (Network) (Hover)

* **`Service / Networking`** - contains the base networklayer `Hover`.
* Hover is a networking library build with `combine`.
* For more about Hover please check: (https://github.com/onurhuseyincantay/Hover)
