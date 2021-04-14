<?php

namespace Grepodata\Library\Model\IndexV2;

use Carbon\Carbon;
use Grepodata\Library\Indexer\UnitStats;
use Grepodata\Library\Model\World;
use \Illuminate\Database\Eloquent\Model;

/**
 * @property mixed id
 * @property mixed uid
 * @property mixed town_id
 * @property mixed world
 * @property mixed town_name
 * @property mixed player_id
 * @property mixed player_name
 * @property mixed alliance_id
 * @property mixed alliance_name
 * @property mixed belligerent_player_id
 * @property mixed belligerent_player_name
 * @property mixed belligerent_alliance_id
 * @property mixed belligerent_alliance_name
 * @property mixed first_attack_date
 * @property mixed cs_killed
 * @property mixed new_owner_player_id
 */
class Conquest extends Model
{
  protected $table = 'Indexer_conquest';

  public function getPublicFields(World $oWorld = null)
  {
    $aBelligerentsAll = json_decode($this->belligerent_all, true);
    $aResponse = array(
      'conquest_id'   => $this->uid,
      'town_id'       => $this->town_id,
      'town_name'     => $this->town_name,
      'player_id'     => $this->player_id,
      'player_name'   => $this->player_name,
      'alliance_id'   => $this->alliance_id,
      'alliance_name' => $this->alliance_name,
      'last_attack_date' => $this->first_attack_date,
      'belligerent_player_id'     => $this->belligerent_player_id,
      'belligerent_player_name'   => $this->belligerent_player_name,
      'belligerent_alliance_id'   => $this->belligerent_alliance_id,
      'belligerent_alliance_name' => $this->belligerent_alliance_name,
      'new_owner_player_id' => $this->new_owner_player_id,
      'cs_killed' => $this->cs_killed,
    );

    $aResponse['hide_details'] = false;
    if ($oWorld != null) {
      $Now = $oWorld->getServerTime();
      if ($this->new_owner_player_id == null
        && $this->cs_killed == false
        && $Now->diffInHours(Carbon::parse($this->first_attack_date, $oWorld->php_timezone)) < 4) {
        // add a 3 hour delay before friendly intel is visible in the detailed report
        $aResponse['hide_details'] = true;
      }
    }

    return $aResponse;
  }
}
