class LibraryDataService {
  static final List<Map<String, dynamic>> _dummyData = [
    {
      'status': 'published',
      'image': 'assets/images/splash.png',
      'title': 'Caramel Macadamia Latte',
      'description':
          'Try our new Caramel Macadamia Latte! Perfect coffee blend...',
      'tags': ['#AddisAbebaCafe', '#EthiopianCoffee', '+1'],
      'date': '1/15/2024',
      'platform': 'Instagram',
      'type': 'Image',
    },
    {
      'status': 'draft',
      'image': 'assets/images/splash.png',
      'title': 'Behind the Scenes',
      'description': 'Watch how we make our signature latte...',
      'tags': ['#BehindTheScenes', '#CoffeeProcess', '+1'],
      'date': '1/14/2024',
      'platform': 'TikTok',
      'type': 'Video',
    },
    {
      'status': 'scheduled',
      'image': 'assets/images/splash.png',
      'title': 'Weekend Special',
      'description': 'Weekend vibes with our special blend...',
      'tags': ['#WeekendSpecial', '#CoffeeLovers', '+1'],
      'date': '1/13/2024',
      'platform': 'Instagram',
      'type': 'Image',
    },
    {
      'status': 'published',
      'image': 'assets/images/splash.png',
      'title': 'Customer Review',
      'description': 'Amazing feedback from our lovely customers...',
      'tags': ['#CustomerLove', '#Reviews', '+1'],
      'date': '1/12/2024',
      'platform': 'TikTok',
      'type': 'Image',
    },
  ];

  static List<Map<String, dynamic>> getData() {
    return _dummyData;
  }

  static void updateStatus(int index, String status) {
    if (index >= 0 && index < _dummyData.length) {
      _dummyData[index]['status'] = status;
    }
  }

  static void deleteItem(int index) {
    if (index >= 0 && index < _dummyData.length) {
      _dummyData.removeAt(index);
    }
  }
}
