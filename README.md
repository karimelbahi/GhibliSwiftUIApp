# Building a SwiftUI with Ghibli API

tech stack
- iOS 26+
- SwiftUI with Observation feature for better performance
- URLSession with async/await
- MVVM with service layer
- testing with Swift Testing 

API [documentation](https://ghibliapi.vercel.app/) for Studio Ghibli:
- base URL: https://ghibliapi.vercel.app/
- endpoints used: /films /people
- no authentication required

## Features of the Reference Project

- TabView with Navigation Stacks
- List Screen (fetch from API, show list of items).
![](/images/ghibli_movie_list.jpeg)

- Detail Screen (display more info, async image loading).
![](/images/ghibli_movie_detail.jpeg)

- Favorites (local persistence).
![](/images/ghibli_favorites.jpeg)

- Search (filter + async debounce).
![](/images/ghibli_search.jpeg)

- Settings (theme, stored in UserDefaults).
![](/images/ghibli_settings.jpeg)

- testing, mocks, & dependency injection






