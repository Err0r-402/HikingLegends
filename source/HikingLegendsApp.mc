import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;


class HikingLegendsApp extends Application.AppBase {

    var stepsStart = 0;
    var currency = 0l;
    var currencyPerStep = 1;
    var stepsLastUpdate = 0;
    var currentSteps = 0;
    var purchasedItems = [];
    var equippedItem = null;
    function initialize() {
        AppBase.initialize();
        
    }

    function onStart(state as Dictionary?) as Void {
        
        var info = ActivityMonitor.getInfo();
        
        if (info != null && info.steps != null) {
        currentSteps = info.steps;

        var myLastSteps = Application.Storage.getValue("stepsStart");
        if( myLastSteps != null) {
            stepsStart = myLastSteps;
        } else {
            stepsStart = info.steps;
        }

        var myLastMoney = Application.Storage.getValue("Money");

        if(myLastMoney != null) {
            currency = myLastMoney;
        } 
        else {
            currency = 0;
        
        }

        var myLastMultiplier = Application.Storage.getValue("Multiplier");

        if(myLastMultiplier != null) {
            currencyPerStep = myLastMultiplier;
        } 
        else {
            currencyPerStep = 1;

        }




        var stepsDelta = currentSteps - stepsStart;
        if (stepsDelta > 0) {
            currency += (stepsDelta * currencyPerStep).toLong();
            stepsStart = currentSteps;
        }

        var myPurchasedItems = Application.Storage.getValue("PurchasedItems");
        if (myPurchasedItems != null) {
            purchasedItems = myPurchasedItems;
        } else {
            purchasedItems = [];
        }

        equippedItem = Application.Storage.getValue("EquippedItem");

        }

       WatchUi.requestUpdate(); 
    
}

   /* 
    function onUpdate(dc) {
        
        var info = ActivityMonitor.getInfo();
        
        if (info != null && info.steps != null) {
        currentSteps = info.steps;
        }
        var stepsDelta = currentSteps - stepsStart;
        if (stepsDelta > stepsLastUpdate) {
            var newSteps = stepsDelta - stepsLastUpdate;
            currency += newSteps * currencyPerStep;
            stepsLastUpdate = stepsDelta;
        }
        
        WatchUi.requestUpdate();
        
    }*/

    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new HikingLegendsView(self) ,new testDelegate(self)];
    }

    function getCurrency() {
        return currency;
    }

    function getSteps() {
        return currentSteps;
    }

    function getCurrencyPerStep() {
        return currencyPerStep;
    }

    function setCurrency(amount){

        currency= amount;

    }

    function addCurrency(amount) {
        currency += amount;
    }

    function buyUpgrade() {
        var cost = 100 * currencyPerStep;
        if (currency >= cost) {
            currency -= cost;
            currencyPerStep += 1;
            return true;
        }
        return false;
    }

    function getPurchasedItems() {
        return purchasedItems;
    }

    function getEquippedItem() {
        return equippedItem;
    }

    function isPurchased(id) {
        for (var i = 0; i < purchasedItems.size(); i++) {
            if (purchasedItems[i].equals(id)) {
                return true;
            }
        }
        return false;
    }

    // Attempts to buy the upgrade with the given id. Returns :success,
    // :already_owned, or :insufficient_funds.
    function purchaseItem(id) {
        if (isPurchased(id)) {
            return :already_owned;
        }

        var upgrade = getUpgradeById(id);
        if (upgrade == null || currency < upgrade.get(:cost)) {
            return :insufficient_funds;
        }

        currency -= upgrade.get(:cost);
        currencyPerStep = upgrade.get(:multiplier);
        purchasedItems.add(id);
        equippedItem = id;

        Application.Storage.setValue("Money", currency);
        Application.Storage.setValue("Multiplier", currencyPerStep);
        Application.Storage.setValue("PurchasedItems", purchasedItems);
        Application.Storage.setValue("EquippedItem", equippedItem);

        return :success;
    }

}

/*function getApp() as HikingTycoonApp {
    return Application.getApp() as HikingTycoonApp;
}*/
