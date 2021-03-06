<?php

namespace Grepodata\Application\API\Route\Indexer;

class DeprecatedRoutesV1 extends \Grepodata\Library\Router\BaseRoute
{
  // === \Index
  public static function NewKeyRequestGET()
  {
    die(self::OutputJson(array('deprecated' => true), 200));
  }
  public static function CleanupRequestGET()
  {
    die(self::OutputJson(array('deprecated' => true), 200));
  }
  public static function ResetIndexOwnersGET()
  {
    die(self::OutputJson(array('deprecated' => true), 200));
  }
  public static function ForgotKeysRequestGET()
  {
    die(self::OutputJson(array('deprecated' => true), 200));
  }
  public static function ConfirmActionGET()
  {
    die(self::OutputJson(array('deprecated' => true), 200));
  }
  public static function NewIndexV1GET()
  {
    die(self::OutputJson(array('deprecated' => true), 200));
  }
  public static function IsValidGET()
  {
    die(self::OutputJson(array('deprecated' => true), 200));
  }
  public static function GetIndexV1GET()
  {
    die(self::OutputJson(array('deprecated' => true), 200));
  }

  // === \Browse
  public static function GetTownGET()
  {
    die(self::OutputJson(array('deprecated' => true), 200));
  }
  public static function GetPlayerGET()
  {
    die(self::OutputJson(array('deprecated' => true), 200));
  }
  public static function GetAllianceGET()
  {
    die(self::OutputJson(array('deprecated' => true), 200));
  }

  // === \Owners
  public static function ResetOwnersGET()
  {
    die(self::OutputJson(array('deprecated' => true), 200));
  }
  public static function ExcludeAllianceGET()
  {
    die(self::OutputJson(array('deprecated' => true), 200));
  }
  public static function IncludeAllianceGET()
  {
    die(self::OutputJson(array('deprecated' => true), 200));
  }

  // === \IndexApi
  public static function DeleteGET()
  {
    die(self::OutputJson(array('deprecated' => true), 200));
  }
  public static function DeleteUndoGET()
  {
    die(self::OutputJson(array('deprecated' => true), 200));
  }
  public static function AddNoteGET()
  {
    die(self::OutputJson(array('deprecated' => true), 200));
  }
  public static function DeleteNoteGET()
  {
    die(self::OutputJson(array('deprecated' => true), 200));
  }

  // === \Report
  public static function LatestReportHashesGET()
  {
    //Logger::v2Migration("GetReportHashesV1");
    die(self::OutputJson(array(
      'i' => array(),
      'f' => array(),
      'deprecated' => true
    ), 200));
  }
  public static function AddReportFromInboxPOST()
  {
    die(self::OutputJson(array(), 200));
  }
  public static function AddReportFromForumPOST()
  {
    die(self::OutputJson(array(), 200));
  }

  // === \Reporting
  public static function BugReportDeprecatedPOST()
  {
    die(self::OutputJson(array('success' => true), 200));
  }

  // === \IndexApi (siege routes)
  public static function GetConquestReportsGET()
  {
    die(self::OutputJson(array('deprecated' => true), 200));
  }

  public static function GetSiegelistGET()
  {
    die(self::OutputJson(array('deprecated' => true), 200));
  }
}
