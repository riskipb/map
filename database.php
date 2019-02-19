<?php
require __DIR__ . "/vendor/autoload.php";
require __DIR__ . "/config.php";

date_default_timezone_set('Europe/Moscow');

// sqlite3 database.db ".output ./database.db.dump" ".dump"

function check_schema_and_get_db($as_pdo=false, $db_file=null) {
  if (empty($db_file)) {
    $db_file = __DIR__ . "/database.db";
  }

  $db = new SQLite3($db_file);
  $db->exec("CREATE TABLE IF NOT EXISTS 'point'
    ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
     'uid' VARCHAR,
     'ch_counter_objects_state' INTEGER DEFAULT 0,
     'ch_counter_objects'       INTEGER DEFAULT 0,
     'ch_counter_catalogs'      INTEGER DEFAULT 0,
     'has_object'   INTEGER DEFAULT 0,
     'has_address'  INTEGER DEFAULT 0,
     'has_device'   INTEGER DEFAULT 0,
     'phone'        TEXT,
     'person'       VARCHAR,
     'class_fp'       VARCHAR,
     'class_fp_id'    INTEGER,
     'company'      VARCHAR,
     'company_id'   INTEGER,
     'department'     VARCHAR,
     'department_id'  INTEGER,
     'service'      VARCHAR,
     'service_id'   INTEGER,
     'services'     TEXT,
     'type'     VARCHAR,
     'type_id'  INTEGER,
     'type_financing' VARCHAR,
     'municipality'   VARCHAR,
     'link'       VARCHAR,
     'number'     INTEGER,
     'region'     VARCHAR,
     'region_id'  INTEGER,
     'osm_id'     INTEGER,
     'v01'        INTEGER DEFAULT 1,
     'state_id'   INTEGER,
     'state'      VARCHAR,
     'name'       VARCHAR,
     'description'  TEXT,
     'address_id'   INTEGER,
     'locality' VARCHAR,
     'street'   VARCHAR,
     'house'    VARCHAR,
     'address'  VARCHAR,
     'lat' VARCHAR,
     'lng' VARCHAR,
     'dogovor' INTEGER DEFAULT 0)");

  $db->exec("CREATE TABLE IF NOT EXISTS 'state'
    ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
     'objects_state_seq_id'     INTEGER DEFAULT 0,
     'ch_counter_objects_state' INTEGER DEFAULT 0,
     'objects_seq_id'           INTEGER DEFAULT 0,
     'ch_counter_objects'       INTEGER DEFAULT 0,
     'catalogs_seq_id'          INTEGER DEFAULT 0,
     'ch_counter_catalogs'      INTEGER DEFAULT 0)");

  $db->exec("CREATE TABLE IF NOT EXISTS 'company'
    ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
     'title'   VARCHAR,
     'lat'     VARCHAR,
     'lng'     VARCHAR,
     'phone'   VARCHAR,
     'site'    VARCHAR,
     'email'   VARCHAR,
     'address' VARCHAR,
     'person'  VARCHAR,
     'link'    VARCHAR)");

  $db->exec("CREATE TABLE IF NOT EXISTS 'list'
     ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
      'type'   VARCHAR,
      'type_a' VARCHAR,
      'type_b' VARCHAR,
      'type_c' VARCHAR,
      'value'   VARCHAR,
      'value_a' VARCHAR,
      'value_b' VARCHAR,
      'value_c' VARCHAR)");

  $db->exec("CREATE TABLE IF NOT EXISTS 'users'
     ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
      'login'      VARCHAR,
      'password'   VARCHAR,
      'isenabled'  INTEGER DEFAULT 0,
      'session'    VARCHAR,
      'session_dt' INTEGER,
      'auth_dt'    INTEGER,
      'created_dt' INTEGER,
      'role_id'    INTEGER DEFAULT 0,
      'fio'        VARCHAR,
      'email'      VARCHAR,
      'phone'      VARCHAR,
      'company_id' INTEGER)");

  $db->exec("CREATE TABLE IF NOT EXISTS 'roles'
     ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
      'name' VARCHAR)");

  $db->exec("CREATE TABLE IF NOT EXISTS 'pages'
     ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
      'name'    VARCHAR,
      'title'   VARCHAR,
      'content' TEXT,
      'views'   VARCHAR,
      'enabled' NUMERIC DEFAULT 0)");

  if ($as_pdo) {
    $db->close();
    return new \PDO("sqlite:" . $db_file);
  } else {
    return $db;
  }
}

function get_db_orm($db_file=null) {
  $db = new \LessQL\Database( check_schema_and_get_db(true, $db_file) );
  return $db;
}
