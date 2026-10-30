-- Kullanıcı ayarları (Caelestia dots'un üzerine)
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- end4-pC ayarlar penceresinin kalıcı kaydı (Hyprland sekmesi). Eskiden hiçbir yerden yüklenmiyordu;
-- değişiklikler yeniden başlatınca kayboluyordu. Kişisel tercihler (aşağıdaki bloklar) her zaman son sözü söyler.
pcall(dofile, os.getenv("HOME") .. "/.config/hypr/hyprland/shellOverrides/main.lua")

hl.config({input = {kb_layout = "tr,us", kb_options = "grp:alt_shift_toggle",
    touchpad = {tap_to_click = true, natural_scroll = true, disable_while_typing = true}}})
hl.config({general = {resize_on_border = true, extend_border_grab_area = 15}})

-- Fareyle taşı/boyutlandır (Super'e ek olarak Alt ile de)
hl.bind("ALT + mouse:272", hl.dsp.window.drag(), {mouse = true})
hl.bind("ALT + mouse:273", hl.dsp.window.resize(), {mouse = true})

-- İlk girişte videodaki duvar kağıdı + ondan renk şeması (bir kez)
hl.on("hyprland.start", function()
    hl.exec_cmd("sh -c 'm=$HOME/.local/state/caelestia/ilk-duvar; [ -e $m ] && exit 0; sleep 4; caelestia wallpaper -f $HOME/Pictures/Wallpapers/caelestia-acik.png && caelestia scheme set -n dynamic && mkdir -p ${m%/*} && touch $m'")
end)

-- Hyprland eklentileri (hyprpm): açılışta etkin olanları yükle
hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpm reload -n")
end)

-- Hyprspace: Super + O ile tüm çalışma alanlarına kuşbakışı (eklenti yüklü değilse bir şey yapmaz)
hl.bind("SUPER + O", function()
    if hl.plugin and hl.plugin.overview then hl.plugin.overview.toggle() end
end, { description = "Hyprspace overview" })

-- Super + Tab: açık pencereler + uygulamalar arasında arama (~/.local/bin/pencere-ara)
hl.bind("SUPER + TAB", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/pencere-tus"), { description = "Pencere/uygulama ara" })

-- Super + A: Ubuntu'daki gibi tam ekran uygulama ızgarası (nwg-drawer)
hl.bind("SUPER + A", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/izgara-ac"), { description = "Uygulama ızgarası" })
hl.layer_rule({ match = { namespace = "nwg-drawer" }, blur = true, ignore_alpha = 0.2, animation = "fade" })

-- Dil: İngilizce arayüz (klavye Türkçe kalır; para/ölçü/kağıt Türkiye)
hl.env("LANG", "en_US.UTF-8")
hl.env("LC_MESSAGES", "en_US.UTF-8")
hl.env("LC_TIME", "en_US.UTF-8")
hl.env("LC_NUMERIC", "en_US.UTF-8")

-- Super + A ızgarası arka planda hazır beklesin (anında açılsın)
hl.on("hyprland.start", function()
    hl.exec_cmd("sleep 3 && " .. os.getenv("HOME") .. "/.local/bin/izgara-ac --baslat")
    hl.exec_cmd("sleep 4 && " .. os.getenv("HOME") .. "/.local/bin/kisayol-ac --baslat")
end)

-- Türkçe klavyede "=" Shift+0 olduğu için Super + = çalışmıyor: 0'ın sağındaki "*" tuşu genişletir
-- (Super + - zaten çalışıyor: daraltır). Shift ile birlikte yükseklik.
local fn_ = require("utils.functions")
hl.bind("SUPER + asterisk", fn_.resize_active_window(10, 0), { repeating = true })
hl.bind("SUPER + SHIFT + asterisk", fn_.resize_active_window(0, 10), { repeating = true })
hl.bind("SUPER + SHIFT + question", fn_.resize_active_window(0, 10), { repeating = true })

-- Kate (hafif metin/kod editörü): Super + Alt + C  (Super + C = Eclipse)
hl.bind("SUPER + ALT + C", hl.dsp.exec_cmd("kate"), { description = "Kate" })

-- Resim içinde resim (PiP), gnome-pip-konum'un Hyprland karşılığı:
--  * ilk açılışta bulunduğu monitörün sağ altında (bar/çerçeve payı düşülerek) açılır
--  * konum ve boyut monitör başına kaydedilir; sonraki açılışta son kullanılan monitörde aynı yerde açılır
--  * monitör çözünürlüğü/ölçeği değiştiyse konum yeni boyuta ölçeklenir; o monitör takılı değilse etkin monitörün sağ altına düşer
--  * yüzen + sabitli (tüm sanal masaüstlerinde, en üstte): Caelestia'nın PiP kuralı (rules.lua) sağlar; bu blok ondan sonra çalışır
-- Kayıt: ~/.local/state/pip-konum-monitor  (satır başına: "son <monitör>" ya da "<monitör> rx ry w h mantıksal_g mantıksal_y")
do
    local pip_dosya = os.getenv("HOME") .. "/.local/state/pip-konum-monitor"
    local function pip_mi(w)
        if not (w and w.title) then return false end
        return string.find(w.title, "^Picture[- ]in[- ][Pp]icture$") ~= nil
            or string.find(w.title, "^Pencere içinde pencere$") ~= nil
    end
    local function mantiksal(m)
        return m.width / m.scale, m.height / m.scale
    end
    local function monitor_bul(ad) -- çıkarılmış monitör adında hata vermesin
        if not ad then return nil end
        local ok, m = pcall(hl.get_monitor, ad)
        if ok then return m end
    end
    local function oku()
        local kayit, son = {}, nil
        local f = io.open(pip_dosya, "r")
        if not f then return kayit, nil end
        for satir in f:lines() do
            local s = satir:match("^son (%S+)$")
            if s then
                son = s
            else
                local ad, rx, ry, w, h, lw, lh = satir:match("^(%S+) (%-?[%d.]+) (%-?[%d.]+) ([%d.]+) ([%d.]+) ([%d.]+) ([%d.]+)$")
                if ad then
                    kayit[ad] = { rx = tonumber(rx), ry = tonumber(ry), w = tonumber(w), h = tonumber(h),
                                  lw = tonumber(lw), lh = tonumber(lh) }
                end
            end
        end
        f:close()
        return kayit, son
    end
    local function yaz(kayit, son)
        local f = io.open(pip_dosya, "w")
        if not f then return end
        if son then f:write("son " .. son .. "\n") end
        for ad, k in pairs(kayit) do
            local fl = math.floor -- kesirli ölçekte (ör. 1.333) %d tam sayı ister
            f:write(string.format("%s %d %d %d %d %d %d\n", ad, fl(k.rx), fl(k.ry), fl(k.w), fl(k.h), fl(k.lw), fl(k.lh)))
        end
        f:close()
    end
    local function sag_alt(m, w, h)
        local lw, lh = mantiksal(m)
        local r = m.reserved or {}
        local pay = math.floor(math.min(lw, lh) * 0.02)
        return math.floor(m.x + lw - w - (r.right or 0) - pay), math.floor(m.y + lh - h - (r.bottom or 0) - pay)
    end
    local function yerlestir(win)
        if not pip_mi(win) or not win.size then return end
        local kayit, son = oku()
        local m = monitor_bul(son)
        local k = m and kayit[m.name] or nil
        if not m then m = hl.get_active_monitor() end -- kayıtlı monitör çıkarılmış ya da hiç kayıt yok
        if not m then return end
        local lw, lh = mantiksal(m)
        local w, h, x, y
        if k then
            local ox, oy = lw / k.lw, lh / k.lh -- düzen değiştiyse oranla
            w, h = math.floor(k.w * ox), math.floor(k.h * oy)
            x, y = math.floor(m.x + k.rx * ox), math.floor(m.y + k.ry * oy)
        else
            w, h = win.size.x, win.size.y
            if son and kayit[son] then w, h = kayit[son].w, kayit[son].h end -- boyut eski monitörden taşınır
            x, y = sag_alt(m, w, h)
        end
        -- monitör dışına taşmasın
        x = math.max(m.x, math.min(x, math.floor(m.x + lw - w)))
        y = math.max(m.y, math.min(y, math.floor(m.y + lh - h)))
        hl.dispatch(hl.dsp.window.resize({ x = w, y = h, window = win }))
        hl.dispatch(hl.dsp.window.move({ x = x, y = y, relative = false, window = win }))
    end
    hl.on("window.open", yerlestir)
    hl.on("window.title", yerlestir)
    hl.on("window.close", function(win)
        if not (pip_mi(win) and win.at and win.size) then return end
        -- monitör pencerenin merkezinden: taşınan yüzen pencerede win.monitor eski monitörde kalabiliyor
        local ok, m = pcall(hl.get_monitor_at, { x = win.at.x + win.size.x / 2, y = win.at.y + win.size.y / 2 })
        if not ok or not m then m = win.monitor and monitor_bul(win.monitor.name) end
        if not m then return end
        local lw, lh = mantiksal(m)
        local kayit = oku()
        kayit[m.name] = { rx = win.at.x - m.x, ry = win.at.y - m.y, w = win.size.x, h = win.size.y, lw = lw, lh = lh }
        yaz(kayit, m.name)
    end)
end

-- Telegram da iletişim alanına (Super+D): Discord/WhatsApp ile yan yana döşenir
hl.window_rule({ match = { class = "org.telegram.desktop" }, tag = "+communication_app" })

-- Klasörlü uygulama ızgarası (uygulama-klasor): bulanık arka plan + yumuşak geçiş
hl.layer_rule({ match = { namespace = "app-izgara" }, blur = true, ignore_alpha = 0.2, animation = "fade" })

-- AOC ekran laptopun solunda
-- Ölçek/mod/konum artık ayarlar penceresi > Hyprland sekmesinden yönetilir (~/.config/hypr/monitors.lua)
local monitors_file = os.getenv("HOME") .. "/.config/hypr/monitors.lua"
local ok = pcall(dofile, monitors_file)
if not ok then
    hl.monitor({ output = "eDP-1", mode = "2560x1600@60", position = "0x0", scale = 1.25 })
    hl.monitor({ output = "DP-1", mode = "1920x1080@60", position = "-1920x0", scale = 1 })
end

-- Masaüstü arayüzünü seç / ayarlarını aç
hl.bind("SUPER + CTRL + F12", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/arayuz-sec"), { description = "Arayüz seç" })
hl.bind("SUPER + CTRL + F11", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/arayuz-ayarlari"), { description = "Arayüz ayarları" })

hl.bind("SUPER + CTRL + F10", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/hareketli-duvar"), { description = "Hareketli duvar kağıdı" })

-- Chrome "simge durumuna küçült" düğmesi: Hyprland olay vermediği için tıklama konumundan yakalanır
hl.bind("mouse:272", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/pencere-kucult tikla"), { release = true, non_consuming = true, description = "Chrome küçült düğmesi" })
hl.bind("SUPER + ALT + M", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/pencere-kucult geri"), { description = "Küçültülen pencereyi geri getir" })

-- Hyprland kısayol rehberi (sağ alttan kayan popup)
hl.bind("SUPER + H", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/kisayol-ac"), { description = "Kısayol rehberi (Help)" })
hl.bind("ALT + TAB", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/pencere-gec"), { description = "Son kullanılan pencereye geç" })
-- Clipline (pano rafları): zaten çalışıyorsa rafları açar, değilse başlatır
hl.bind("SUPER + CTRL + T", hl.dsp.exec_cmd("env CLIPLINE_HOME=" .. os.getenv("HOME") .. "/projeler/clipline-linux " .. os.getenv("HOME") .. "/projeler/clipline-linux/packaging/clipline"), { description = "Clipline pano rafları" })
-- 5 parmakla touchpad kaydırma: ilk boş çalışma alanına geç
hl.gesture({ fingers = 5, direction = "swipe", action = function()
    hl.exec_cmd([[hyprctl dispatch 'hl.dsp.focus({ workspace = "empty" })']])
end })

-- WhatsApp (ZapZap): Super+D iletişim alanı
hl.window_rule({ match = { class = "com.rtosta.zapzap" }, tag = "+communication_app" })

-- Win+D uygulamalarını oturum başlangıcında hazırla
hl.on("hyprland.start", function()
    hl.exec_cmd(os.getenv("HOME") .. "/.local/bin/iletisim-baslat")
end)
