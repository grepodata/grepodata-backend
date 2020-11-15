<?php

namespace Grepodata\Library\Controller\IndexV2;

use Carbon\Carbon;
use Exception;
use Grepodata\Library\Model\Indexer\City;
use Grepodata\Library\Model\Indexer\IndexInfo;
use Grepodata\Library\Model\User;
use Grepodata\Library\Model\World;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Capsule\Manager as DB;

class IntelShared
{

  /**
   * Returns all hashes for the given player_id on this world
   * @param $PlayerId
   * @param $World
   * @param int $Limit
   * @return Collection
   */
  public static function getHashlistForPlayer($PlayerId, $World, $Limit = 300)
  {
    return \Grepodata\Library\Model\IndexV2\IntelShared::where('world', '=', $World, 'and')
      ->where('player_id', '=', $PlayerId)
      ->orderBy('id', 'desc')
      ->limit($Limit)
      ->get();
  }

  /**
   * Returns a specific record if it exists for this hash
   * @param $World
   * @param $Hash
   * @return \Grepodata\Library\Model\IndexV2\Intel
   */
  public static function getByHashByWorld($World, $Hash)
  {
    return \Grepodata\Library\Model\IndexV2\IntelShared::where('world', '=', $World, 'and')
      ->where('report_hash', '=', $Hash)
      ->first();
  }

  /**
   * Get all records by hash by user
   * @param User $oUser
   * @param $World
   * @param $Hash
   * @return \Grepodata\Library\Model\IndexV2\IntelShared[]
   */
  public static function allByHashByUser(User $oUser, $World, $Hash)
  {
//    DB::enableQueryLog();
    $Id = $oUser->id;
    return \Grepodata\Library\Model\IndexV2\IntelShared::select(['Indexer_intel_shared.*', 'Indexer_roles.role', 'Indexer_roles.contribute'])
      ->leftJoin('Indexer_roles', 'Indexer_roles.index_key', '=', 'Indexer_intel_shared.index_key')
      ->where(function ($query) use ($Id) {
        $query->where('Indexer_roles.user_id', '=', $Id)
          ->orWhere('Indexer_intel_shared.user_id', '=', $Id);
      })
      ->where('Indexer_intel_shared.world', '=', $World)
      ->where('Indexer_intel_shared.report_hash', '=', $Hash)
      ->get();
//    $test = DB::getQueryLog();
//    return $aResult;
  }

  public static function saveHashToIndex($ReportHash, $IntelId, IndexInfo $oIndex)
  {
    $oIntelShared = new \Grepodata\Library\Model\IndexV2\IntelShared();
    $oIntelShared->intel_id = $IntelId;
    $oIntelShared->report_hash = $ReportHash;
    $oIntelShared->index_key = $oIndex->key_code;
    $oIntelShared->user_id = null;
    $oIntelShared->world = $oIndex->world;
    $oIntelShared->save();
  }

  public static function saveHashToUser($ReportHash, $IntelId, User $oUser, $World)
  {
    $oIntelShared = new \Grepodata\Library\Model\IndexV2\IntelShared();
    $oIntelShared->intel_id = $IntelId;
    $oIntelShared->report_hash = $ReportHash;
    $oIntelShared->index_key = null;
    $oIntelShared->user_id = $oUser->id;
    $oIntelShared->world = $World;
    $oIntelShared->save();
  }
}