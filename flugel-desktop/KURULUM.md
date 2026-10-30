# Kurulum ve geri yükleme

31 Ekim 2026'da çalışan **EndeavourOS / Arch Linux, Hyprland 0.56.2 ve Quickshell 0.3.2** sisteminin kişisel anlık görüntüsüdür. Temiz makinede uçtan uca kurulum testi yapılmadı; doğrulama mevcut makinede dosya bütünlüğü, sözdizimi ve çalışan oturum üzerinden yapıldı.

## Önizleme

```bash
git clone --branch flugel-desktop https://github.com/gok8lp/end4-pC.git
cd end4-pC
python3 flugel-desktop/tools/restore.py
```

Son komut yalnızca önizlemedir. `home/` kullanıcı ayarları, `system/` yönetici dosyaları, `packages/` sürüm kayıtları içerir. Paket listesi, bütün uygulamaları otomatik yüklemek için hazırlanmadı.

Bu dosyalar `/home/flugel`, `flugel` kullanıcısı, UID 1000 ve bu bilgisayarın monitörleri için hazırlandı. Başka cihazda monitör adları, NVIDIA ortam değişkenleri ve sunucu adresleri uyarlanmalıdır. `restore.py --relocate-home` metinlerdeki ev dizinini mevcut kullanıcıya göre değiştirir; UID veya sunucu adreslerini değiştirmez.

## Kullanıcı ayarları

Bağımlılıkları kurup dosyaları inceledikten sonra, LibreOffice kapalıyken:

```bash
python3 flugel-desktop/tools/restore.py --apply
```

Değişen mevcut dosyalar `~/.local/state/flugel-desktop-backups/<tarih>/` altında saklanır. Kaynak dosya bağlantılarının hedefleri `manifest.json` içindedir ve geri yüklemede bağlantı olarak oluşturulur. LibreOffice'in bütün kullanıcı profili taşınmaz: dört görünüm tercihi mevcut kayıt dosyasına birleştirilir; belgeler, geçmiş ve kimlik bilgileri taşınmaz.

Bu deponun kaynaklarını `~/.config/quickshell/end4-pC` konumunda bulundur. Kök dizindeki özgün End4-pC README dosyası arayüzün genel bağımlılıklarını açıklar. Yerel değişikliklerin üzerine resmî deponun yeni dosyalarını doğrudan kopyalamak yerine kendi dalında upstream değişikliklerini birleştir. `home/.config/hypr` Caelestia tabanını ve yerel Lua değişikliklerini birlikte içerir.

Temel yerel araçlar Python 3/PyGObject/GTK4, fish, fuzzel, zenity, wl-clipboard, cliphist, playerctl, brightnessctl ve notify-send kullanır. Varsayılan terminal Terminator'dür. Telegram `Telegram` komutuyla, WhatsApp `flatpak run com.rtosta.zapzap` ile açılır. Discord `/usr/bin/discord` girişini gerektirir. Qt/KDE ayar düğmeleri ilgili KDE Control Module paketlerine ihtiyaç duyar. `.desktop` dosyaları uygulamaların kendisini içermez. Tema ve font adları GTK/Qt ayarlarında bulunur.

## Discord'a özel Mullvad

Mullvad kurulu ve hesabına giriş yapılmış olmalı; genel VPN bağlantısı **kapalı** kalmalı. `wireguard-tools` kurulduktan ve betik incelendikten sonra:

```bash
sudo bash flugel-desktop/tools/install-discord-network.sh
```

Bu işlem iki yönetici betiğini, systemd servisini, ağ alanının DNS dosyalarını ve belirli başlatıcı için sudoers kuralını kurar. Önceki aynı adlı dosyalar `/var/backups/flugel-desktop-<tarih>/` altında saklanır. Servis açılışta zorunlu olarak etkinleştirilmez; Discord başlatıcısı gerektiğinde çalıştırır.

Hesap numarası ve WireGuard özel anahtarı depoda yoktur; çalışan betik bunları mevcut `/etc/mullvad-vpn/device.json` dosyasından belleğe okur. Etkin ve geçerli bir Mullvad hesabı gerekir. Discord ayrı ağ alanında tek WireGuard çıkışına sahiptir. Tailscale'in ana makinedeki yönlendirme, DNS veya güvenlik duvarı ayarları değiştirilmez. Çıkış doğrulanamazsa Discord normal bağlantıya geçirilmez. Bu kurulum genel Mullvad bağlantısıyla eşzamanlı kullanım için hazırlanmadı.

## Caelestia ve hareketli duvar kâğıtları

`sources.json` içinde Caelestia dotfiles, AdiAmbassador'ın hareketli duvar kâğıdı destekli CLI/shell sürümleri, mpvpaper ve Matugen 4.2.0 için gerçek kaynak adresleri ve sürümler kayıtlıdır. Etkin QML dosyaları `home/.config/quickshell/caelestia*` altında bulunur. Derlenmiş eklentiler, sanal ortamlar ve program ikilileri kaynak yerine depoya konulmadı; dışarıda bırakılan iki yerel ikilinin SHA-256 değerleri ayrıca kayıtlıdır.

Hareketli Caelestia kullanmak için ilgili kaynakların README dosyalarına göre QML eklentisi derlenmeli; CLI `~/.local/share/caelestia-aw/venv`, QML modülleri `~/.local/share/caelestia-aw/qml` yoluna kurulmalıdır. `ready` işareti ancak kurulum tamamlandığında oluşturulmalıdır. mpvpaper kaynak commitinden derlenen oynatıcı `~/.local/libexec/mpvpaper`, holder programı `~/.local/bin/mpvpaper-holder` yolunda beklenir. Başlatıcı betikleri bu yolları kullanır.

Online galeri önbelleği yeniden indirilebilir: `galeri-preset-indir` betiği `Blapples/wallpapers` kaynağını kullanır. Depoda etkin ayarların ve kaydedilmiş önayarların başvurduğu mevcut yerel görseller bulunur. İlgisiz kişisel fotoğraflar, bütün indirilen medya arşivi ve tarayıcı önbellekleri alınmadı.

## Kontrol

Yeni oturumda Win+D: WhatsApp, Telegram ve Discord; Win+T: Terminator. İletişim uygulamaları oturum başlangıcında hazırlanır. `hyprctl configerrors` boş olmalıdır. Discord açıkken `systemctl status discord-mullvad.service` ve `tailscale ping flugelserver` iki bağlantının durumunu gösterir. Bu GitHub aktarımı sırasında mevcut bilgisayara ayarlar yeniden uygulanmadı ve oturum kapatılmadı.
