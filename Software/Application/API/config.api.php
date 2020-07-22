<?php

use Symfony\Component\Routing\Route;

$oRouter = \Grepodata\Library\Router\Service::GetInstance();

// AUTH
//Register
$oRouter->Add('register', new Route('/auth/register', array(
  '_controller' => '\Grepodata\Application\API\Route\Authentication',
  '_method'     => 'Register'
)));
$oRouter->Add('confirmMail', new Route('/auth/confirm', array(
  '_controller' => '\Grepodata\Application\API\Route\Authentication',
  '_method'     => 'ConfirmMail'
)));
$oRouter->Add('newConfirmMail', new Route('/auth/newconfirm', array(
  '_controller' => '\Grepodata\Application\API\Route\Authentication',
  '_method'     => 'RequestNewConfirmMail'
)));
//Verify
$oRouter->Add('verifytoken', new Route('/auth/token', array(
  '_controller' => '\Grepodata\Application\API\Route\Authentication',
  '_method'     => 'Verify'
)));
//Login
$oRouter->Add('login', new Route('/auth/login', array(
  '_controller' => '\Grepodata\Application\API\Route\Authentication',
  '_method'     => 'Login'
)));
//Forgot
$oRouter->Add('forgot', new Route('/auth/reset', array(
  '_controller' => '\Grepodata\Application\API\Route\Authentication',
  '_method'     => 'Forgot'
)));
//Reset password
$oRouter->Add('changepassword', new Route('/auth/changepassword', array(
  '_controller' => '\Grepodata\Application\API\Route\Authentication',
  '_method'     => 'ChangePassword'
)));


// PROFILE
//indexes
$oRouter->Add('profileIndexes', new Route('/profile/indexes', array(
  '_controller' => '\Grepodata\Application\API\Route\Profile',
  '_method'     => 'Indexes'
)));

// Scoreboard
$oRouter->Add('playerScoreboard', new Route('/scoreboard/player', array(
  '_controller' => '\Grepodata\Application\API\Route\Scoreboard',
  '_method'     => 'PlayerScoreboard'
)));
$oRouter->Add('playerDiffs', new Route('/player/diffs', array(
  '_controller' => '\Grepodata\Application\API\Route\Scoreboard',
  '_method'     => 'PlayerDiffs'
)));
$oRouter->Add('playerDiffsDay', new Route('/player/daydiffs', array(
  '_controller' => '\Grepodata\Application\API\Route\Scoreboard',
  '_method'     => 'PlayerDiffsByDay'
)));
$oRouter->Add('allianceDiffsDay', new Route('/alliance/daydiffs', array(
  '_controller' => '\Grepodata\Application\API\Route\Scoreboard',
  '_method'     => 'AllianceDiffsByDay'
)));
$oRouter->Add('playerDiffsHour', new Route('/scoreboard/hourdiffs', array(
  '_controller' => '\Grepodata\Application\API\Route\Scoreboard',
  '_method'     => 'PlayerDiffsByHour'
)));
$oRouter->Add('allianceScoreboard', new Route('/scoreboard/alliance', array(
  '_controller' => '\Grepodata\Application\API\Route\Scoreboard',
  '_method'     => 'AllianceScoreboard'
)));

// Active worlds
$oRouter->Add('activeWorlds', new Route('/world/active', array(
  '_controller' => '\Grepodata\Application\API\Route\World',
  '_method'     => 'ActiveWorlds'
)));
$oRouter->Add('worldAllianceChanges', new Route('/world/changes', array(
  '_controller' => '\Grepodata\Application\API\Route\World',
  '_method'     => 'AllianceChanges'
)));

// Player
$oRouter->Add('playerInfo', new Route('/player/info', array(
  '_controller' => '\Grepodata\Application\API\Route\Player',
  '_method'     => 'PlayerInfo'
)));
$oRouter->Add('playerHistory', new Route('/player/history', array(
  '_controller' => '\Grepodata\Application\API\Route\Player',
  '_method'     => 'PlayerHistory'
)));
$oRouter->Add('playerRangeHistory', new Route('/player/rangehistory', array(
  '_controller' => '\Grepodata\Application\API\Route\Player',
  '_method'     => 'PlayerHistoryRange'
)));
$oRouter->Add('playerSearch', new Route('/player/search', array(
  '_controller' => '\Grepodata\Application\API\Route\Player',
  '_method'     => 'Search'
)));
$oRouter->Add('playerChanges', new Route('/player/changes', array(
  '_controller' => '\Grepodata\Application\API\Route\Player',
  '_method'     => 'AllianceChanges'
)));

// Alliance
$oRouter->Add('allianceInfo', new Route('/alliance/info', array(
  '_controller' => '\Grepodata\Application\API\Route\Alliance',
  '_method'     => 'AllianceInfo'
)));
$oRouter->Add('allianceHistory', new Route('/alliance/history', array(
  '_controller' => '\Grepodata\Application\API\Route\Alliance',
  '_method'     => 'AllianceHistory'
)));
$oRouter->Add('allianceRangeHistory', new Route('/alliance/rangehistory', array(
  '_controller' => '\Grepodata\Application\API\Route\Alliance',
  '_method'     => 'AllianceHistoryRange'
)));
$oRouter->Add('allianceSearch', new Route('/alliance/search', array(
  '_controller' => '\Grepodata\Application\API\Route\Alliance',
  '_method'     => 'Search'
)));
$oRouter->Add('allianceMembers', new Route('/alliance/members', array(
  '_controller' => '\Grepodata\Application\API\Route\Alliance',
  '_method'     => 'AllianceMemberHistory'
)));
$oRouter->Add('allianceChanges', new Route('/alliance/changes', array(
  '_controller' => '\Grepodata\Application\API\Route\Alliance',
  '_method'     => 'AllianceChanges'
)));

// Conquest
$oRouter->Add('allConquests', new Route('/conquest', array(
  '_controller' => '\Grepodata\Application\API\Route\Conquest',
  '_method'     => 'AllConquests'
)));
//$oRouter->Add('allianceConquests', new Route('/conquest/alliance', array(
//  '_controller' => '\Grepodata\Application\API\Route\Conquest',
//  '_method'     => 'AllianceConquests'
//)));
//$oRouter->Add('townConquests', new Route('/conquest/town', array(
//  '_controller' => '\Grepodata\Application\API\Route\Conquest',
//  '_method'     => 'TownConquests'
//)));

// Message
$oRouter->Add('messageNew', new Route('/message/add', array(
  '_controller' => '\Grepodata\Application\API\Route\Message',
  '_method'     => 'AddMessage'
)));

// Discord
$oRouter->Add('setServerDiscord', new Route('/discord/set_server', array(
  '_controller' => '\Grepodata\Application\API\Route\Discord',
  '_method'     => 'SetServer'
)));
$oRouter->Add('setIndexDiscord', new Route('/discord/set_index', array(
  '_controller' => '\Grepodata\Application\API\Route\Discord',
  '_method'     => 'SetIndex'
)));
$oRouter->Add('getIndexDiscord', new Route('/discord/get_index', array(
  '_controller' => '\Grepodata\Application\API\Route\Discord',
  '_method'     => 'GetIndex'
)));
$oRouter->Add('getSettingsDiscord', new Route('/discord/guild_settings', array(
  '_controller' => '\Grepodata\Application\API\Route\Discord',
  '_method'     => 'GetSettings'
)));
$oRouter->Add('getReportByHash', new Route('/discord/hash', array(
  '_controller' => '\Grepodata\Application\API\Route\Discord',
  '_method'     => 'GetReportByHash'
)));

// Ranking
$oRouter->Add('playerRanking', new Route('/ranking/player', array(
  '_controller' => '\Grepodata\Application\API\Route\Ranking',
  '_method'     => 'PlayerRanking'
)));
$oRouter->Add('allianceRanking', new Route('/ranking/alliance', array(
  '_controller' => '\Grepodata\Application\API\Route\Ranking',
  '_method'     => 'AllianceRanking'
)));

// Towns
$oRouter->Add('playerTowns', new Route('/town/player', array(
  '_controller' => '\Grepodata\Application\API\Route\Town',
  '_method'     => 'PlayerTowns'
)));
//$oRouter->Add('allianceTowns', new Route('/town/alliance', array(
//  '_controller' => '\Grepodata\Application\API\Route\Town',
//  '_method'     => 'AllianceTowns'
//)));
//$oRouter->Add('TownDetails', new Route('/town/details', array(
//  '_controller' => '\Grepodata\Application\API\Route\Town',
//  '_method'     => 'TownDetails'
//)));
//$oRouter->Add('townSearch', new Route('/town/search', array(
//  '_controller' => '\Grepodata\Application\API\Route\Town',
//  '_method'     => 'Search'
//)));


// Indexer
$oRouter->Add('stats', new Route('/indexer/stats', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\Index',
  '_method'     => 'Stats'
)));
$oRouter->Add('isValid', new Route('/indexer/isvalid', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\Index',
  '_method'     => 'IsValid'
)));
$oRouter->Add('getIndex', new Route('/indexer/getindex', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\Index',
  '_method'     => 'GetIndex'
)));
$oRouter->Add('newIndex', new Route('/indexer/newindex', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\Index',
  '_method'     => 'NewIndex'
)));
$oRouter->Add('newKey', new Route('/indexer/newkey', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\Index',
  '_method'     => 'NewKeyRequest'
)));
$oRouter->Add('cleanupRequest', new Route('/indexer/cleanup', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\Index',
  '_method'     => 'CleanupRequest'
)));
$oRouter->Add('forgotKey', new Route('/indexer/forgotkeys', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\Index',
  '_method'     => 'ForgotKeysRequest'
)));
$oRouter->Add('confirmAction', new Route('/indexer/confirmaction', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\Index',
  '_method'     => 'ConfirmAction'
)));
$oRouter->Add('getWorlds', new Route('/indexer/worlds', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\Index',
  '_method'     => 'GetWorlds'
)));
$oRouter->Add('reportHashList', new Route('/indexer/getlatest', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\Report',
  '_method'     => 'LatestReportHashes'
)));
$oRouter->Add('addReportForum', new Route('/indexer/addreport', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\Report',
  '_method'     => 'AddReportFromForum'
)));
$oRouter->Add('addReportInbox', new Route('/indexer/inboxreport', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\Report',
  '_method'     => 'AddReportFromInbox'
)));
$oRouter->Add('getplayerintel', new Route('/indexer/player', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\Browse',
  '_method'     => 'GetPlayer'
)));
$oRouter->Add('getallianceintel', new Route('/indexer/alliance', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\Browse',
  '_method'     => 'GetAlliance'
)));
$oRouter->Add('gettownintel', new Route('/indexer/town', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\Browse',
  '_method'     => 'GetTown'
)));
$oRouter->Add('searchindexplayers', new Route('/indexer/search/player', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\Search',
  '_method'     => 'SearchPlayers'
)));
$oRouter->Add('searchindextowns', new Route('/indexer/search/town', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\Search',
  '_method'     => 'SearchTowns'
)));
$oRouter->Add('searchindexislands', new Route('/indexer/search/island', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\Search',
  '_method'     => 'SearchIslands'
)));
$oRouter->Add('indexownersinclude', new Route('/indexer/owner/include', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\Owners',
  '_method'     => 'IncludeAlliance'
)));
$oRouter->Add('indexownersexclude', new Route('/indexer/owner/exclude', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\Owners',
  '_method'     => 'ExcludeAlliance'
)));
$oRouter->Add('indexownersreset', new Route('/indexer/owner/reset', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\Owners',
  '_method'     => 'ResetOwners'
)));

// index API
$oRouter->Add('indexapitown', new Route('/indexer/api/town', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\IndexApi',
  '_method'     => 'GetTown'
)));
$oRouter->Add('indexapidelete', new Route('/indexer/delete', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\IndexApi',
  '_method'     => 'Delete'
)));
$oRouter->Add('indexapiundo', new Route('/indexer/undodelete', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\IndexApi',
  '_method'     => 'DeleteUndo'
)));
$oRouter->Add('indexaddnote', new Route('/indexer/addnote', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\IndexApi',
  '_method'     => 'AddNote'
)));
$oRouter->Add('indexdelnote', new Route('/indexer/delnote', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\IndexApi',
  '_method'     => 'DeleteNote'
)));
$oRouter->Add('indexunitinfo', new Route('/indexer/movementspeed', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\IndexApi',
  '_method'     => 'CalculateRuntime'
)));
$oRouter->Add('conquestreports', new Route('/indexer/conquest', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\IndexApi',
  '_method'     => 'GetConquestReports'
)));
$oRouter->Add('conquestsiegelist', new Route('/indexer/siegelist', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\IndexApi',
  '_method'     => 'GetSiegelist'
)));

// Reporting
$oRouter->Add('indexerbugreport', new Route('/indexer/scripterror', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\Reporting',
  '_method'     => 'BugReport'
)));

// old:
$oRouter->Add('resetOwners', new Route('/indexer/resetowners', array(
  '_controller' => '\Grepodata\Application\API\Route\Indexer\Index',
  '_method'     => 'ResetOwners'
)));

// google catpcha proxy
$oRouter->Add('captcha', new Route('/captcha', array(
  '_controller' => '\Grepodata\Application\API\Route\Captcha',
  '_method'     => 'Verify'
)));

// Town
$oRouter->Add('towninfo', new Route('/town', array(
  '_controller' => '\Grepodata\Application\API\Route\Town',
  '_method'     => 'GetTownInfo'
)));

// status
$oRouter->Add('analyticsindexer', new Route('/analytics/indexer', array(
  '_controller' => '\Grepodata\Application\API\Route\Status',
  '_method'     => 'IndexerUsage'
)));


/** TODO:
 * index: account creation
 * index: index deleting
 * index: index forking
 * index: index merging
 * index: allow grcrt reports (image recognition)
 */