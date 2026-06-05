class HomeState {
  final int currentIndex;
  final List<String> stories;
  final List<Map<String, dynamic>> posts;

  const HomeState({
    required this.currentIndex,
    required this.stories,
    required this.posts,
  });

  factory HomeState.initial() {
    return HomeState(
      currentIndex: 0,
      stories: ['Add', 'Jone', 'Smith', 'Kriston', 'Ryan'],
      posts: [
        {
          'name': 'Sandy Watson',
          'time': '08:39 am',
          'text': 'Lorem Ipsum Dolor Sit Amet, Consectetur Adipiscing Elit. Fringilla Natoque Id Aenean.',
          'likes': '1,964',
          'comments': '135',
          'hasImage': true,
        },
        {
          'name': 'Kriston Watson',
          'time': '08:39 am',
          'text': 'Enjoying the new aquarium setup today! Clean water, happy fish.',
          'likes': '892',
          'comments': '67',
          'hasImage': false,
        },
      ],
    );
  }

  HomeState copyWith({
    int? currentIndex,
    List<String>? stories,
    List<Map<String, dynamic>>? posts,
  }) {
    return HomeState(
      currentIndex: currentIndex ?? this.currentIndex,
      stories: stories ?? this.stories,
      posts: posts ?? this.posts,
    );
  }
}
