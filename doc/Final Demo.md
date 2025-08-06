# Final Demo

## Changes in the directions of our project
Over the course of the project, we made several adjustments to our plan, such as modifying the feature set and altering the development timeline, based on technical feasibility.
Our original goal was to create a music-mood logging and dynamic playlist recommendation web application that continuously updates based on user interactions.
However, as we iterated on feature scope and schema design, we shifted our emphasis to focus more on mood-centric song recommendations and implemented brief performance optimizations to better meet course requirements and our achievable workload.

## Usefulness

### Achieved
- **Core Functionality:** Successfully implemented mood logging, playlist mapping, and song search features.
- **Data Analysis:** Added features for top song recommendations based on target moods.
- **User Experience:** Provided responsive web UI and quick operations to implemented features.

### Failed
- **Recommendation Engine:** Did not introduce a more sophisticated learning-based collaborative filtering system for song suggestions.
- **Advanced Play History:** Analysis of user listening patterns was not implemented.
- **Community:** We did not implement community sharing feature, as this requires a functional user authentication support.

## Schema changes

## Table implementations change

### Differences and rationale


## Functionalities changes
### Added
- Data analytics endpoints (e.g., top happy tracks, most active users).
- Perpetual playlist updates upon new mood insertion.
### Removed
- Social playlist sharing (de-scoped due to authentication complexity).
- Song metadata editing by users (reserved for backend operations-only, out of scope).

## How database complement the application?
The database design gives fast retrieval of user, song, and playlist data. This is especially true considering the large scale (over 100k) of our song inventory and user base, which requires efficient cross-referencing.
Benchmarked query relations and indexes allow for slightly more efficient queries that power analytics features, which reflects on making the web app responsive, consider that we did not cache the database connection in user sessions and requiring a new connection on every operation.

## Technical challenges

### Kushi

### Anay

### Yen-Ting (Andy)

## Future work
- Utilize and connect existing services, e.g. using Apple Health to provide mood record, and Spotify to support song search and playlist storage.

## Final division of labor

## Corrections for early stages

### Stage 2

#### Before

#### After

### Stage 3

#### Before

#### After
