<?php
file_put_contents(__DIR__ . "/daemon.pid", getmypid());
require __DIR__ . "/vendor/autoload.php";
require __DIR__ . "/config.php";
require __DIR__ . "/database.php";

date_default_timezone_set('Europe/Moscow');
$_ENV["asset_uid"] = uniqid();
//$DB = get_db_orm(__DIR__ . "/database_write.db");
$DB = get_db_orm(__DIR__ . "/database.db");


function _log($msg) {
  file_put_contents(__DIR__ . "/log.txt", $msg, FILE_APPEND);
}

/**
 * c_get_conn
 * Функция создаёт соединение до к базе couchdb и возвращает его
 *
 * @return conn
 */
function c_get_conn($dbname = null) {
  global $config;

  $transport = HeadCouchCurl::newInstance($config->couchdb->host, $config->couchdb->port)
    ->setUserName($config->couchdb->user)
    ->setPassword($config->couchdb->pass);

  if ($dbname) {
    $conn = HeadCouchDatabase::newInstance($transport, $dbname);
  } else {
    $conn = HeadCouchServer::newInstance($transport);
  }

  return $conn;
};


/**
 * c_objects
 * Функция позволяет принять данные из коллекции базы couchdb.
 * Могут быть установлены опции-ограничения.
 *
 * @param dbname обязательный, имя коллекции в базе
 * @param limit не обязательный, ограничения по количеству принимаемых данных
 * @param decode не обязательный, в каком виде принять данные, в stdClass или array
 *
 * @return rows
 */
function c_objects($dbname, $limit=null, $decode = true) {
  $conn = c_get_conn($dbname);
  $params = [
    "include_docs" => "true",
  ];

  if($limit) {
    $params["limit"] = $limit;
  };

  if ($decode === false) {
    $rows_raw = $conn->getAll(null, $params);
    return $rows_raw;
  }

  $rows_raw = json_decode($conn->getAll(null, $params));
  $rows = [];
  foreach($rows_raw->rows as $row) {
    $rows[] = $row->doc->data;
  }

  return $rows;
}

function c_row($dbname, $seq_id, $limit=1, $decode=false) {
  $conn = c_get_conn($dbname);
  $params = [
    "since" => $seq_id,
    "include_docs" => "true",
    "limit" => $limit,
  ];

  $row = json_decode($conn->changes($params), $decode);
  return $row;
}


function get_objects_state() {
  _log("get_objects_state\n");
  global $DB;
  $results = true;
  $ch_trigger = false;
  $_state = $DB->state()->fetch();

  if($_state) {
    $ch_counter_objects_state = $_state->ch_counter_objects_state;
    $last_seq_id = $_state->objects_state_seq_id;
  } else {
    $_state = $DB->createRow('state', [
      "objects_state_seq_id"     => 0,
      "ch_counter_objects_state" => 0,
      "objects_seq_id"           => 0,
      "ch_counter_objects"       => 0,
      "catalogs_seq_id"          => 0,
      "ch_counter_catalogs"      => 0,
    ]);

    $_state->save();
    $_state = $DB->state()->fetch();
    $ch_counter_objects_state = $_state->ch_counter_objects_state;
    $last_seq_id = $_state->objects_state_seq_id;
  }

  while ($results) {
    $row = c_row("objects_state", $last_seq_id);

    if (empty($row->results)) {
      $results = false;
      if (!empty($row->last_seq)) {
        $_state->update([
          "objects_state_seq_id" => $row->last_seq,
        ]);
        _log("OBJECTS_STATE LAST: " . $row->last_seq . "\n");
      }
    } else {
      $last_seq_id = $row->last_seq;
      _log("$last_seq_id\n");

      $_row = $row->results[0];

      if (isset($_row->doc)) {
        if (isset($_row->doc->data)) {
          $data = $_row->doc->data;

          if (!empty($data->number) && !empty($data->region_id) && !empty($data->state_id) && !empty($data->state)) {
            $number    = $data->number;
            $region_id = $data->region_id;
            $uid       = $number . "_" . $region_id;
            $state_id  = $data->state_id;
            $state     = $data->state;
            $osm_id    = $data->osm_id;

            $item = [
              "number"    => $number,
              "region_id" => $region_id,
              "osm_id"    => $osm_id,
              "state"     => $state,
              "state_id"  => $state_id,
              "has_device" => 1,
            ];

            $point = $DB->point()->where("uid", $uid)->fetch();
            $item["ch_counter_objects_state"] = $ch_counter_objects_state + 1;

            if ($point) {
              $part = [
                "state" => $state,
                "state_id" => $state_id,
                "has_device" => 1,
                "ch_counter_objects_state" => $ch_counter_objects_state + 1,
              ];
              $point->update($part);
            } else {
              $item["uid"] = $uid;
              $DB->createRow("point", $item)->save();
            }

            if ($ch_trigger === false) {
              $_state->update([
                "ch_counter_objects_state" => $ch_counter_objects_state + 1,
              ]);
              $ch_trigger = true;
            }
          }
        }
      }
    }
  }
}


function get_objects() {
  _log("get_objects\n");
  global $DB;
  $results = true;
  $ch_trigger = false;
  $_state = $DB->state()->fetch();

  if($_state) {
    $ch_counter_objects = $_state->ch_counter_objects;
    $last_seq_id = $_state->objects_seq_id;
  } else {
    $_state = $DB->createRow('state', [
      "objects_state_seq_id"     => 0,
      "ch_counter_objects_state" => 0,
      "objects_seq_id"           => 0,
      "ch_counter_objects"       => 0,
      "catalogs_seq_id"          => 0,
      "ch_counter_catalogs"      => 0,
    ]);

    $_state->save();
    $_state = $DB->state()->fetch();
    $ch_counter_objects = $_state->ch_counter_objects;
    $last_seq_id = $_state->objects_seq_id;
  }

  while ($results) {
    $row = c_row("objects", $last_seq_id);
    if (empty($row->last_seq)) {
      throw new Exception("!!!" . json_encode($row) . "!!!");
    }

    if (empty($row->results)) {
      $results = false;
      if (!empty($row->last_seq)) {
        $_state->update([
          "objects_seq_id" => $row->last_seq,
        ]);
        _log("OBJECTS LAST: " . $row->last_seq . "\n");
      }
    } else {
      $last_seq_id = $row->last_seq;
      _log("$last_seq_id\n");

      $_row = $row->results[0];

      if (isset($_row->doc)) {
        if (isset($_row->doc->data)) {
          $data = $_row->doc->data;

          if (!empty($data->number) && !empty($data->region_id) && !empty($data->name) && !empty($data->address_id)) {
            $number    = $data->number;
            $region_id = $data->region_id;
            $uid       = $number . "_" . $region_id;

            $name        = $data->name;
            $description = $data->description;
            $address_id  = $data->address_id;
            $dogovor     = $data->dogovor;

            $item = [
              "name"        => $name,
              "description" => $description,
              "address_id"  => $address_id,
              "dogovor"     => $dogovor,
            ];

            $point = $DB->point()->where("uid", $uid)->fetch();
            $item["ch_counter_objects"] = $ch_counter_objects;

            if ($point) {
              $item["has_object"] = 1;
              $point->update($item);
            }

            if ($ch_trigger === false) {
              $_state->update([
                "ch_counter_objects" => $ch_counter_objects + 1,
              ]);
              $ch_trigger = true;
            }
          }
        }
      }
    }
  }
}


function get_catalogs() {
  _log("get_catalogs\n");
  global $DB;
  $results = true;
  $ch_trigger = false;
  $_state = $DB->state()->fetch();

  if($_state) {
    $ch_counter_catalogs = $_state->ch_counter_catalogs;
    $last_seq_id = $_state->catalogs_seq_id;
  } else {
    $_state = $DB->createRow('state', [
      "objects_state_seq_id"     => 0,
      "ch_counter_objects_state" => 0,
      "objects_seq_id"           => 0,
      "ch_counter_objects"       => 0,
      "catalogs_seq_id"          => 0,
      "ch_counter_catalogs"      => 0,
    ]);

    $_state->save();
    $_state = $DB->state()->fetch();
    $ch_counter_catalogs = $_state->ch_counter_catalogs;
    $last_seq_id = $_state->catalogs_seq_id;
  }

  while ($results) {
    $row = c_row("catalogs", $last_seq_id);

    if (empty($row->results)) {
      $results = false;
      if (!empty($row->last_seq)) {
        $_state->update([
          "catalogs_seq_id" => $row->last_seq,
        ]);
        _log("CATALOGS LAST: " . $row->last_seq . "\n");
      }
    } else {
      $last_seq_id = $row->last_seq;
      _log("$last_seq_id\n");

      $_row = $row->results[0];

      if (isset($_row->doc)) {
        if (isset($_row->doc->data)) {
          $data = $_row->doc->data;

          if (!empty($data->id) && !empty($data->lat) && !empty($data->lon)) {
            $address_id = $data->id;
            $lat        = $data->lat;
            $lng        = $data->lon;
            $locality   = $data->locality;
            $street     = $data->street;
            $house      = $data->house;
            $region     = $data->region;
            $address    = $data->address;

            $item = [
              "lat"      => $lat,
              "lng"      => $lng,
              "locality" => $locality,
              "street"   => $street,
              "house"    => $house,
              "region"   => $region,
              "address"  => $address,
            ];

            $point = $DB->point()->where("address_id", $address_id)->fetch();
            $item["ch_counter_catalogs"] = $ch_counter_catalogs;

            if ($point) {
              $item["has_address"] = 1;
              $point->update($item);
            }

            if ($ch_trigger === false) {
              $_state->update([
                "ch_counter_catalogs" => $ch_counter_catalogs + 1,
              ]);
              $ch_trigger = true;
            }
          }
        }
      }
    }
  }
}

while (true) {
  get_objects_state();
  get_objects();
  get_catalogs();
  sleep(60);
}

