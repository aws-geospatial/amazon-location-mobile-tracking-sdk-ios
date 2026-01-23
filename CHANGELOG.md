# 1.0.2

### ✨ Features and improvements

- Updated `amazon-location-mobile-auth-sdk-ios` dependency to `1.0.1` to get `aws-sdk-swift` dependency upgrade to resolve [security vulnerability](https://github.com/aws-geospatial/amazon-location-mobile-tracking-sdk-ios/security/dependabot/1)

# 1.0.1

### ✨ Features and improvements

- Added more integration and unit tests to improve the code coverage

# 1.0.0

### ⚠️ Breaking changes

- Refactored `LocationTracker` to be constructed with an `identityPoolId`
- Removed custom wrapped types of `LocationClient` requests/responses

### ✨ Features and improvements

- `LocationTracker` now uses the updated `AuthHelper` internally instead of requiring the user to create one explicitly
- Updated README with new usage examples

# 0.3.0

### ✨ Features and improvements

- Bumped dependencies to the latest versions

# 0.2.1

### ✨ Features and improvements

- Created Objective-C bridge

# 0.2.0

### ✨ Features and improvements

- Replaced `aws-sdk-ios` with `aws-sdk-swift`

# 0.0.1

### ✨ Features and improvements

- Created utilities to track a device's positions and send the positions to Amazon Location Service
