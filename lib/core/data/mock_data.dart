import '../../features/chat/domain/chat_thread.dart';
import '../../features/feed/domain/pet_post.dart';
import '../../features/pets/domain/pet.dart';
import '../../features/walks/domain/walk.dart';

final mockPets = <Pet>[
  const Pet(
    id: 'pet-1',
    ownerId: 'user-1',
    name: 'Бруно',
    animalType: 'Собака',
    breed: 'Корги',
    age: 3,
    description: 'Обожает мячики, людей и короткие пробежки в парке.',
    photoEmoji: '🐶',
    ownerName: 'Аня',
  ),
  const Pet(
    id: 'pet-2',
    ownerId: 'user-2',
    name: 'Мия',
    animalType: 'Кошка',
    breed: 'Мейн-кун',
    age: 2,
    description: 'Спокойная кошка, которая любит наблюдать за птицами.',
    photoEmoji: '🐱',
    ownerName: 'Максим',
  ),
  const Pet(
    id: 'pet-3',
    ownerId: 'user-3',
    name: 'Рокки',
    animalType: 'Собака',
    breed: 'Бигль',
    age: 4,
    description: 'Всегда ищет компанию для активной прогулки.',
    photoEmoji: '🐕',
    ownerName: 'Лена',
  ),
];

final mockPosts = <PetPost>[
  PetPost(
    id: 'post-1',
    petId: 'pet-1',
    petName: 'Бруно',
    authorName: 'Аня',
    petEmoji: '🐶',
    imageEmoji: '🌳',
    text:
        'Сегодня Бруно впервые спокойно прошел мимо самоката. Маленькая победа!',
    createdAt: DateTime.now().subtract(const Duration(minutes: 24)),
    likesCount: 18,
    commentsCount: 4,
    isLiked: false,
  ),
  PetPost(
    id: 'post-2',
    petId: 'pet-2',
    petName: 'Мия',
    authorName: 'Максим',
    petEmoji: '🐱',
    imageEmoji: '🪟',
    text: 'Мия нашла лучшее место в доме: подоконник с видом на двор.',
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    likesCount: 31,
    commentsCount: 7,
    isLiked: true,
  ),
  PetPost(
    id: 'post-3',
    petId: 'pet-3',
    petName: 'Рокки',
    authorName: 'Лена',
    petEmoji: '🐕',
    imageEmoji: '🥎',
    text: 'Ищем друзей для вечерней прогулки. Рокки очень социальный.',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    likesCount: 12,
    commentsCount: 2,
    isLiked: false,
  ),
];

final mockWalks = <Walk>[
  Walk(
    id: 'walk-1',
    title: 'Корги-встреча в парке',
    place: 'Парк Горького, центральный вход',
    startsAt: DateTime.now().add(const Duration(hours: 5)),
    description: 'Неспешная прогулка, знакомство питомцев и фото на память.',
    organizerName: 'Аня',
    participantCount: 6,
    isJoined: false,
  ),
  Walk(
    id: 'walk-2',
    title: 'Утренняя прогулка с биглями',
    place: 'Сквер у набережной',
    startsAt: DateTime.now().add(const Duration(days: 1, hours: 2)),
    description: 'Маршрут на 40 минут, подойдет активным собакам.',
    organizerName: 'Лена',
    participantCount: 4,
    isJoined: false,
  ),
  Walk(
    id: 'walk-3',
    title: 'Спокойная социализация щенков',
    place: 'Площадка у дома 12',
    startsAt: DateTime.now().add(const Duration(days: 2, hours: 1)),
    description: 'Безопасная встреча для молодых собак и новых владельцев.',
    organizerName: 'Игорь',
    participantCount: 3,
    isJoined: true,
  ),
];

final mockChats = <ChatThread>[
  ChatThread(
    id: 'chat-1',
    companionName: 'Аня',
    petName: 'Бруно',
    lastMessage: 'Пойдем завтра в парк?',
    unreadCount: 2,
    updatedAt: DateTime.now().subtract(const Duration(minutes: 8)),
  ),
  ChatThread(
    id: 'chat-2',
    companionName: 'Лена',
    petName: 'Рокки',
    lastMessage: 'Рокки будет рад новой компании!',
    unreadCount: 0,
    updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
];
