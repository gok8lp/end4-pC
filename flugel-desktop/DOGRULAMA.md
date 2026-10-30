# Aktarım doğrulaması

31 Ekim 2026, mevcut masaüstü üzerinde:

- Fork tabanı resmî `pctrade/end4-pC` deposunun kurulu commit'idir; yerel uygulama deposunun Git tarihçesi korunur.
- 27 JSON dosyası ayrıştırıldı; hata yok.
- 9 Python kaynağı AST ile kontrol edildi; sözdizimi hatası yok.
- 28 kabuk betiği `bash -n` ile kontrol edildi; sözdizimi hatası yok.
- `manifest.json` içindeki bütün snapshot dosyalarının SHA-256 değerleri içerikle eşleşti.
- Kaynak dosyalarla son karşılaştırmada snapshot sonrasında değişen dosya bulunmadı.
- `restore.py` mevcut kullanıcının dosyalarında yalnızca önizleme modunda çalıştırıldı: 0 farklı kullanıcı dosyası. Hiçbir ayar yeniden uygulanmadı.
- `hyprctl configerrors` boş sonuç verdi.
- Özel anahtar başlıkları, GitHub token biçimleri, kimlik bilgisi içeren URL'ler ve JSON anahtar/parola alanları tarandı; bulgu yok. Bu desen taraması mutlak bir güvence değildir; hassas uygulama profilleri ayrıca kapsam dışında tutuldu.
- Kaynak değişiklikleri için `git diff --check` temiz sonuç verdi.

Yeni makinede tam kurulum, yeniden başlatma, Discord sesli araması veya her alternatif masaüstünün yeniden başlatılması bu aktarım için yapılmadı. Çalışan yapılandırma ve yeniden kurmak için gereken kaynak/sürüm bilgileri kaydedildi.
