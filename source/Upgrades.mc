import Toybox.Lang;

// Single source of truth for the shop catalog: id, display name, cost, and the
// coin-per-step multiplier granted while the item is equipped.
function getUpgrades() {
    return [
        {:id => "walker", :name => "Walker", :cost => 100l, :multiplier => 1.5},
        {:id => "hiker", :name => "Hiker", :cost => 1000l, :multiplier => 2.0},
        {:id => "explorer", :name => "Explorer", :cost => 10000l, :multiplier => 3.0},
        {:id => "mountaineer", :name => "Mountaineer", :cost => 100000l, :multiplier => 5.0},
        {:id => "trailblazer", :name => "Trailblazer", :cost => 1000000l, :multiplier => 8.0},
        {:id => "hiking_master", :name => "Hiking Master", :cost => 10000000l, :multiplier => 12.0},
        {:id => "hiking_legend", :name => "Hiking Legend", :cost => 100000000l, :multiplier => 18.0},
        {:id => "mythic_explorer", :name => "Mythic Explorer", :cost => 1000000000l, :multiplier => 27.0},
        {:id => "ancient_way_finder", :name => "Old Way Finder", :cost => 10000000000l, :multiplier => 40.0},
        {:id => "summit_sage", :name => "Summit Sage", :cost => 100000000000l, :multiplier => 60.0},
        {:id => "celestial_wanderer", :name => "Star Wanderer", :cost => 1000000000000l, :multiplier => 90.0},
        {:id => "legendary_ascendant", :name => "Legend Ascend", :cost => 50000000000000l, :multiplier => 180.0},
        {:id => "eternal_ascendant", :name => "Eternal Ascend", :cost => 1000000000000000l, :multiplier => 350.0}
    ];
}

function getUpgradeById(id) {
    var upgrades = getUpgrades();
    for (var i = 0; i < upgrades.size(); i++) {
        if (upgrades[i].get(:id).equals(id)) {
            return upgrades[i];
        }
    }
    return null;
}

// Maps an upgrade id to its small icon used in the shop list (Menu2).
function getMenuShopIcon(id) {
    var icons = {
        "walker" => Rez.Drawables.ICON_WALK,
        "hiker" => Rez.Drawables.ICON_HIKER,
        "explorer" => Rez.Drawables.ICON_EXPLORER,
        "mountaineer" => Rez.Drawables.ICON_MOUNTAIN,
        "trailblazer" => Rez.Drawables.ICON_TRAILBLAZER,
        "hiking_master" => Rez.Drawables.ICON_HIKING_MASTER,
        "hiking_legend" => Rez.Drawables.ICON_HIKING_LEGEND,
        "mythic_explorer" => Rez.Drawables.ICON_MYTHIC_EXPLORER,
        "ancient_way_finder" => Rez.Drawables.ICON_ANCIENT_WAY_FINDER,
        "summit_sage" => Rez.Drawables.ICON_SUMMIT_SAGE,
        "celestial_wanderer" => Rez.Drawables.ICON_CELESTIAL_WANDERER,
        "legendary_ascendant" => Rez.Drawables.ICON_LEGENDARY_ASCENDANT,
        "eternal_ascendant" => Rez.Drawables.ICON_ETERNAL_ASCENDANT
    };
    return icons.get(id);
}
