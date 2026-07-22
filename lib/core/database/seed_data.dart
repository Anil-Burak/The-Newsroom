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
  {
    'id': 'news_001',
    'headline': 'Belediye Başkanı Rüşvet Skandalıyla Gözaltına Alındı',
    'summary':
        'Özel akşam yemeğinde müteahhitlerden nakit kabul eden belediye başkanını gösteren fotoğraflar gün yüzüne çıktı.',
    'imageUrl': '',
    'category': 'Siyaset',
    'sensationalismScore': 88,
    'biasIndex': 0,
    'tags': '["yolsuzluk","yerel","son dakika"]',
  },
  {
    'id': 'news_002',
    'headline': 'Meclis Yeni İklim Yasasını Kabul Etti',
    'summary':
        'Çığır açan yasa, 2035\'e kadar yüzde 60 yenilenebilir enerji zorunluluğu getirerek iş dünyasını ikiye böldü.',
    'imageUrl': '',
    'category': 'Siyaset',
    'sensationalismScore': 22,
    'biasIndex': -10,
    'tags': '["iklim","politika","hükümet"]',
  },
  {
    'id': 'news_003',
    'headline': 'Ünlü Çift Ayrılık Söylentilerinin Ardından Görüntülendi',
    'summary':
        'Yıldız isimler, haftalardır süren ayrılık dedikodularını susturarak Milano\'da el ele görüntülendi.',
    'imageUrl': '',
    'category': 'Magazin',
    'sensationalismScore': 92,
    'biasIndex': 0,
    'tags': '["magazin","aşk","özel"]',
  },
  {
    'id': 'news_004',
    'headline': 'Yeni Araştırma Aşırı İşlenmiş Gıdaları Demansla İlişkilendirdi',
    'summary':
        '200.000 yetişkini kapsayan 20 yıllık kapsamlı çalışma, diyet ve bilişsel gerileme arasında güçlü bir korelasyon saptadı.',
    'imageUrl': '',
    'category': 'Bilim',
    'sensationalismScore': 45,
    'biasIndex': 0,
    'tags': '["sağlık","bilim","beslenme"]',
  },
  {
    'id': 'news_005',
    'headline': 'Borsa Tek Günde Yüzde 8 Çöktü',
    'summary':
        'Sürpriz faiz artışının tetiklediği panik satışları borsadan 2 trilyon dolar sildi.',
    'imageUrl': '',
    'category': 'Ekonomi',
    'sensationalismScore': 72,
    'biasIndex': 15,
    'tags': '["finans","çöküş","ekonomi"]',
  },
  {
    'id': 'news_006',
    'headline': 'Öğretmenler Sendikası Ulusal Grev Çağrısı Yaptı',
    'summary':
        'Yüz binlerce öğretmen, durağan maaşlar ve aşırı kalabalık sınıflar gerekçesiyle iş bırakmayı planlıyor.',
    'imageUrl': '',
    'category': 'Siyaset',
    'sensationalismScore': 55,
    'biasIndex': -20,
    'tags': '["eğitim","grev","işçi"]',
  },
  {
    'id': 'news_007',
    'headline': 'Seri Katil 15 Yıl Sonra Yakalandı',
    'summary':
        'DNA teknolojisi polisi, üç eyaletteki 11 aydınlatılamamış cinayetle bağlantılı bir şüpheliye ulaştırdı.',
    'imageUrl': '',
    'category': 'Suç',
    'sensationalismScore': 95,
    'biasIndex': 0,
    'tags': '["suç","cinayet","son dakika"]',
  },
  {
    'id': 'news_008',
    'headline': 'Teknoloji Devi Veri Gizliliği İhlali Nedeniyle 4,2 Milyar Euro Ceza Aldı',
    'summary':
        'AB\'nin şimdiye kadarki en büyük cezası, yasadışı kullanıcı verisi toplama üzerine yürütülen 3 yıllık soruşturmanın ardından geldi.',
    'imageUrl': '',
    'category': 'Ekonomi',
    'sensationalismScore': 38,
    'biasIndex': -15,
    'tags': '["teknoloji","gizlilik","AB"]',
  },
  {
    'id': 'news_009',
    'headline': 'Olimpiyat Şampiyonu Doping Kullandığını İtiraf Etti',
    'summary':
        'Altın madalyalı sporcu, son üç şampiyonada yasaklı madde kullandığını kabul etti.',
    'imageUrl': '',
    'category': 'Spor',
    'sensationalismScore': 80,
    'biasIndex': 0,
    'tags': '["spor","skandal","olimpiyat"]',
  },
  {
    'id': 'news_010',
    'headline': 'Sınırda Mülteci Krizi Kritik Boyuta Ulaştı',
    'summary':
        'Yardım kuruluşları, işlem bekleyen 50.000 mülteciye dikkat çekerek insani felakete karşı uyardı.',
    'imageUrl': '',
    'category': 'Siyaset',
    'sensationalismScore': 60,
    'biasIndex': -25,
    'tags': '["mülteci","sınır","insani yardım"]',
  },
  {
    'id': 'news_011',
    'headline': 'Bilim İnsanları Alzheimer\'a Potansiyel Tedavi Keşfetti',
    'summary':
        'Protein bazlı terapi, denemelerde erken evre Alzheimer\'ı geri döndürmede yüzde 70 etkinlik gösterdi.',
    'imageUrl': '',
    'category': 'Bilim',
    'sensationalismScore': 30,
    'biasIndex': 0,
    'tags': '["alzheimer","tıp","atılım"]',
  },
  {
    'id': 'news_012',
    'headline': 'Reality TV Yıldızının Malibü\'deki Villası Yandı',
    'summary':
        'Fenomen isim ve köpekleri sağ salim kurtuldu; ancak 15 milyon dolar değerinde mülk küle döndü.',
    'imageUrl': '',
    'category': 'Magazin',
    'sensationalismScore': 89,
    'biasIndex': 0,
    'tags': '["yangın","magazin","malibü"]',
  },
  {
    'id': 'news_013',
    'headline': 'Merkez Bankası Faizi Beşinci Kez Artırdı',
    'summary':
        'Analistler bu hamlenin enflasyonu dizginlemeyi amaçlarken ekonomiyi resesyona sürükleme riskini de beraberinde getirdiği konusunda uyarıyor.',
    'imageUrl': '',
    'category': 'Ekonomi',
    'sensationalismScore': 18,
    'biasIndex': 10,
    'tags': '["ekonomi","faiz","enflasyon"]',
  },
  {
    'id': 'news_014',
    'headline': 'Muhbir Hükümetin Gözetleme Programını İfşa Etti',
    'summary':
        'Sızdırılan belgeler, istihbarat birimlerinin milyonlarca vatandaşın sosyal medyasını mahkeme kararı olmadan izlediğini ortaya koydu.',
    'imageUrl': '',
    'category': 'Siyaset',
    'sensationalismScore': 75,
    'biasIndex': -30,
    'tags': '["gözetleme","hükümet","gizlilik"]',
  },
  {
    'id': 'news_015',
    'headline': 'Ulusal Futbol Ligi Yurt Dışı Genişlemesini Duyurdu',
    'summary':
        'Avrupa\'ya açılımı kapsayan planla 2027\'ye kadar lige üç yeni uluslararası takım eklenecek.',
    'imageUrl': '',
    'category': 'Spor',
    'sensationalismScore': 35,
    'biasIndex': 0,
    'tags': '["spor","futbol","genişleme"]',
  },
  {
    'id': 'news_016',
    'headline': 'Uyuşturucu Karteli Lideri Yüksek Güvenlikli Hapishaneden Kaçtı',
    'summary':
        'Hapishane altında keşfedilen tünelin kaçışa yardım eden 12 silahlı gardiyan tarafından kullanıldığı öne sürülüyor.',
    'imageUrl': '',
    'category': 'Suç',
    'sensationalismScore': 97,
    'biasIndex': 0,
    'tags': '["suç","hapishane","kaçış"]',
  },
  {
    'id': 'news_017',
    'headline': 'Yerel Çiftçi Dünyanın En Ağır Balkabaklarını Yetiştirdi',
    'summary':
        'Idaho\'lu emekli mühendis, devlet fuarında 635 kiloluk balkabağıyla dünya rekoru kırdı.',
    'imageUrl': '',
    'category': 'İlginç',
    'sensationalismScore': 10,
    'biasIndex': 0,
    'tags': '["rekor","çiftçilik","ilginç"]',
  },
  {
    'id': 'news_018',
    'headline': 'Yapay Zeka Sistemi Kanser Tespitinde Radyologları Geçti',
    'summary':
        'Yeni derin öğrenme modeli, klinik denemelerde erken evre akciğer kanserini yüzde 94,5 doğrulukla tespit etti.',
    'imageUrl': '',
    'category': 'Bilim',
    'sensationalismScore': 40,
    'biasIndex': 0,
    'tags': '["yapayZeka","tıp","kanser"]',
  },
  {
    'id': 'news_019',
    'headline': 'Müteahhit İflasının Ardından Konut Fiyatları Yüzde 15 Düştü',
    'summary':
        'Büyük bir inşaat firmasının çöküşüyle binlerce ev sahibi negatif özkaynakla karşı karşıya kaldı.',
    'imageUrl': '',
    'category': 'Ekonomi',
    'sensationalismScore': 65,
    'biasIndex': 5,
    'tags': '["konut","ekonomi","iflas"]',
  },
  {
    'id': 'news_020',
    'headline': 'Pop Yıldızı Saçlarını Kazıttı, Gözyaşlı Video Paylaştı',
    'summary':
        'Grammy ödüllü ismin duygusal çöküşü, ünlülerin ruh sağlığı üzerine geniş çaplı tartışma başlattı.',
    'imageUrl': '',
    'category': 'Magazin',
    'sensationalismScore': 87,
    'biasIndex': 0,
    'tags': '["magazin","ruhSağlığı","viral"]',
  },
  {
    'id': 'news_021',
    'headline': 'BM Raporu: Okyanuslardaki Plastik 2035\'te Balıkları Geçecek',
    'summary':
        'Çarpıcı rapor, tek kullanımlık plastik üretimine yönelik ivedi bir küresel anlaşma çağrısında bulunuyor.',
    'imageUrl': '',
    'category': 'Bilim',
    'sensationalismScore': 50,
    'biasIndex': -10,
    'tags': '["okyanus","plastik","çevre"]',
  },
  {
    'id': 'news_022',
    'headline': 'Kanlı Çete Savaşı Başkentte 18 Kişiyi Hayattan Kopardı',
    'summary':
        'İki rakip grup arasındaki şiddetli bölge çatışması gündüz vakti şehir merkezinde patlak verdi.',
    'imageUrl': '',
    'category': 'Suç',
    'sensationalismScore': 96,
    'biasIndex': 5,
    'tags': '["suç","çete","şiddet"]',
  },
  {
    'id': 'news_023',
    'headline': 'Hükümet Emeklilik Maaşlarını Yüzde 20 Kesmeyi Teklif Etti',
    'summary':
        'Yetkililer bütçe açıklarını gerekçe gösterirken emekli grupları kitlesel protestolar planlıyor.',
    'imageUrl': '',
    'category': 'Siyaset',
    'sensationalismScore': 55,
    'biasIndex': 20,
    'tags': '["emeklilik","bütçe","protestolar"]',
  },
  {
    'id': 'news_024',
    'headline': 'Uzay Ajansı Mars\'ta Su Kanıtı Buldu',
    'summary':
        'Uydu verileri geniş yeraltı rezervuarlarını gözler önüne sererek gelecekteki insan kolonizasyonu umutlarını yeniden alevlendirdi.',
    'imageUrl': '',
    'category': 'Bilim',
    'sensationalismScore': 42,
    'biasIndex': 0,
    'tags': '["mars","uzay","su"]',
  },
  {
    'id': 'news_025',
    'headline': 'Viral Video Protestoda Polis Şiddetini Gözler Önüne Serdi',
    'summary':
        '40 milyon kez izlenen görüntüler, polislerin barışçıl göstericilere güç kullandığını ortaya koyuyor.',
    'imageUrl': '',
    'category': 'Siyaset',
    'sensationalismScore': 82,
    'biasIndex': -35,
    'tags': '["polis","protesto","şiddet"]',
  },
  {
    'id': 'news_026',
    'headline': 'Milyarder Süper Modele Özel Adada Evlenme Teklif Etti',
    'summary':
        'Teknoloji milyarderinin 7 haneli bütçeli görkemli teklifi, sosyal medyada 2 milyon kişi tarafından canlı izlendi.',
    'imageUrl': '',
    'category': 'Magazin',
    'sensationalismScore': 76,
    'biasIndex': 0,
    'tags': '["magazin","milyarder","aşk"]',
  },
  {
    'id': 'news_027',
    'headline': 'Fabrika İşçileri Tehlikeli Kimyasal Atık Dökümünü Belgeledi',
    'summary':
        'Kimya tesisi çalışanları, yasadışı zehirli atıkların yerel nehirlere boşaltıldığını gizlice kayıt altına aldı.',
    'imageUrl': '',
    'category': 'Siyaset',
    'sensationalismScore': 62,
    'biasIndex': -20,
    'tags': '["çevre","şirket","muhbir"]',
  },
  {
    'id': 'news_028',
    'headline': 'Ulusal İşsizlik Oranı Tarihi Düşük Seviyeye İndi',
    'summary':
        '50 yılın en düşüğü olan yüzde 3,1\'lik oran, yeşil enerji sektöründeki büyümeye bağlanıyor.',
    'imageUrl': '',
    'category': 'Ekonomi',
    'sensationalismScore': 15,
    'biasIndex': -5,
    'tags': '["ekonomi","istihdam","işsizlik"]',
  },
  {
    'id': 'news_029',
    'headline': 'Çocuk Yıldızın Anne-Babası Finansal Sömürüden Tutuklandı',
    'summary':
        'Soruşturmacılar, ebeveynlerin genç oğullarının oyunculuk kariyerinden 8 milyon dolardan fazlasını aktardığını öne sürüyor.',
    'imageUrl': '',
    'category': 'Suç',
    'sensationalismScore': 85,
    'biasIndex': 0,
    'tags': '["suç","magazin","çocukİstismarı"]',
  },
  {
    'id': 'news_030',
    'headline': 'Şehir Tarihi Merkezi Araçlara Kapatmayı Planlıyor',
    'summary':
        'Tartışmalı yeşil girişim emisyonları azaltmayı hedeflerken iş sahipleri ve sürücüler öfkesini dile getiriyor.',
    'imageUrl': '',
    'category': 'Siyaset',
    'sensationalismScore': 30,
    'biasIndex': -15,
    'tags': '["çevre","şehir","ulaşım"]',
  },
];
