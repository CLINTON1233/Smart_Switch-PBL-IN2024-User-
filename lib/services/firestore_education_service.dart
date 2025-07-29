// lib/services/firestore_education_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreEducationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method untuk inisialisasi data edukasi (jalankan sekali saja)
  Future<void> initializeEducationData() async {
    try {
      // Cek apakah data sudah ada
      QuerySnapshot existingData =
          await _firestore.collection('education').get();
      if (existingData.docs.isNotEmpty) {
        print('Data edukasi sudah ada di Firebase');
        return;
      }

      // Data edukasi listrik/smart switch
      List<Map<String, dynamic>> educationItems = [
        {
          'id': 'measurement',
          'title': 'Cara Mengukur Daya, Arus, Tegangan dan Hambatan',
          'subtitle': 'Pelajari cara mengukur komponen listrik dengan benar',
          'image': 'assets/multimeter.jpg',
          'difficulty': 'MUDAH',
          'estimatedTime': '10-15 menit',
          'content': '''
Tegangan, arus, dan hambatan adalah elemen utama dalam kelistrikan. Tegangan listrik mendorong pergerakan elektron dalam rangkaian dan diukur dalam Volt (V), sedangkan arus listrik adalah aliran elektron yang diukur dalam Ampere (A). Arus terdiri dari arus searah (DC) dan arus bolak-balik (AC). Hambatan listrik berfungsi membatasi aliran arus untuk mencegah kerusakan perangkat, diukur dalam Ohm (Ω).

**Alat yang Dibutuhkan:**
1. Multimeter digital atau analog
2. Kabel probe
3. Komponen elektronik yang akan diukur

**Langkah Pengukuran:**
1. **Tegangan:**
   - Atur multimeter ke mode pengukuran tegangan (V)
   - Pilih AC atau DC sesuai kebutuhan
   - Hubungkan probe merah ke titik positif, hitam ke negatif
   - Baca nilai yang ditampilkan

2. **Arus:**
   - Atur multimeter ke mode pengukuran arus (A)
   - Putuskan rangkaian dan sambungkan multimeter secara seri
   - Pastikan range pengukuran sesuai
   - Baca nilai yang ditampilkan

3. **Hambatan:**
   - Pastikan komponen tidak terhubung ke sumber daya
   - Atur multimeter ke mode pengukuran hambatan (Ω)
   - Hubungkan probe ke kedua ujung komponen
   - Baca nilai yang ditampilkan

**Keselamatan Kerja:**
- Selalu periksa kondisi multimeter sebelum digunakan
- Gunakan alat pelindung diri seperti sarung tangan isolasi
- Pastikan tangan kering saat bekerja dengan listrik
- Hindari mengukur tegangan tinggi tanpa pelatihan khusus''',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'id': 'circuit_basics',
          'title': 'Pemahaman Dasar Rangkaian Listrik',
          'subtitle': 'Memahami konsep dasar dalam rangkaian elektronik',
          'image': 'assets/electrical.jpg',
          'difficulty': 'SEDANG',
          'estimatedTime': '15-20 menit',
          'content': '''
Rangkaian listrik adalah jalur tertutup di mana elektron dapat mengalir dari sumber daya kembali ke sumber tersebut. Ada beberapa jenis rangkaian dasar:

**1. Rangkaian Seri:**
- Komponen disusun berurutan
- Arus yang mengalir sama di semua titik
- Tegangan terbagi di antara komponen
- Contoh: Lampu hias pohon natal

**2. Rangkaian Paralel:**
- Komponen disusun bercabang
- Tegangan sama di semua cabang
- Arus terbagi di antara cabang
- Contoh: Instalasi listrik rumah

**3. Rangkaian Campuran:**
- Kombinasi seri dan paralel
- Memiliki karakteristik gabungan
- Contoh: Sistem kelistrikan mobil

**Komponen Dasar Rangkaian:**
1. Sumber daya (baterai, adaptor)
2. Konduktor (kabel, PCB)
3. Beban (lampu, motor)
4. Saklar (switch, relay)
5. Pengaman (sekering, MCB)

**Hukum Ohm:**
V = I × R
- V: Tegangan (Volt)
- I: Arus (Ampere)
- R: Hambatan (Ohm)

**Aplikasi Praktis:**
- Menghitung kebutuhan daya perangkat
- Merancang sistem pengkabelan
- Memecahkan masalah rangkaian sederhana
- Memahami spesifikasi komponen elektronik''',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'id': 'safety',
          'title': 'Keselamatan Kerja dengan Listrik',
          'subtitle': 'Tips dan cara kerja aman saat bekerja dengan listrik',
          'image': 'assets/instalasi.jpg',
          'difficulty': 'MUDAH',
          'estimatedTime': '8-12 menit',
          'content': '''
Bekerja dengan listrik memerlukan kewaspadaan tinggi karena risiko sengatan listrik, kebakaran, dan ledakan. Berikut panduan keselamatan dasar:

**1. Persiapan Sebelum Bekerja:**
- Matikan sumber daya dan verifikasi dengan tester
- Gunakan alat yang terisolasi dan dalam kondisi baik
- Kenakan APD (Alat Pelindung Diri) yang sesuai
- Pasang tanda peringatan di area kerja

**2. Alat Keselamatan Dasar:**
- Sarung tangan isolasi
- Sepatu safety anti listrik
- Kacamata pengaman
- Multimeter untuk verifikasi

**3. Praktik Kerja Aman:**
- Kerja dengan satu tangan (jangan biarkan arus mengalir melalui jantung)
- Jangan bekerja dalam kondisi basah atau lembab
- Gunakan tangga non-konduktif untuk pekerjaan tinggi
- Jauhkan bahan mudah terbakar dari area kerja

**4. Pertolongan Pertama Sengatan Listrik:**
- Jangan langsung menyentuh korban
- Matikan sumber listrik jika memungkinkan
- Gunakan benda non-konduktif untuk memindahkan korban
- Hubungi bantuan medis segera
- Lakukan CPR jika korban tidak bernafas

**5. Pemeliharaan Peralatan:**
- Periksa kabel secara berkala untuk kerusakan isolasi
- Ganti komponen yang aus atau rusak
- Pastikan grounding peralatan bekerja dengan baik
- Labeli panel listrik dengan jelas

**Tingkat Tegangan Berbahaya:**
- >30V AC atau >60V DC: Berpotensi fatal
- >50V AC atau >120V DC: Sangat berbahaya
- Selalu anggap semua tegangan sebagai berbahaya''',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      ];

      // Simpan ke Firebase
      WriteBatch batch = _firestore.batch();
      for (var item in educationItems) {
        DocumentReference docRef = _firestore
            .collection('education')
            .doc(item['id']);
        batch.set(docRef, item);
      }
      await batch.commit();

      print('Data edukasi berhasil diinisialisasi');
    } catch (e) {
      throw Exception('Gagal inisialisasi data edukasi: $e');
    }
  }

  // Mengambil semua data edukasi
  Future<List<Map<String, dynamic>>> getEducationData() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('education')
              .orderBy('createdAt', descending: false)
              .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data edukasi: $e');
    }
  }

  // Mengambil data edukasi berdasarkan ID
  Future<Map<String, dynamic>?> getEducationById(String id) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('education').doc(id).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil data edukasi: $e');
    }
  }

  // Search edukasi berdasarkan judul
  Future<List<Map<String, dynamic>>> searchEducation(String query) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('education')
              .where('title', isGreaterThanOrEqualTo: query)
              .where('title', isLessThanOrEqualTo: query + '\uf8ff')
              .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      throw Exception('Gagal search edukasi: $e');
    }
  }
}
