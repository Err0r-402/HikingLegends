import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;


using Toybox.Math;
using Toybox.Timer;

var animationTimer;

var animationFrame = 0;
var purchaseOffset = 0;




function getFullShopIcon(id) {
    var icons = {
        "walker" => Rez.Drawables.FULL_WALKER,
        "hiker" => Rez.Drawables.FULL_HIKER,
        "explorer" => Rez.Drawables.FULL_EXPLORER,
        "mountaineer" => Rez.Drawables.FULL_MOUNTAINEER,
        "trailblazer" => Rez.Drawables.FULL_TRAILBLAZER,
        "hiking_master" => Rez.Drawables.FULL_HIKING_MASTER,
        "hiking_legend" => Rez.Drawables.FULL_HIKING_LEGEND,
        "mythic_explorer" => Rez.Drawables.FULL_MYTHIC_EXPLORER,
        "ancient_way_finder" => Rez.Drawables.FULL_ANCIENT_WAY_FINDER,
        "summit_sage" => Rez.Drawables.FULL_SUMMIT_SAGE,
        "celestial_wanderer" => Rez.Drawables.FULL_CELESTIAL_WANDERER,
        "legendary_ascendant" => Rez.Drawables.FULL_LEGENDARY_ASCENDANT,
        "eternal_ascendant" => Rez.Drawables.FULL_ETERNAL_ASCENDANT
    };
    return icons.get(id);
}


class ShopItemDetailView extends WatchUi.View {

    var app;
    var itemId;
    var itemName;
    var itemPrice;
    var itemMultiplier;

    var background;
    var purchase;

    var animationTimer;
    var pauseTimer;

    var frame = 0;
    var purchaseOffset = 0;

    // Apple-style motion
    const KEYFRAMES = [
         0,
        -2,
        -5,
        -9,
        -13,
        -17,
        -20,
        -17,
        -12,
        -7,
        -3,
         1,
        -1,
         -2,
        -5,
        -9,
        -13,
        -17,
        -20,
        -17,
        -12,
        -7,
        -3,
         1,
        -1,
         0
    ];

    function initialize(app, itemId) {

        View.initialize();

        self.app = app;
        self.itemId = itemId;

        var upgrade = getUpgradeById(itemId);
        self.itemName = upgrade.get(:name);
        self.itemPrice = upgrade.get(:cost);
        self.itemMultiplier = upgrade.get(:multiplier);

        var iconRezId = getFullShopIcon(itemId);
        if (iconRezId != null) {
            background = WatchUi.loadResource(iconRezId);
        }

        purchase = WatchUi.loadResource(Rez.Drawables.Purchase);

        animationTimer = new Timer.Timer();
        pauseTimer = new Timer.Timer();
    }

    function onShow() {
        if (!app.isPurchased(itemId)) {
            startAnimation();
        }
    }

    function onHide() {
        animationTimer.stop();
        pauseTimer.stop();
    }

    function startAnimation() {

        frame = 0;

        animationTimer.start(
            method(:animate),
            16,      // Try for 60 fps
            true
        );
    }

    function animate() {

        purchaseOffset = KEYFRAMES[frame];

        frame += 1;

        WatchUi.requestUpdate();

        if (frame >= KEYFRAMES.size()) {

            animationTimer.stop();

            purchaseOffset = 0;

            pauseTimer.start(
                method(:startAnimation),
                2000,
                false
            );
        }
    }

    function onUpdate(dc) {

        dc.clear();

        if (background != null) {
            dc.drawBitmap(0,0,background);
        }

        if (!app.isPurchased(itemId)) {
            dc.drawBitmap(
                purchaseOffset+340,
                80,
                purchase
            );
        }
    }
}

class ShopItemDetailDelegate extends WatchUi.BehaviorDelegate {

    var app;
    var itemId;

    function initialize(app, itemId) {
        BehaviorDelegate.initialize();
        self.app = app;
        self.itemId = itemId;
    }

    function onKey(keyEvent as KeyEvent) as Boolean {
        var key = keyEvent.getKey();

        if (key == 4) {
            var result = app.purchaseItem(itemId);
            var rezId = Rez.Drawables.Insufficient;

            if (result == :success) {
                rezId = Rez.Drawables.Bought;
            } else if (result == :already_owned) {
                rezId = Rez.Drawables.AlreadyOwned;
            }

            WatchUi.pushView(new ShopResultView(app, rezId), null, WatchUi.SLIDE_LEFT);
            return true;
        }

        if (key == 5) {
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            return true;
        }

        return false;
    }
}
