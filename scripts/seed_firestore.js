#!/usr/bin/env node

const path = require("path");

function loadFirebaseAdmin() {
  try {
    return require("firebase-admin");
  } catch (_) {
    return require(path.join(
      __dirname,
      "..",
      "functions",
      "node_modules",
      "firebase-admin"
    ));
  }
}

const admin = loadFirebaseAdmin();

const projectId = process.env.FIREBASE_PROJECT_ID || "petconnect-local";
const emulatorHost = process.env.FIRESTORE_EMULATOR_HOST;

if (!emulatorHost) {
  console.error(
    "FIRESTORE_EMULATOR_HOST is required. Refusing to seed production Firestore."
  );
  console.error("Example: FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npm run seed --prefix functions");
  process.exit(1);
}

if (!admin.apps.length) {
  admin.initializeApp({ projectId });
}

const db = admin.firestore();
const timestamp = admin.firestore.Timestamp;

function ts(value) {
  return timestamp.fromDate(new Date(value));
}

async function setDoc(pathSegments, data) {
  await db.doc(pathSegments.join("/")).set(data);
}

const users = [
  {
    id: "user-anya",
    displayName: "Аня",
    email: "anya@example.com",
    avatarUrl: null,
    bio: "Гуляю с корги и люблю pet-friendly места.",
    city: "Москва",
    createdAt: ts("2026-06-16T09:00:00Z"),
    updatedAt: ts("2026-06-16T09:00:00Z")
  },
  {
    id: "user-maksim",
    displayName: "Максим",
    email: "maksim@example.com",
    avatarUrl: null,
    bio: "Кот Мия руководит домом, я только ассистирую.",
    city: "Москва",
    createdAt: ts("2026-06-16T09:05:00Z"),
    updatedAt: ts("2026-06-16T09:05:00Z")
  }
];

const pets = [
  {
    id: "pet-bruno",
    ownerId: "user-anya",
    ownerName: "Аня",
    name: "Бруно",
    animalType: "dog",
    breed: "Корги",
    age: 3,
    description: "Обожает мячики, людей и короткие пробежки в парке.",
    photoUrl: null,
    photoEmoji: "dog",
    createdAt: ts("2026-06-16T09:10:00Z"),
    updatedAt: ts("2026-06-16T09:10:00Z")
  },
  {
    id: "pet-mia",
    ownerId: "user-maksim",
    ownerName: "Максим",
    name: "Мия",
    animalType: "cat",
    breed: "Мейн-кун",
    age: 2,
    description: "Спокойная кошка, которая любит наблюдать за птицами.",
    photoUrl: null,
    photoEmoji: "cat",
    createdAt: ts("2026-06-16T09:12:00Z"),
    updatedAt: ts("2026-06-16T09:12:00Z")
  },
  {
    id: "pet-rocky",
    ownerId: "user-anya",
    ownerName: "Аня",
    name: "Рокки",
    animalType: "dog",
    breed: "Бигль",
    age: 4,
    description: "Всегда ищет компанию для активной прогулки.",
    photoUrl: null,
    photoEmoji: "dog",
    createdAt: ts("2026-06-16T09:14:00Z"),
    updatedAt: ts("2026-06-16T09:14:00Z")
  }
];

const posts = [
  {
    id: "post-bruno-park",
    authorId: "user-anya",
    authorName: "Аня",
    petId: "pet-bruno",
    petName: "Бруно",
    petPhotoUrl: null,
    petEmoji: "dog",
    text: "Сегодня Бруно впервые спокойно прошел мимо самоката. Маленькая победа!",
    imageUrls: ["https://example.com/seed/bruno-park.jpg"],
    imageEmoji: "park",
    likesCount: 1,
    commentsCount: 2,
    visibility: "public",
    createdAt: ts("2026-06-16T10:00:00Z"),
    updatedAt: ts("2026-06-16T10:00:00Z"),
    deletedAt: null
  },
  {
    id: "post-mia-window",
    authorId: "user-maksim",
    authorName: "Максим",
    petId: "pet-mia",
    petName: "Мия",
    petPhotoUrl: null,
    petEmoji: "cat",
    text: "Мия нашла лучшее место в доме: подоконник с видом на двор.",
    imageUrls: ["https://example.com/seed/mia-window.jpg"],
    imageEmoji: "window",
    likesCount: 1,
    commentsCount: 1,
    visibility: "public",
    createdAt: ts("2026-06-16T10:20:00Z"),
    updatedAt: ts("2026-06-16T10:20:00Z"),
    deletedAt: null
  },
  {
    id: "post-rocky-ball",
    authorId: "user-anya",
    authorName: "Аня",
    petId: "pet-rocky",
    petName: "Рокки",
    petPhotoUrl: null,
    petEmoji: "dog",
    text: "Ищем друзей для вечерней прогулки. Рокки очень социальный.",
    imageUrls: ["https://example.com/seed/rocky-ball.jpg"],
    imageEmoji: "ball",
    likesCount: 0,
    commentsCount: 1,
    visibility: "public",
    createdAt: ts("2026-06-16T10:40:00Z"),
    updatedAt: ts("2026-06-16T10:40:00Z"),
    deletedAt: null
  },
  {
    id: "post-bruno-rest",
    authorId: "user-anya",
    authorName: "Аня",
    petId: "pet-bruno",
    petName: "Бруно",
    petPhotoUrl: null,
    petEmoji: "dog",
    text: "После большой прогулки Бруно выбрал самый мягкий плед.",
    imageUrls: ["https://example.com/seed/bruno-rest.jpg"],
    imageEmoji: "blanket",
    likesCount: 0,
    commentsCount: 0,
    visibility: "public",
    createdAt: ts("2026-06-16T11:00:00Z"),
    updatedAt: ts("2026-06-16T11:00:00Z"),
    deletedAt: null
  }
];

const comments = [
  {
    postId: "post-bruno-park",
    id: "comment-bruno-1",
    authorId: "user-maksim",
    authorName: "Максим",
    authorAvatarUrl: null,
    text: "Какой молодец!",
    createdAt: ts("2026-06-16T10:05:00Z"),
    updatedAt: null,
    deletedAt: null
  },
  {
    postId: "post-bruno-park",
    id: "comment-bruno-2",
    authorId: "user-anya",
    authorName: "Аня",
    authorAvatarUrl: null,
    text: "Спасибо! Маленькими шагами к спокойным прогулкам.",
    createdAt: ts("2026-06-16T10:08:00Z"),
    updatedAt: null,
    deletedAt: null
  },
  {
    postId: "post-mia-window",
    id: "comment-mia-1",
    authorId: "user-anya",
    authorName: "Аня",
    authorAvatarUrl: null,
    text: "Мия знает толк в уюте.",
    createdAt: ts("2026-06-16T10:26:00Z"),
    updatedAt: null,
    deletedAt: null
  },
  {
    postId: "post-rocky-ball",
    id: "comment-rocky-1",
    authorId: "user-maksim",
    authorName: "Максим",
    authorAvatarUrl: null,
    text: "Мы можем присоединиться после 19:00.",
    createdAt: ts("2026-06-16T10:45:00Z"),
    updatedAt: null,
    deletedAt: null
  }
];

const likes = [
  {
    postId: "post-bruno-park",
    userId: "user-maksim",
    createdAt: ts("2026-06-16T10:03:00Z")
  },
  {
    postId: "post-mia-window",
    userId: "user-anya",
    createdAt: ts("2026-06-16T10:24:00Z")
  }
];

const walks = [
  {
    id: "walk-corgi-park",
    creatorId: "user-anya",
    organizerName: "Аня",
    title: "Корги-встреча в парке",
    place: "Парк Горького, центральный вход",
    geo: new admin.firestore.GeoPoint(55.7298, 37.6011),
    startsAt: ts("2026-06-16T17:00:00Z"),
    description: "Неспешная прогулка, знакомство питомцев и фото на память.",
    participantIds: ["user-anya", "user-maksim"],
    participantsCount: 2,
    status: "active",
    createdAt: ts("2026-06-16T11:10:00Z"),
    updatedAt: ts("2026-06-16T11:10:00Z")
  },
  {
    id: "walk-morning",
    creatorId: "user-maksim",
    organizerName: "Максим",
    title: "Утренняя прогулка с биглями",
    place: "Сквер у набережной",
    geo: new admin.firestore.GeoPoint(55.7512, 37.6184),
    startsAt: ts("2026-06-17T07:30:00Z"),
    description: "Маршрут на 40 минут, подойдет активным собакам.",
    participantIds: ["user-maksim"],
    participantsCount: 1,
    status: "active",
    createdAt: ts("2026-06-16T11:20:00Z"),
    updatedAt: ts("2026-06-16T11:20:00Z")
  },
  {
    id: "walk-puppy-social",
    creatorId: "user-anya",
    organizerName: "Аня",
    title: "Спокойная социализация щенков",
    place: "Площадка у дома 12",
    geo: null,
    startsAt: ts("2026-06-18T15:00:00Z"),
    description: "Безопасная встреча для молодых собак и новых владельцев.",
    participantIds: ["user-anya"],
    participantsCount: 1,
    status: "active",
    createdAt: ts("2026-06-16T11:30:00Z"),
    updatedAt: ts("2026-06-16T11:30:00Z")
  }
];

const chat = {
  id: "chat-anya-maksim",
  participantIds: ["user-anya", "user-maksim"],
  participantNames: {
    "user-anya": "Аня",
    "user-maksim": "Максим"
  },
  petNames: {
    "user-anya": "Бруно",
    "user-maksim": "Мия"
  },
  lastMessageText: "Да, Бруно будет рад компании.",
  lastMessageSenderId: "user-anya",
  lastMessageAt: ts("2026-06-16T12:06:00Z"),
  unreadCounts: {
    "user-anya": 0,
    "user-maksim": 1
  },
  createdAt: ts("2026-06-16T12:00:00Z"),
  updatedAt: ts("2026-06-16T12:06:00Z")
};

const messages = [
  {
    id: "message-1",
    chatId: "chat-anya-maksim",
    senderId: "user-maksim",
    senderName: "Максим",
    text: "Пойдем завтра в парк?",
    status: "sent",
    createdAt: ts("2026-06-16T12:01:00Z"),
    updatedAt: null
  },
  {
    id: "message-2",
    chatId: "chat-anya-maksim",
    senderId: "user-anya",
    senderName: "Аня",
    text: "Да, Бруно будет рад компании.",
    status: "sent",
    createdAt: ts("2026-06-16T12:06:00Z"),
    updatedAt: null
  }
];

async function seed() {
  console.log(`Seeding Firestore emulator at ${emulatorHost}`);
  console.log(`Project: ${projectId}`);

  for (const user of users) {
    await setDoc(["users", user.id], user);
  }

  for (const pet of pets) {
    await setDoc(["pets", pet.id], pet);
  }

  for (const post of posts) {
    await setDoc(["posts", post.id], post);
  }

  for (const comment of comments) {
    await setDoc(["posts", comment.postId, "comments", comment.id], comment);
  }

  for (const like of likes) {
    await setDoc(["posts", like.postId, "likes", like.userId], like);
  }

  for (const walk of walks) {
    await setDoc(["walks", walk.id], walk);
  }

  await setDoc(["chats", chat.id], chat);

  for (const message of messages) {
    await setDoc(["chats", chat.id, "messages", message.id], message);
  }

  console.log("Seed completed:");
  console.log(`- ${users.length} users`);
  console.log(`- ${pets.length} pets`);
  console.log(`- ${posts.length} posts`);
  console.log(`- ${comments.length} comments`);
  console.log(`- ${walks.length} walks`);
  console.log("- 1 chat");
  console.log(`- ${messages.length} messages`);
}

seed()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Seed failed:", error);
    process.exit(1);
  });
