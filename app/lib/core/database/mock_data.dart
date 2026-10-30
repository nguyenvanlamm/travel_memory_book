import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/memory.dart';
import '../../models/photo.dart';
import '../../models/trip.dart';
import '../services/memory_file_store.dart';
import 'memory_store.dart';

/// Run with `--dart-define=MOCK_DATA=true` (see tool/run_mock.sh) to open the
/// app on the demo library from design-demos/spec.md instead of an empty one.
const mockDataEnabled = bool.fromEnvironment('MOCK_DATA');

/// Where the demo photos are read from: a URL path on web (run_mock.sh copies
/// them into web/mock-photos), or a directory such as
/// `--dart-define=MOCK_PHOTOS=$PWD/../design-demos/assets/photos` on desktop.
const _photosBase =
    String.fromEnvironment('MOCK_PHOTOS', defaultValue: 'mock-photos');

class _MockPhoto {
  final int day;
  final int hour;
  final int minute;
  final String file;
  final String place;

  const _MockPhoto(this.day, this.hour, this.minute, this.file, this.place);
}

class _MockMemory {
  /// Null for a memory of the whole trip.
  final int? day;
  final String title;
  final String content;

  const _MockMemory(this.day, this.title, this.content);
}

class _MockTrip {
  final String title;
  final String description;
  final String country;
  final List<String> cities;
  final DateTime start;
  final DateTime end;
  final String cover;
  final List<_MockPhoto> photos;
  final List<_MockMemory> memories;

  const _MockTrip({
    required this.title,
    required this.description,
    required this.country,
    required this.cities,
    required this.start,
    required this.end,
    required this.cover,
    required this.photos,
    required this.memories,
  });
}

/// Fills [MemoryStore] with the six demo books. Photos that cannot be read
/// are skipped so the library still opens.
Future<void> seedMockData() async {
  final store = MemoryStore.instance;
  final bytesByFile = <String, Uint8List?>{};
  Future<Uint8List?> photo(String file) async =>
      bytesByFile[file] ??= await _readPhoto(file);

  for (final m in _trips) {
    final coverBytes = await photo(m.cover);
    final trip = Trip(
      title: m.title,
      description: m.description,
      startDate: m.start,
      endDate: m.end,
      country: m.country,
      cities: m.cities,
      coverPhotoPath: coverBytes == null
          ? null
          : MemoryFileStore.putNamed('mem://covers/${m.cover}', coverBytes),
      createdAt: m.end,
    )..id = store.nextId();
    store.trips.add(trip);

    for (final (i, p) in m.photos.indexed) {
      final bytes = await photo(p.file);
      if (bytes == null) continue;
      final path = MemoryFileStore.putNamed(
          'mem://trips/${trip.id}/photos/${p.file}', bytes);
      store.photos.add(Photo(
        tripId: trip.id,
        filePath: path,
        thumbnailPath: path,
        takenAt: _dayOf(m, p.day).add(Duration(hours: p.hour, minutes: p.minute)),
        locationName: p.place,
        day: p.day,
        sortOrder: i,
      )..id = store.nextId());
    }

    for (final (i, mem) in m.memories.indexed) {
      final date = mem.day == null ? null : _dayOf(m, mem.day!);
      store.memorys.add(Memory(
        tripId: trip.id,
        title: mem.title,
        content: mem.content,
        date: date,
        createdAt: (date ?? m.end).add(Duration(hours: 21, minutes: i)),
      )..id = store.nextId());
    }
  }
}

DateTime _dayOf(_MockTrip trip, int day) =>
    trip.start.add(Duration(days: day - 1));

Future<Uint8List?> _readPhoto(String file) async {
  try {
    final bytes = await XFile('$_photosBase/$file').readAsBytes();
    // On web a missing file comes back as the dev server's 404 page.
    if (bytes.length > 2 && bytes[0] == 0xFF && bytes[1] == 0xD8) return bytes;
  } catch (_) {}
  debugPrint('Mock data: no photo at $_photosBase/$file — start the app with '
      'tool/run_mock.sh, or pass --dart-define=MOCK_PHOTOS=<photos dir>.');
  return null;
}

final _trips = [
  _MockTrip(
    title: 'Hà Giang Loop',
    description: 'Four days on the back of a motorbike around the karst '
        'plateau, from Quản Bạ to Mèo Vạc and back.',
    country: 'Vietnam',
    cities: ['Hà Giang', 'Yên Minh', 'Đồng Văn', 'Mèo Vạc'],
    start: DateTime(2026, 3, 14),
    end: DateTime(2026, 3, 17),
    cover: 'hagiang-cover-tham-ma-pass.jpg',
    photos: const [
      _MockPhoto(1, 15, 40, 'hagiang-d1-yen-minh-terraces.jpg', 'Yên Minh'),
      _MockPhoto(2, 9, 20, 'hagiang-cover-tham-ma-pass.jpg', 'Thẩm Mã Pass'),
      _MockPhoto(2, 14, 5, 'hagiang-d2-lung-cu-flag.jpg', 'Lũng Cú Flag Tower'),
      _MockPhoto(3, 7, 12, 'hagiang-d3-ma-pi-leng-portrait.jpg', 'Mã Pí Lèng Pass'),
      _MockPhoto(3, 8, 30, 'hagiang-d3-ma-pi-leng-road.jpg', 'Mã Pí Lèng Pass'),
      _MockPhoto(3, 10, 15, 'hagiang-d3-nho-que-river.jpg', 'Nho Quế River'),
      _MockPhoto(3, 11, 40, 'hagiang-d3-nho-que-green.jpg', 'Nho Quế River'),
      _MockPhoto(4, 10, 0, 'hagiang-d4-terraced-fields.jpg', 'Du Già'),
    ],
    memories: const [
      _MockMemory(2, 'Thẩm Mã, khúc cua đầu tiên',
          'Con dốc Thẩm Mã dựng đứng hơn mình tưởng. Mấy đứa trẻ ôm giỏ hoa cải '
          'đứng bên đường, mình mua một bó, cắm luôn vào giỏ xe, đến tối vẫn chưa héo.'),
      _MockMemory(2, 'Cột cờ Lũng Cú',
          'Leo hết bậc thang lên đỉnh cột cờ thì thở không ra hơi. Gió trên đó mạnh '
          'đến mức lá cờ kêu phần phật như tiếng sóng. Nhìn xuống là ruộng bậc thang '
          'và mấy mái nhà trình tường nhỏ xíu.'),
      _MockMemory(3, 'Mã Pí Lèng, 7 giờ sáng',
          'Dừng xe ở Mã Pí Lèng lúc sương còn vắt ngang vách núi. Sông Nho Quế bên '
          'dưới xanh như ai đổ mực, nhỏ đến mức tưởng chỉ là một sợi chỉ. Anh Páo — '
          'người chở mình suốt bốn ngày — bảo mùa này nước đẹp nhất. Mình đứng đó gần '
          'nửa tiếng, không chụp thêm tấm nào, chỉ muốn nhớ cảm giác gió lạnh tạt vào mặt.'),
      _MockMemory(3, 'Thuyền trên sông Nho Quế',
          'Buổi trưa xuống bến đi thuyền vào hẻm Tu Sản. Vách đá hai bên cao vút, '
          'nước xanh đến mức nhìn mãi vẫn không tin là thật. Người lái thuyền tắt máy '
          'giữa dòng để cả thuyền ngồi im nghe tiếng nước.'),
      _MockMemory(null, 'Bốn ngày trên cao nguyên đá',
          'Về đến thành phố Hà Giang lúc chiều tối, người ê ẩm mà chưa muốn cất ba lô. '
          'Hơn ba trăm cây số đèo dốc, đổ xăng ở những cây xăng chẳng có biển hiệu. '
          'Lần sau nhất định quay lại vào mùa lúa chín.'),
    ],
  ),
  _MockTrip(
    title: 'Hội An by Lantern Light',
    description: 'Four slow days in the old town: cao lầu for breakfast, a '
        'tailor fitting, and lanterns on the river every night.',
    country: 'Vietnam',
    cities: ['Hội An'],
    start: DateTime(2026, 1, 24),
    end: DateTime(2026, 1, 27),
    cover: 'hoian-cover-lantern-street.jpg',
    photos: const [
      _MockPhoto(1, 16, 30, 'hoian-yellow-houses.jpg', 'Hội An Ancient Town'),
      _MockPhoto(2, 19, 10, 'hoian-cover-lantern-street.jpg', 'Hội An Ancient Town'),
    ],
    memories: const [
      _MockMemory(2, 'Đêm đèn lồng',
          'Phố cổ về đêm sáng toàn đèn lồng. Mình thả một chiếc hoa đăng xuống sông '
          'Hoài, chưa kịp ước gì thì nó đã trôi mất sau mạn thuyền bên cạnh.'),
    ],
  ),
  _MockTrip(
    title: 'Kyoto in Late Autumn',
    description: 'A week of temples and maple leaves, mostly on foot and by '
        'the slow Randen tram.',
    country: 'Japan',
    cities: ['Kyoto', 'Arashiyama'],
    start: DateTime(2025, 11, 18),
    end: DateTime(2025, 11, 24),
    cover: 'kyoto-cover-fushimi-inari.jpg',
    photos: const [
      _MockPhoto(1, 7, 30, 'kyoto-cover-fushimi-inari.jpg', 'Fushimi Inari Taisha'),
      _MockPhoto(3, 8, 5, 'kyoto-arashiyama-bamboo.jpg', 'Arashiyama Bamboo Grove'),
    ],
    memories: const [
      _MockMemory(1, 'Ngàn cổng torii',
          'Đến Fushimi Inari từ sáu rưỡi sáng để tránh đông. Càng lên cao càng vắng, '
          'đến lưng chừng núi thì chỉ còn mình và tiếng quạ. Đếm được hơn trăm cổng '
          'thì bỏ cuộc.'),
      _MockMemory(3, 'Rừng tre buổi sớm',
          'Gió lùa qua rừng tre nghe như mưa. Đứng yên một lúc mới thấy thân tre cọ '
          'vào nhau kêu lộc cộc, như ai đang gõ cửa.'),
    ],
  ),
  _MockTrip(
    title: 'Đà Lạt, Cold Mornings',
    description: 'Sweaters, artichoke tea and fog over the lake — a short '
        'escape before the year ended.',
    country: 'Vietnam',
    cities: ['Đà Lạt'],
    start: DateTime(2024, 12, 20),
    end: DateTime(2024, 12, 23),
    cover: 'dalat-cover-xuan-huong-lake.jpg',
    photos: const [
      _MockPhoto(2, 6, 45, 'dalat-cover-xuan-huong-lake.jpg', 'Xuân Hương Lake'),
    ],
    memories: const [
      _MockMemory(2, 'Sương trên hồ Xuân Hương',
          'Sáu giờ sáng, hồ còn phủ sương. Mình đi bộ một vòng, tay ôm ly sữa đậu '
          'nành nóng mua ở đầu dốc, đến khi sương tan thì ly cũng nguội.'),
    ],
  ),
  _MockTrip(
    title: 'Slow Days in Luang Prabang',
    description: 'Six unhurried days by the Mekong: morning alms, the night '
        'market, and long naps through the afternoon heat.',
    country: 'Laos',
    cities: ['Luang Prabang'],
    start: DateTime(2024, 2, 8),
    end: DateTime(2024, 2, 13),
    cover: 'luangprabang-cover-haw-pha-bang.jpg',
    photos: const [
      _MockPhoto(2, 6, 20, 'luangprabang-cover-haw-pha-bang.jpg', 'Haw Pha Bang'),
    ],
    memories: const [
      _MockMemory(2, 'Khất thực lúc bình minh',
          'Năm giờ rưỡi đã ngồi bên vỉa hè chờ đoàn sư đi khất thực. Không ai nói gì, '
          'chỉ có tiếng chân trần trên đường và mùi xôi nếp bốc lên từ những chiếc giỏ mây.'),
    ],
  ),
  _MockTrip(
    title: 'Côn Đảo, First Swim of Summer',
    description: 'Our first beach trip of the summer: clear water, quiet '
        'roads and a scooter with a broken speedometer.',
    country: 'Vietnam',
    cities: ['Côn Đảo'],
    start: DateTime(2023, 7, 1),
    end: DateTime(2023, 7, 4),
    cover: 'condao-cover-beach.jpg',
    photos: const [
      _MockPhoto(1, 16, 0, 'condao-cover-beach.jpg', 'Côn Sơn Island'),
    ],
    memories: const [
      _MockMemory(1, 'Lần bơi đầu tiên của mùa hè',
          'Vừa nhận phòng là chạy thẳng ra biển. Nước trong đến mức nhìn rõ bóng mình '
          'in dưới cát, lạnh hơn mình nghĩ nhưng không ai chịu lên bờ trước.'),
    ],
  ),
];
