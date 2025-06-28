# MeloMood
Khushi Patel, Anany Pravin, Yen-Ting Liu

## Project Summary
MeloMood is a website that is going to aid its users to create playlists based on their current mood, supporting their emotional wellness through music. Through various music services and their APIs (e.g. Spotify, Apple Music), MeloMood uses genre tags and crowdsourced mood ratings to generate playlists that reflect the user’s mood. The platform visualizes individual mood trends and creates a feedback loop between music and emotional wellness. This includes a mood history tracker, allowing users to better understand their moods through music.

Beyond that, users can also contribute to a crowdsourced tagging system, adding their own mood labels and descriptions to songs (possibly assigning mood labels to segments of songs as well). A community hub may also be developed, allowing users to share playlists and connect with others. MeloMood delivers a unique personal experience, going beyond just a simple playlist generator.

## Application Description
Many users have access to millions of songs, but lack personalized tools that connect music to emotional wellness.  While there are mood-based playlists on music services (e.g. Spotify), they are often pre-curated and do not connect well to users’ emotional states, often more focused on the consumption of music rather than the emotion in which musical artists aim for in order to connect with their fans. This makes it difficult to find music that truly resonates how they feel in that moment, creating the gap between music and emotional wellness.

MeloMood aims to bridge that gap by offering users a platform where they are able to generate personalized playlists based on their current mood. By integrating with APIs from music services, the website will generate playlists using real-time mood input from the user as well as genre tags and crowdsource emotion tags from the community. Users will enter their mood, and the system will recommend songs that complement their emotional state.
Beyond music, MeloMood visualizes how users' moods change over time through music, offering a mood history dashboard that shows the emotional trends in connection to songs listened to. Users can create their own tags/descriptions to label songs or particular segments of a song. The platform may also include a social aspect where users can share mood-based playlists and connect with others. MeloMood creates a unique space for self-expression,building a music experience that will evolve with the user.

## Features and Rationale
The overarching creative component of MeloMood, when compared to existing music platforms, is its integration of real-time mood-based audio recommendation. Based on our research thus far, this is likely the first product that actively aligns emotion-aware audio with a user's dynamic mood-emotion timeline, rather than relying on passive genre selection or inferred mood clustering from listening habits.

We have identified two major technical challenges that define this creative component:

#### Emotion-Aware Audio Embedding (Smart Transformation)
Drawing on a decade of research in emotion-aware music analysis, we are working with more emotional metadata than typical applications ingest. These collected diverse public datasets must be transformed and organized into a queryable emotional audio embedding space.

To accomplish this, we plan to apply dimensionality reduction techniques (e.g., PCA) and clustering algorithms (e.g., HDBSCAN) on high-dimensional audio feature vectors (e.g., valence, tempo, danceability). The goal is to create emotionally meaningful clusters that support real-time song **retrieval** based on user mood inputs.


#### Interactive mood history dashboard (Visualization)
Given our platform’s emphasis on real-time emotional input, we aim to build an interactive visualization module that enables users to explore their emotional-musical journey over time. Key features include:
Plotting mood inputs alongside listening history.
Animating emotional shifts and supporting filters by time range and mood category.
Displaying songs on a 2D valence–arousal grid, augmented by user mood feedback.
Allowing users to annotate and reflect on specific periods, building a personalized emotional-musical diary.

## Usefulness
MeloMood is useful because it provides a unique tailored experience to discover music and track emotional well-being. For many, users often correlate their music listening experience to their mood, and rarely are these two aspects combined in existing services. While most streaming platforms do offer general mood playlists (e.g. “Happy Hits” or “Homework Vibes”), it may not resonate with the user much especially with their current mood. MeloMood stands out by offering the user to generate emotionally curated playlists based on their input of their current mood.

The functions of the platform include but do not limit to:
- Selecting/entering their current mood.
- Generating said mood’s playlist from various datasets, and through several streaming platforms APIs.
- Tagging songs / portions of songs with emotional labels, pre-curated or custom through a crowdsourced emotion tagging system.
- Reflect on past moods using visual charts.
- Discover community-curated mood playlists that have helped others feel better.

While there are similar applications such as Moodify or Spotify’s mood playlists, these platforms rely on rather basic metadata without considering the user’s input. Current music platforms like Spotify or Apple Music are based mostly on consumption of music. MeloMood differs by actually integrating real-time mood tracking as well as having custom emotional labels, creating a platform that focuses on not only personal growth but also sharing these music experiences with others. It does not simply focus on finding music for the user, but actually helps understand how that music relates to how they feel.

## Realness
We are grounding our work in two complementary and publicly available music datasets:

#### Spotify Tracks Dataset
**What is it?**
A comprehensive CSV dataset sourced from Kaggle (contributed by Maharshi Pandya), containing between 100,000 and 1.2 million Spotify tracks spanning over 125 genres. This dataset supports large-scale modeling for genre classification and emotional valence prediction, which are essential for building features like playlist recommendations.
**Structure**
Approximately 114,000 to 1.2 million rows and ~20 columns, including both numeric (e.g., valence, tempo, loudness) and categorical (e.g., genre, artist) features.

#### DEAM / MediaEval Emotional Analysis Dataset
**What is it?**
A CSV-based Kaggle dataset developed through MediaEval, comprising ~2,058 music clips with detailed annotations of emotional valence and arousal. This dataset provides a medium-scale, validated test set ideal for training and evaluating regression-based emotion models and affective computing applications.
**Structure**
Each music clip (~45 seconds) is annotated across both emotional dimensions (valence and arousal), enabling nuanced modeling beyond basic mood labels.

#### Supplemental
Should the above macro- and micro-level emotion annotations prove insufficient for the project’s goals, we have also identified a curated GitHub repository, “datasets_emotion” by juansgomez87. This collection aggregates diverse research datasets related to music emotion recognition, covering both categorical and dimensional emotion labels. Dataset sizes range from small (~200 audio clips) to medium (e.g., NTWICM) collections. These supplemental sources offer the necessary emotional ground truths for calibrating or validating models trained on large-scale audio descriptors.

## Functionality
As mentioned, MeloMood generates playlists for users based on their current mood. Upon logging in, the user can select a mood from a preset list (such as “anxious”, “excited”, or “relaxed”), or typing in a custom emotion. The system will then use this input along with user preferences in their music taste (e.g. favorite genres, artists) to generate a playlist through a music streaming API like Spotify. Users will be able to listen to this playlist and tag individual songs/segments of a song with specific emotions which helps build a crowdsourced emotion-to-music dataset for better playlist recommendations. They are also able to rate these songs, informing on whether the recommendation was good or not.

Each playlist generated is saved to the user’s profile and stored in a mood history dashboard, which users can later revisit and edit. The dashboard will additionally display a visual chart of their mood patterns over a certain period of time, linked to the playlists generated. This feature encourages more emotional self-reflection. MeloMood offers other various features, such as:

- Search and filter playlists by mood, genre, or popularity
- Sharing playlists with other users and connect with through a community feed
- Update account settings and music preferences at any time to adjust recommendations

These features make MeloMood more than just a simple music generator. It is a tool that allows users to express how they feel and connect through music.

Below is a low-fidelity UI mockup for MeloMood:
[]

The website includes four main pages:
1. Main Page: Users will choose or enter their current mood and generate a playlist based on that
2. Playlist: A mood based playlist generated from mood input, tagging individual songs with emotional labels
3. Community (ComHub): Users can browse and filter playlists shared by others, and interact with them. They can also check through emotion tags.
4. Mood History Dashboard: Timeline chart / Pie Chart that tracks the user’s mood and playlist activity over time, as well as past generated playlists.
The UI should be as user friendly as possible, hence focusing on simplicity with basic functions.
