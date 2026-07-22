// ─── Seed Data ────────────────────────────────────────────────────────────────
// Firestore seed verisiyle birebir aynı içerik, yerel SQLite için Dart sabiti.

const List<Map<String, dynamic>> kSeedPersonas = [
  {
    'id': 'persona_public',
    'name': 'Kamu Yayıncısı',
    'description':
        'Dengeli ve gerçeğe dayalı habercilikle kamuyu bilgilendirir.',
    'iconEmoji': '📡',
    'isDefault': 1,
    'sortOrder': 0,
    'bias':
        'Tarafsız, sivil bilinçli; kamu yararı ve demokratik hesap verebilirliğe odaklanır.',
    'ethics':
        'Çok yüksek. Sıkı gerçek denetimi, sansasyonalizm yok, dengeli bakış açısı şart.',
    'clickbaitThreshold': 15,
  },
  {
    'id': 'persona_tabloid',
    'name': 'Ticari Magazin',
    'description':
        'Tıklanma, sansasyon ve dedikodu odaklı yayın anlayışı benimser.',
    'iconEmoji': '🔥',
    'isDefault': 1,
    'sortOrder': 1,
    'bias':
        'Sansasyonalist. Duygusal etki, magazin haberleri, suç ve skandala ağırlık verir.',
    'ethics':
        'Düşük. Yeterince ilgi çekiciyse doğrulanmamış söylentileri yayınlar. Gerçekten önce tıklama.',
    'clickbaitThreshold': 85,
  },
  {
    'id': 'persona_independent',
    'name': 'Bağımsız',
    'description':
        'İlerici ve anti-otoriter; az bilinen haberleri gün yüzüne çıkarır.',
    'iconEmoji': '✊',
    'isDefault': 1,
    'sortOrder': 2,
    'bias':
        'İlerici, iktidara karşı. Göz ardı edilen haberlere, aktivizme ve sistemik sorunlara öncelik verir.',
    'ethics':
        'İlkeler açısından yüksek, ancak güçlü bir yayın tutumu takınabilir.',
    'clickbaitThreshold': 40,
  },
];

const List<Map<String, dynamic>> kSeedNewsPool = [
 [
  {
    "id": "news_001",
    "headline": "Yeni Oyun Motoru Piyasaya Sürüldü",
    "summary": "Bağımsız mobil geliştiriciler için özel olarak tasarlanan yeni bir oyun motoru, endüstride devrim yaratmayı vaat ediyor.",
    "imageUrl": "",
    "category": "Teknoloji",
    "sensationalismScore": 30,
    "biasIndex": 0,
    "tags": ["oyun", "yazılım", "mobil"]
  },
  {
    "id": "news_002",
    "headline": "Başkentte Trafik Çilesi",
    "summary": "Şehir merkezinde başlatılan yeni kavşak ve yol genişletme çalışmaları, sabah saatlerinde uzun araç kuyruklarına neden oldu.",
    "imageUrl": "",
    "category": "Asayiş",
    "sensationalismScore": 60,
    "biasIndex": 5,
    "tags": ["trafik", "şehir", "altyapı"]
  },
  {
    "id": "news_003",
    "headline": "Merkez Bankası Faiz Kararını Açıkladı",
    "summary": "Piyasaların merakla beklediği toplantıdan sürpriz bir karar çıktı. Analistler, bu hamlenin döviz kurlarındaki dalgalanmayı durdurmasını bekliyor.",
    "imageUrl": "",
    "category": "Ekonomi",
    "sensationalismScore": 45,
    "biasIndex": 10,
    "tags": ["ekonomi", "faiz", "döviz"]
  },
  {
    "id": "news_004",
    "headline": "Tarihi Eser Operasyonu",
    "summary": "Gümrük muhafaza ekipleri, sınır kapısında gerçekleştirdikleri rutin kontrolde paha biçilemez Roma dönemi tarihi eserleri ele geçirdi.",
    "imageUrl": "",
    "category": "Asayiş",
    "sensationalismScore": 70,
    "biasIndex": 0,
    "tags": ["kaçakçılık", "tarih", "operasyon"]
  },
  {
    "id": "news_005",
    "headline": "Şampiyonluk Yarışı Kızışıyor",
    "summary": "Ligin zirvesindeki iki takımın bu hafta sonu oynayacağı tarihi derbi maçının biletleri sadece beş dakika içinde tükendi.",
    "imageUrl": "",
    "category": "Spor",
    "sensationalismScore": 85,
    "biasIndex": 15,
    "tags": ["spor", "futbol", "derbi"]
  },
  {
    "id": "news_006",
    "headline": "Mars'ta Su İzi Bulundu",
    "summary": "Uzay ajansının yolladığı yeni keşif aracı, kızıl gezegenin güney kutbunda donmuş halde devasa su kaynakları tespit etti.",
    "imageUrl": "",
    "category": "Bilim",
    "sensationalismScore": 40,
    "biasIndex": 0,
    "tags": ["uzay", "bilim", "mars"]
  },
  {
    "id": "news_007",
    "headline": "Ünlü Oyuncudan Kötü Haber",
    "summary": "Sevilen aksiyon filmi aktörü, çekimler sırasında set kazası geçirerek hastaneye kaldırıldı. Çekimlere süresiz ara verildi.",
    "imageUrl": "",
    "category": "Magazin",
    "sensationalismScore": 80,
    "biasIndex": -5,
    "tags": ["magazin", "sinema", "kaza"]
  },
  {
    "id": "news_008",
    "headline": "Küresel Isınma Alarma Geçirdi",
    "summary": "Kutuplardaki buzulların erime hızı, son on yılın en yüksek seviyesine ulaşarak kıyı şeritleri için tehlike çanlarını çaldırdı.",
    "imageUrl": "",
    "category": "Bilim",
    "sensationalismScore": 65,
    "biasIndex": -10,
    "tags": ["iklim", "çevre", "küresel ısınma"]
  },
  {
    "id": "news_009",
    "headline": "Teknoloji Devinden Yapay Zeka Hamlesi",
    "summary": "Dünyaca ünlü yazılım şirketi, karmaşık metin ve görselleri anında işleyebilen yeni yapay zeka asistanını tanıttı.",
    "imageUrl": "",
    "category": "Teknoloji",
    "sensationalismScore": 50,
    "biasIndex": 5,
    "tags": ["yapay zeka", "yazılım", "inovasyon"]
  },
  {
    "id": "news_010",
    "headline": "Altın Fiyatlarında Rekor Kırıldı",
    "summary": "Küresel piyasalardaki belirsizlik ve artan enflasyon endişeleri, yatırımcıyı yeniden güvenli liman olan altına yöneltti.",
    "imageUrl": "",
    "category": "Ekonomi",
    "sensationalismScore": 75,
    "biasIndex": 0,
    "tags": ["altın", "piyasa", "yatırım"]
  },
  {
    "id": "news_011",
    "headline": "E-Spor Turnuvasında Büyük Sürpriz",
    "summary": "Yılın en büyük taktiksel nişancı (FPS) turnuvasında, favori gösterilmeyen genç bir takım şampiyonluk kupasını havaya kaldırdı.",
    "imageUrl": "",
    "category": "Spor",
    "sensationalismScore": 60,
    "biasIndex": 0,
    "tags": ["espor", "oyun", "turnuva"]
  },
  {
    "id": "news_012",
    "headline": "Yeni Eğitim Müfredatı Yolda",
    "summary": "Eğitim Bakanlığı, gelecek yıldan itibaren pilot okullarda uygulanacak teknoloji ve inovasyon odaklı yeni eğitim sisteminin detaylarını paylaştı.",
    "imageUrl": "",
    "category": "Bilim",
    "sensationalismScore": 35,
    "biasIndex": -15,
    "tags": ["eğitim", "okul", "teknoloji"]
  },
  {
    "id": "news_013",
    "headline": "Gizemli Kayıp Vakası Çözüldü",
    "summary": "10 yıldır haber alınamayan bir adamın, kimlik değiştirerek okyanus ötesinde yeni bir hayat kurduğu ortaya çıktı. Olayın ardındaki sırlar araştırılıyor.",
    "imageUrl": "",
    "category": "Asayiş",
    "sensationalismScore": 90,
    "biasIndex": 0,
    "tags": ["gizem", "asayiş", "soruşturma"]
  },
  {
    "id": "news_014",
    "headline": "Elektrikli Araç Satışları Patladı",
    "summary": "Otomotiv pazarında tarihi bir dönüm noktası yaşanıyor. Yılın ilk çeyreğinde elektrikli otomobil satışları, benzinli araçları ilk kez geride bıraktı.",
    "imageUrl": "",
    "category": "Ekonomi",
    "sensationalismScore": 55,
    "biasIndex": 10,
    "tags": ["otomotiv", "elektrikli araç", "pazar"]
  },
  {
    "id": "news_015",
    "headline": "Göktaşı Yağmuru Bekleniyor",
    "summary": "Bu gece gökyüzünde eşsiz bir görsel şölen yaşanacak. Uzmanlar, olayı izlemek isteyenlere ışık kirliliğinden uzaklaşmayı öneriyor.",
    "imageUrl": "",
    "category": "Bilim",
    "sensationalismScore": 25,
    "biasIndex": 0,
    "tags": ["astronomi", "doğa", "göktaşı"]
  },
  {
    "id": "news_016",
    "headline": "Ünlü Şefin Restoranı Kapatıldı",
    "summary": "Şehrin en popüler lüks restoranı, yapılan ani denetimlerde hijyen kurallarına uymadığı gerekçesiyle süresiz olarak mühürlendi.",
    "imageUrl": "",
    "category": "Asayiş",
    "sensationalismScore": 85,
    "biasIndex": -5,
    "tags": ["gıda", "denetim", "skandal"]
  },
  {
    "id": "news_017",
    "headline": "Mobil Uygulama Pazarında Yeni Trend",
    "summary": "Kullanıcıların spor salonu alışkanlıklarını ve günlük egzersizlerini takip eden yeni nesil sağlık uygulamaları indirme rekorları kırıyor.",
    "imageUrl": "",
    "category": "Teknoloji",
    "sensationalismScore": 40,
    "biasIndex": 0,
    "tags": ["mobil", "sağlık", "uygulama"]
  },
  {
    "id": "news_018",
    "headline": "Müzede Tablo Soygunu",
    "summary": "Gece yarısı ulusal müzeye giren hırsızlar, güvenlik sistemini atlatarak paha biçilemez üç tabloyu çaldı ve kayıplara karıştı.",
    "imageUrl": "",
    "category": "Asayiş",
    "sensationalismScore": 95,
    "biasIndex": 0,
    "tags": ["suç", "sanat", "soygun"]
  },
  {
    "id": "news_019",
    "headline": "Tedarik Zincirinde Kriz",
    "summary": "Büyük kargo gemilerinin kilit rotalarda yaşadığı gecikmeler, küresel perakende sektöründe ciddi ürün tedariki sorunlarına yol açıyor.",
    "imageUrl": "",
    "category": "Ekonomi",
    "sensationalismScore": 65,
    "biasIndex": -10,
    "tags": ["kriz", "lojistik", "ticaret"]
  },
  {
    "id": "news_020",
    "headline": "Uluslararası Film Festivali Sona Erdi",
    "summary": "Bu yılki festivalde büyük ödül, sıradışı bir dedektiflik hikayesini anlatan bağımsız bir yönetmenin yapımına gitti.",
    "imageUrl": "",
    "category": "Sanat",
    "sensationalismScore": 20,
    "biasIndex": 0,
    "tags": ["sinema", "festival", "ödül"]
  },
  {
    "id": "news_021",
    "headline": "Kripto Para Piyasasında Çöküş",
    "summary": "Lider kripto para birimi, gece saatlerinde gelen toplu satış baskısıyla sadece 24 saat içinde değerinin yüzde yirmisini kaybetti.",
    "imageUrl": "",
    "category": "Ekonomi",
    "sensationalismScore": 85,
    "biasIndex": -5,
    "tags": ["kripto", "finans", "çöküş"]
  },
  {
    "id": "news_022",
    "headline": "Barınaklara Destek Çağrısı",
    "summary": "Hayvan hakları dernekleri, yaklaşan sert kış ayları öncesinde sokak hayvanlarına barınak ve mama sağlamak için dev bir yardım kampanyası başlattı.",
    "imageUrl": "",
    "category": "Sosyal",
    "sensationalismScore": 45,
    "biasIndex": -20,
    "tags": ["yardım", "hayvanlar", "kampanya"]
  },
  {
    "id": "news_023",
    "headline": "Havayolu Şirketleri Grevde",
    "summary": "Sendikaya bağlı pilotların başlattığı grev nedeniyle yüzlerce uçuş iptal edildi, binlerce yolcu havalimanlarında mağdur oldu.",
    "imageUrl": "",
    "category": "Ekonomi",
    "sensationalismScore": 75,
    "biasIndex": -15,
    "tags": ["havacılık", "grev", "ulaşım"]
  },
  {
    "id": "news_024",
    "headline": "Antik Kentte Yeni Keşif",
    "summary": "Bölgede yıllardır süren kazı çalışmalarında, 3 bin yıl öncesine ait tamamen bozulmamış bir tapınak mozaiği gün yüzüne çıkarıldı.",
    "imageUrl": "",
    "category": "Bilim",
    "sensationalismScore": 30,
    "biasIndex": 0,
    "tags": ["arkeoloji", "tarih", "keşif"]
  },
  {
    "id": "news_025",
    "headline": "Siber Saldırı Paniği",
    "summary": "Ülkenin en büyük bankalarından birinin sistemlerine sızan hackerlar, on binlerce müşterinin kredi kartı verilerini ele geçirdi.",
    "imageUrl": "",
    "category": "Teknoloji",
    "sensationalismScore": 95,
    "biasIndex": 10,
    "tags": ["siber güvenlik", "hacker", "banka"]
  },
  {
    "id": "news_026",
    "headline": "Genç Girişimciden Büyük Başarı",
    "summary": "Üniversitenin işletme bölümünde okuyan bir öğrenci, iletişim ve veri analitiği üzerine kurduğu girişimiyle milyon dolarlık yatırım aldı.",
    "imageUrl": "",
    "category": "Ekonomi",
    "sensationalismScore": 50,
    "biasIndex": 5,
    "tags": ["girişimcilik", "yatırım", "başarı"]
  },
  {
    "id": "news_027",
    "headline": "Dağcılar Mahsur Kaldı",
    "summary": "Aniden bastıran kar fırtınası nedeniyle, zorlu bir zirve tırmanışı gerçekleştiren üç tecrübeli dağcıdan dünden beri haber alınamıyor.",
    "imageUrl": "",
    "category": "Asayiş",
    "sensationalismScore": 80,
    "biasIndex": 0,
    "tags": ["kurtarma", "doğa", "kaza"]
  },
  {
    "id": "news_028",
    "headline": "Kahve Fiyatlarına Büyük Zam Yolda",
    "summary": "Küresel iklim krizinin Güney Amerika'daki hasadı vurmasıyla, dünya genelinde kahve çekirdeği fiyatlarında eşi görülmemiş bir artış bekleniyor.",
    "imageUrl": "",
    "category": "Ekonomi",
    "sensationalismScore": 70,
    "biasIndex": 0,
    "tags": ["zam", "tarım", "tüketim"]
  },
  {
    "id": "news_029",
    "headline": "Yerel Seçimlerde Sürpriz Sonuç",
    "summary": "Resmi olmayan sonuçlara göre, büyük partilerin adaylarını geride bırakan bağımsız bir aday ipi göğüsleyerek yeni belediye başkanı oldu.",
    "imageUrl": "",
    "category": "Siyaset",
    "sensationalismScore": 75,
    "biasIndex": -10,
    "tags": ["seçim", "siyaset", "son dakika"]
  },
  {
    "id": "news_030",
    "headline": "Sokak Sanatçısının Eseri Satıldı",
    "summary": "Duvarlara yaptığı gizemli ve düşündürücü çizimlerle tanınan anonim sanatçının son eseri, ünlü bir müzayedede rekor fiyata alıcı buldu.",
    "imageUrl": "",
    "category": "Sanat",
    "sensationalismScore": 40,
    "biasIndex": 0,
    "tags": ["sanat", "müzayede", "koleksiyon"]
  }
]
