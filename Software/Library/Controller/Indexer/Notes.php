<?php

namespace Grepodata\Library\Controller\Indexer;

use Illuminate\Database\Eloquent\Collection;

class Notes
{

  /**
   * @param $Keys array list of Index identifiers
   * @param $Id int Town identifier
   * @return Collection|\Grepodata\Library\Model\Indexer\Notes[]
   */
  public static function allByTownIdByKeys($Keys, $Id)
  {
    return \Grepodata\Library\Model\Indexer\Notes::whereIn('index_key', $Keys, 'and')
      ->where('town_id', '=', $Id)
      ->orderBy('id', 'desc')
      ->get();
  }

}