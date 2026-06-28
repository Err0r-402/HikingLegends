import Toybox.Lang;
import Toybox.WatchUi;

class ShopMenuDelegate extends WatchUi.Menu2InputDelegate {

    var app;

    function initialize(app) {
        Menu2InputDelegate.initialize();
        self.app = app;
    }

    function onSelect(item) {

    var id = item.getId();

    WatchUi.pushView(
        new ShopItemDetailView(app, id),
        new ShopItemDetailDelegate(app, id),
        WatchUi.SLIDE_LEFT
    );
}
}