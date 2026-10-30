# Yerel değişikliklerin ayrıntıları

Bu kayıt 25–31 Ekim 2026 boyunca biriken **son etkin dosyaları** açıklar. Eski `.yedek-*` dosyaları ayrı değişiklikler gibi tekrar eklenmedi. Git commitleri aktarım sırasında oluşturuldu; önceki günlerde ayrı ayrı commit yapılmış gibi bir tarihçe üretilmedi.

## 1. End4-pC kaynak kodu

Başlangıç commit'i `74813a8219defc8d210c2055d6935fbfb9f93239`, gerçek kaynak `https://github.com/pctrade/end4-pC`. Kurulu sürümün tabanı korunarak çalışma ağacındaki 29 değiştirilmiş dosya ve iki yeni QML dosyası taşındı.

| Dosya / bileşen | Yerel davranış |
| --- | --- |
| `MonitorConfigOption.qml` | Monitör değişikliklerini bekletme, Kaydet/Vazgeç, kayıt kuyruğu ve ölçeğe göre mantıksal boyut hesabı. |
| `MonitorCanvas.qml`, `MonitorRect.qml` | Sürükleme/yerleşim değişikliklerini kaydetme modeline bağlama ve ekran ölçeğiyle uyumlu önizleme. |
| `HyprlandConfig.qml` | Monitör düzenini açıkça kaydetme/vazgeçme kontrolleri. |
| `SystemConfig.qml` (yeni) | Ağ, Bluetooth, ses, ekran, güç, giriş, dil ve masaüstü ayarlarına erişim sayfası. |
| `Settings.qml`, `SettingsContent.qml`, `SettingsPages.qml` | Sistem sayfasını kaydetme ve ayar sayfası/bölümünü IPC ile açma. |
| `TailscaleVpn.qml` (yeni), `SystemIcons.qml` | Yerel durum betiğinden Tailscale durumunu okuma, çubuk simgesi, bilgi balonu ve aç/kapat eylemi. Genel Mullvad bağlantısı için çakışma göstergesi; Discord'un ayrı ağ alanı bu genel bağlantı sayılmaz. |
| `DockAppButton.qml`, `DragApps.qml` | Dock simgesine basıldığında pencereyi öne getirme, küçültme veya geri getirmeyi `pencere-kucult` betiğine devretme. |
| `Dock.qml` | Uygulama düğmesinin özel klasörlü ızgarayı açması. |
| `DockMedia.qml` | Medya kartı ve kapak görselinde fareyle üzerine gelince büyüme animasyonu. |
| `Overview.qml` | Uygulama araması ile çalışma alanı ızgarasının ayrı IPC eylemleri olması. |
| `ScreenFrame.qml`, `RoundCorner.qml` | Çerçeve köşelerinin bağlı kenarlara göre görünürlüğü ve opak renk/yarıçap düzenlemesi. |
| Ortak ve panel `Visualizer.qml`, `BarContent.qml`, `VerticalBarContent.qml` | Yerel yansıtma özelliğini `pcMirrored` adıyla uyumlu kullanma. |
| `DynamicIsland.qml`, `SidebarPlayerControl.qml`, `StyledPopup.qml` | İlgili QML bağlama/özellik uyumluluğu düzenlemeleri. |
| `Notifications.qml` | Bildirim temizlemede okunmamış sayacını sıfırlama ve `notifications.clearAll` IPC eylemi. |
| `IllogicalImpulseFamily.qml` | Oturumda polkit-gnome kullanıldığı için ikinci Polkit arayüzünü açmama. |
| `scripts/colors/*`, `scripts/kvantum/materialQT.sh` | Yapılandırma adını `end4-pC` olarak kullanma; duvar kâğıdı akışında hedefli süreç kapatma, koordinat hesabı ve uygulama temalarını bağımsız tutma düzenlemeleri. |

## 2. Hyprland ve Caelestia

`home/.config/hypr/` etkin Lua yapılandırmasının tam kopyasıdır. `home/.config/caelestia/` kullanıcı değişkenleri, pencere kuralları ve başlangıç kancalarını içerir. Caelestia tabanının kaynak commit'i `sources.json` içindedir; GPL lisansı korunur.

Başlıca yerel davranışlar: Terminator varsayılan terminal; Win+D iletişim alanı; Win+A klasörlü uygulama ızgarası; Win+Tab pencere arama; alternatif arayüz seçimi; özel boşluklar, touchpad ve pencere kapatma tuşları; monitör konumu/ölçek ayarları; Chrome küçültme ve pencere geri getirme; monitöre göre PiP konum/boyut kaydı. Dosyalardaki özgün yorumlar ve komutlar da korunur.

`home/.config/quickshell/caelestia/` ve `caelestia-aw/` içindeki etkin QML kaynakları ayrıca saklanır. Sistem paketlerine yönelen dosyalar okunabilir kaynak kopyası olarak alınmıştır; derlenmiş QML eklentileri ve Python sanal ortamları alınmamıştır. Kaynak/sürüm adresleri ve lisanslar `sources.json` / `licenses/` altındadır.

## 3. Başlatıcı, dock, pencere yönetimi

`uygulama-klasor`, `uygulama-izgara`, `izgara-ac`, `pencere-ara`, `pencere-tus`, `pencere-gec`, `pencere-kucult`, `kisayol-rehberi`, `kisayol-ac` yerel uygulama/pencere deneyimini sağlar. `home/.local/state/uygulama-klasor/pinler.json` sabitlenen uygulamaları saklar. Kullanım geçmişi sayacı ve pano içerikleri alınmaz.

`arayuz-sec`, `arayuz-komut`, `arayuz-ayarlari` Caelestia ile End4-pC arasında geçişi ve komut yönlendirmesini sağlar. Arayüz seçiminin etkin değeri de snapshot'ta bulunur.

## 4. WhatsApp, Telegram, Discord ve otomatik başlangıç

`cli.json` iletişim alanında ZapZap (`com.rtosta.zapzap`), Telegram (`org.telegram.desktop`) ve Discord'u etkinleştirir; Signal devre dışıdır. `iletisim-baslat` oturum başında yalnızca eksik uygulamaları açar. Hyprland başlangıç olayı bu betiği çağırır. Discord için NetworkManager bağlantısı beklenir; mevcut uygulamalar tekrar çoğaltılmaz.

Discord kısayolu ve yerel komut `discord-mullvad` başlatıcısını kullanır. `system/` altındaki servis, kullanıcı alanından ayrı WireGuard ağı, DNS ve dar kapsamlı sudoers girişini içerir. DNS/Mullvad çıkışı açılışta doğrulanır. VPN anahtarı mevcut Mullvad kurulumundan okunur; depoda bulunmaz. Tailscale'in ana ağındaki ayarlar değiştirilmez. Ses dahil Discord'un IP trafiği bu ağ alanını kullanır; gerçek bir Discord sesli görüşmesi bu GitHub aktarımı için yapılmadı.

## 5. Tema, duvar kâğıdı, terminal ve LibreOffice

`illogical-impulse/config.json` ve `presets/`: panel/dock, avatar, widget, arka plan ve önayar düzenleri. `gtk-3.0`, `gtk-4.0`, `matugen` ve seçilmiş üretilmiş renk dosyaları: uygulama görünümü ve palet. `fish/config.fish`: etkin arayüzün terminal renklerini kullanma. Foot ve KDE terminal tercihleriyle birlikte Terminator başlatıcı dosyası da saklanır.

`hareketli-duvar`, `mpvpaper`, `galeri-preset-indir`, `masaustu-foto` görsel seçimi ve galeri yardımcılarıdır. Etkin ayarların başvurduğu mevcut yerel görseller snapshot'a eklenir. mpvpaper ve Matugen programlarının kaynak sürümleri kayıtlıdır; yerel derlenmiş ikilileri kaynak yerine yüklemekten kaçınılır.

LibreOffice başlatıcıları GTK3 koyu görünüm ortamını kullanır. Belge sayfasını beyaz tutan dört tercih `templates/libreoffice-appearance.xcu` içindedir. Tam kullanıcı kaydı kişisel geçmiş taşıyabileceği için alınmaz; geri yükleme aracı yalnızca bu görünüm özelliklerini birleştirir.

## 6. Dolphin ve yerel sunucu araçları

`home/.local/share/applications/flugel-*.desktop` sunucu hizmetlerinin masaüstü kısayollarıdır. Dolphin yer imleri/tercihleri, `bulut-giris`, `bulut-yukle` ve servis menüleri, Taildrop ve sunucu bağlantı yardımcıları birlikte saklanır. API anahtarları ve bulut parolalarının tutulduğu dosyalar alınmaz. `yedek-sunucu`, `yedek-geri`, servis/zamanlayıcı dosyaları bu bilgisayardaki yerel yedekleme araçlarıdır; sunucunun bütün verileri veya yapılandırması bu masaüstü deposuna aktarılmaz.

PipeWire filtreleri ve ilgili kullanıcı servisi de etkin masaüstü ayarları arasında saklanır. Bu, yeni bir ses ayarı uygulanması anlamına gelmez; mevcut dosyaların kaydıdır.

## 7. Envanter ve kapsam

`DOSYA-ENVANTERI.tsv` dosya başına boyut, SHA-256 ve işlev grubunu verir. `manifest.json`, dosyaları özgün yerel yolları ve kaynak dosya bağlantısı bilgisiyle eşleştirir. `packages/` kurulu sürümleri kaydeder. `excluded-runtime-binaries.json` tekrar kurulacak iki yerel program ikilisinin hash'ini; `missing-original-paths.json` var olmayan özgün yolları kaydeder.

SSH anahtarları, Mullvad hesap/cihaz anahtarları, tarayıcı ve mesajlaşma oturumları, Nextcloud kimlik bilgileri, API anahtarları, keyring, pano içerikleri, bildirim veritabanları, loglar, derleme çıktıları ve eski yedek kopyalar kapsam dışıdır. Amaç etkin masaüstünü kod/ayar düzeyinde kaydetmektir; disk görüntüsü oluşturmak değildir.
