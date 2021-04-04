<?php

namespace Grepodata\Application\API\Route\IndexV2;

use Grepodata\Library\Controller\Indexer\IndexInfo;
use Grepodata\Library\Controller\Indexer\IndexOverview;
use Grepodata\Library\Controller\IndexV2\Roles;
use Grepodata\Library\Indexer\IndexBuilderV2;
use Grepodata\Library\Indexer\Validator;
use Grepodata\Library\IndexV2\IndexManagement;
use Grepodata\Library\Logger\Logger;
use Grepodata\Library\Model\Indexer\Stats;
use Grepodata\Library\Router\Authentication;
use Grepodata\Library\Router\BaseRoute;
use Grepodata\Library\Router\ResponseCode;
use Illuminate\Database\Eloquent\ModelNotFoundException;

class Index extends BaseRoute
{

  public static function StatsGET()
  {
    $oStats = Stats::orderBy('created_at', 'desc')
      ->first();

    if ($oStats == null) {
      die(self::OutputJson(array(
        'message'     => 'No stats found.',
      ), 404));
    }

    return self::OutputJson($oStats);
  }

  public static function GetWorldsGET()
  {
    $aServers = \Grepodata\Library\Controller\World::getServers();
    $aWorlds = \Grepodata\Library\Controller\World::getAllActiveWorlds();

    $aResponse = array();
    foreach ($aServers as $Server) {
      $aServer = array(
        'server'  => $Server
      );
      foreach ($aWorlds as $oWorld) {
        if (strpos($oWorld->grep_id, $Server) !== false) {
          $aServer['timezone'] = $oWorld->php_timezone;
          $aServer['worlds'][] = array(
            'id'    => $oWorld->grep_id,
            'val'   => substr($oWorld->grep_id, 2),
            'name'  => $oWorld->name,
          );
        }
      }
      $aServer['worlds'] = self::SortWorlds($aServer['worlds']);
      $aResponse[] = $aServer;
    }

    return self::OutputJson($aResponse);
  }

  private static function SortWorlds($aWorlds)
  {
    usort($aWorlds, function ($item1, $item2) {
      if ($item1['val'] == $item2['val']) return 0;
      return $item1['val'] < $item2['val'] ? 1 : -1;
    });
    return $aWorlds;
  }

  public static function IsValidGET()
  {
    $aParams = array();
    try {
      // Validate params
      $aParams = self::validateParams(array('key'));

      // Validate index key
      if (!Validator::IsValidIndex($aParams['key'])) {
        die(self::OutputJson(array(
          'message'     => 'Unauthorized index key. Please enter the correct index key.',
        ), 401));
      }

      return self::OutputJson(array(
        'valid' => true
      ));

    } catch (ModelNotFoundException $e) {
      die(self::OutputJson(array(
        'message'     => 'No index overview found for these parameters.',
        'parameters'  => $aParams
      ), 404));
    }
  }

  public static function GetIndexGET()
  {
    $aParams = array();
    try {
      // Validate params
      $aParams = self::validateParams(array('access_token', 'key'));
      $oUser = \Grepodata\Library\Router\Authentication::verifyJWT($aParams['access_token']);

      // Validate index key
      $oIndex = Validator::IsValidIndex($aParams['key']);
      if ($oIndex === null || $oIndex === false) {
        die(self::OutputJson(array(
          'message'     => 'Unauthorized index key. Please enter the correct index key.',
        ), 401));
      }

      $oIndexRole = IndexManagement::verifyUserCanRead($oUser, $aParams['key']);
      $bUserIsAdmin = in_array($oIndexRole->role, array(Roles::ROLE_ADMIN, Roles::ROLE_OWNER));

      $oIndexOverview = IndexOverview::firstOrFail($aParams['key']);
      if ($oIndexOverview == null) throw new ModelNotFoundException();

      $aRecentConquests = array();
      // TODO: index conquests
//      try {
//        $oWorld = World::getWorldById($oIndex->world);
//        $aConquests = Conquest::allByIndex($oIndex, 0, 30);
//        $SearchLimit = 1;
//        if (count($aConquests) > 3) $SearchLimit = 2;
//        if (count($aConquests) > 6) $SearchLimit = 3;
//        if (count($aConquests) >= 10) $SearchLimit = 4;
//        if (count($aConquests) >= 20) $SearchLimit = 5;
//        foreach ($aConquests as $oConquest) {
//          if ($oConquest->num_attacks_counted>=$SearchLimit) {
//            $aRecentConquests[] = $oConquest->getPublicFields($oWorld);
//          }
//          if (count($aRecentConquests) > 10) {
//            // only return top 10
//            break;
//          }
//        }
//      } catch (Exception $e) {
//        Logger::warning("Error loading recent conquests: " . $e->getMessage());
//      }

      $aResponse = array(
        'is_admin'          => $bUserIsAdmin,
        'world'             => $oIndexOverview['world'],
        'total_reports'     => $oIndexOverview['total_reports'],
        'spy_reports'       => $oIndexOverview['spy_reports'],
        'enemy_attacks'     => $oIndexOverview['enemy_attacks'],
        'friendly_attacks'  => $oIndexOverview['friendly_attacks'],
        'latest_report'     => $oIndexOverview['latest_report'],
        'max_version'       => $oIndexOverview['max_version'],
        'recent_conquests'  => $aRecentConquests,
        'latest_version'    => $oIndex->script_version,
        'index_version'     => $oIndex->index_version,
        'index_name'        => $oIndex->index_name,
        'role'              => $oIndexRole->role,
        'contribute'        => $oIndexRole->contribute,
        'share_link'        => $bUserIsAdmin ? $oIndex->share_link : 'Unauthorized',
        'num_days'          => $bUserIsAdmin ? $oIndex->delete_old_intel_days : 0,
        'allow_join_v1_key' => $bUserIsAdmin ? $oIndex->allow_join_v1_key : 0,
        'update_message'    => USERSCRIPT_UPDATE_INFO,
        'owners'            => json_decode(urldecode($oIndexOverview['owners'])),
        'contributors'      => json_decode(urldecode($oIndexOverview['contributors'])),
        'alliances_indexed' => json_decode(urldecode($oIndexOverview['alliances_indexed'])),
        'players_indexed'   => json_decode(urldecode($oIndexOverview['players_indexed'])),
        'latest_intel'      => json_decode(urldecode($oIndexOverview['latest_intel'])),
      );

      return self::OutputJson($aResponse);

    } catch (ModelNotFoundException $e) {
      die(self::OutputJson(array(
        'message'     => 'No index overview found for these parameters.',
        'parameters'  => $aParams
      ), 404));
    }
  }

  /**
   * Enable or disable contributing to an index
   */
  public static function IndexContributePUT()
  {
    $aParams = array();
    try {
      // Validate params
      $aParams = self::validateParams(array('access_token', 'index_key', 'contribute'));
      $oUser = \Grepodata\Library\Router\Authentication::verifyJWT($aParams['access_token']);

      $oUserRole = IndexManagement::verifyUserCanWrite($oUser, $aParams['index_key']);

      $bContribute = $aParams['contribute'] === true || $aParams['contribute'] === 'true';
      $oUserRole->contribute = $bContribute;
      $oUserRole->save();

      $aUpdatedUser = $oUserRole->getPublicFields();

      ResponseCode::success(array(
        'size' => 1,
        'data' => $aUpdatedUser
      ));

    } catch (\Exception $e) {
      ResponseCode::errorCode(1200);
    }
  }

  public static function NewIndexGET()
  {
    $aParams = array();
    try {
      // Validate params
      $aParams = self::validateParams(array('world', 'index_name', 'access_token', 'captcha'));

      // Validate captcha
      if (!bDevelopmentMode) {
        BaseRoute::verifyCaptcha($aParams['captcha']);
      }

      // Verify token
      $oUser = \Grepodata\Library\Router\Authentication::verifyJWT($aParams['access_token']);

      // New index
      $oIndex = IndexBuilderV2::buildNewIndex($aParams['world'], $aParams['index_name'], $oUser->id);
      if ($oIndex !== false && $oIndex !== null) {

        Roles::SetUserIndexRole($oUser, $oIndex, Roles::ROLE_OWNER);

        try {
          IndexOverview::buildIndexOverview($oIndex);
        } catch (\Exception $e) {
          Logger::error("Error building index overview for new index " . $oIndex->key_code . " (".$e->getMessage().")");
        }


        $aResponse = array(
          'status' => 'ok',
          'key' => $oIndex->key_code,
          'share_link' => $oIndex->share_link,
        );

        return self::OutputJson($aResponse);
      }
      else throw new \Exception();

    } catch (\Exception $e) {
      Logger::warning("Error building new index: " . $e->getMessage());
      die(self::OutputJson(array(
        'message'     => 'Error building new index.',
        'parameters'  => $aParams
      ), 404));
    }
  }

  public static function NewShareLinkGET()
  {
    $aParams = array();
    try {
      // Validate params
      $aParams = self::validateParams(array('access_token', 'index_key'));
      $oUser = \Grepodata\Library\Router\Authentication::verifyJWT($aParams['access_token']);

      $oIndex = IndexInfo::firstOrFail($aParams['index_key']);

      IndexManagement::verifyUserIsAdmin($oUser, $aParams['index_key']);

      $oIndex->share_link = IndexBuilderV2::generateIndexKey(10);
      $oIndex->save();

      $aResponse = array(
        'share_link' => $oIndex->share_link
      );
      ResponseCode::success($aResponse, 1200);

    } catch (\Exception $e) {
      die(self::OutputJson(array(
        'message'     => 'Error building new index.',
        'parameters'  => $aParams
      ), 404));
    }
  }

  public static function SetDeleteIntelDaysPUT()
  {
    try {
      $aParams = self::validateParams(array('access_token', 'index_key', 'num_days'));
      $oUser = \Grepodata\Library\Router\Authentication::verifyJWT($aParams['access_token']);

      $oIndex = IndexInfo::firstOrFail($aParams['index_key']);

      IndexManagement::verifyUserIsAdmin($oUser, $aParams['index_key']);

      $NumDays = (int) $aParams['num_days'];
      if ($NumDays < 0 || $NumDays > 365) {
        ResponseCode::errorCode(7532);
      }

      $oIndex->delete_old_intel_days = $NumDays;
      $oIndex->save();

      $aResponse = array(
        'num_days' => $NumDays
      );
      ResponseCode::success($aResponse, 1250);

    } catch (\Exception $e) {
      ResponseCode::errorCode(1200);
    }
  }

  /**
   * Toggle the allow_join_v1_key index setting which allows users to join a v1 index with the old 8 character v1 index key
   */
  public static function SetIndexJoinV1PUT()
  {
    try {
      $aParams = self::validateParams(array('access_token', 'index_key', 'allow_join_v1_key'));
      $oUser = Authentication::verifyJWT($aParams['access_token']);

      $oIndex = IndexInfo::firstOrFail($aParams['index_key']);

      IndexManagement::verifyUserIsAdmin($oUser, $aParams['index_key']);

      if (in_array($aParams['allow_join_v1_key'], array("true", "false"))) {
        $bCanJoin = $aParams['allow_join_v1_key'] === "true";
      } else {
        $bCanJoin = (bool) $aParams['allow_join_v1_key'];
      }
      if (is_null($bCanJoin)) {
        ResponseCode::errorCode(7532);
      }

      $oIndex->allow_join_v1_key = $bCanJoin;
      $oIndex->save();

      $aResponse = array(
        'allow_join_v1_key' => $bCanJoin
      );
      ResponseCode::success($aResponse, 1260);

    } catch (\Exception $e) {
      ResponseCode::errorCode(1200);
    }
  }

}
