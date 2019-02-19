<?php
require __DIR__ . "/vendor/autoload.php";
require __DIR__ . "/config.php";
require __DIR__ . "/database.php";

date_default_timezone_set('Europe/Moscow');
$_ENV["asset_uid"] = uniqid();
//$DB = get_db_orm(__DIR__ . "/database_read.db");
$DB = get_db_orm(__DIR__ . "/database.db");
$MD = new Parsedown();
$ROLES = [
  "default"    => 0,
  "admin"      => 1,
  "superadmin" => 2,
];

ini_set("session.save_path", __DIR__ . "/tmp");
ini_set("session.use_cookies", 1);
ini_set("session.use_trans_sid", 0);
ini_set("session.cookie_httponly", 1);

if (session_status() !== 2) {
  session_start();
}


/**
 * Инициализация `fenom` шаблонизатора
 */
$fenom = new Fenom(new Fenom\Provider(__DIR__ . '/views'));
$fenom->setOptions([
  "force_compile" => true,
]);
$fenom->setCompileDir(__DIR__ . "/tmp");


/**
 * json_response
 * Функция ответа `http` сервера в виде `json`
 *
 * @return Flight::json
 */
function json_response($status, $data, $errors = [], $messages = [], $v = "") {
  Flight::json([
    "status"   => $status,
    "data"     => $data,
    "errors"   => $errors,
    "messages" => $messages,
    "v"        => $v,
  ]);
};


/**
 * html_response
 * Функция ответа `http` сервера в виде `html`
 *
 * @return html
 */
function html_response($layout, $data) {
  global $fenom;
  $html = $fenom->fetch($layout . ".tpl", $data);
  echo $html;
}


function gen_paginations($total_rows, $count, $page, $length) {
  $half = ceil($length / 2) - 1;
  $parts = ceil($total_rows / $count);

  $data = [
    "first" => 0,
    "prev"  => 0,
    "page"  => 0,
    "next"  => 0,
    "last"  => 0,
    "pages" => [],

    //"total_rows" => $total_rows,
    //"half"       => $half,
    //"parts"      => $parts,
  ];

  if ($total_rows == 0) {
    return new stdclass();
  }

  if ($total_rows <= $count) {
    return new stdclass();
  }

  $data["page"] = $page;
  $data["first"] = 1;
  $data["last"] = $parts;

  if ($page == 1) {
    $data["prev"] = 1;
  } else if ($page > 1 && $page <= $parts) {
    $data["prev"] = $page - 1;
  }

  if ($page < $parts) {
    $data["next"] = $page + 1;
  } else if ($page = $parts) {
    $data["next"] = $page;
  }

  if ($page == 1 || $page <= $half) {
    if ($length <= $parts) {
      $iter = $length;
    } else if ($length > $parts) {
      $iter = $parts;
    }

    for ($i=1; $i<=$iter; $i++) {
      $data["pages"][] = $i;
    }
  } else {
    $half_right = $parts - $half;

    if ($page <= $half_right) {
      $index = $page - $half;
      $iter = $page + $half;

      for ($i=$index; $i<=$iter; $i++) {
        $data["pages"][] = $i;
      }
    } else {
      if ($parts > $length) {
        $index = $parts - $length + 1;

        for ($i=$index; $i<=$parts; $i++) {
          $data["pages"][] = $i;
        }
      } else {
        for ($i=1; $i<=$parts; $i++) {
          $data["pages"][] = $i;
        }
      }
    }
  }

  return $data;
}


/**
 * balloonContentHeaderGenerator
 * Функция генерации html контента для balloonContentHeader
 *
 * @return html
 */
function balloonContentHeaderGenerator($row) {
  $html = [];
  if ($row->state_id === "1") {
    $html[] = "<div style=\"color:black; padding:5px; background-color:#56db40;\">" . $row->name . "</div>";
  }
  if ($row->state_id === "2") {
    $html[] = "<div style=\"color:black; padding:5px; background-color:yellow;\">" . $row->name . "</div>";
  }
  if ($row->state_id === "3") {
    $html[] = "<div style=\"color:black; padding:5px; background-color:#ed4543;\">" . $row->name . "</div>";
  }

  return join($html, "");
}


/**
 * balloonContentBodyGenerator
 * Функция генерации html контента для balloonContentBody
 *
 * @return html
 */
function balloonContentBodyGenerator($row) {
  $html = [
    "<p>" . $row->address . "</p>",
    "<p>датчик: " . $row->number . "</p>",
    "<p>" . $row->description . "</p>",
    "<a href=\"#!\" data-action=\"show card\" data-uid=\"\"><p nc>показать карточку объекта</p></a>",
  ];

  return join($html, "");
}


function presetGenerator($row) {
  if ($row->state_id === "1") {
    $text = "islands#greenCircleDotIcon";
  }
  if ($row->state_id === "2") {
    $text = "islands#yellowCircleDotIcon";
  }
  if ($row->state_id === "3") {
    $text = "islands#redCircleDotIcon";
  }

  return $text;
}

function presetImgGenerator($row, $check_dogovor=false) {
  if ($row->state_id === "1") {
    $text = "/assets/img/green.png";
  }

  if ($row->state_id === "2") {
    $text = "/assets/img/yellow.png";
  }

  if ($row->state_id === "3") {
    $text = "/assets/img/red.png";
  }

  if ($check_dogovor) {
    if ($row->dogovor === "0") {
      $text = "/assets/img/gray.png";
    }
  }

  if ($row->iscompany === "1") {
    $text = "/assets/img/blue.png";
  }

  return $text;
}


function rowObjectGenerator($row, $check_dogovor=false, $without_state=false, $without_iscompany=false) {
  $_row = [
    "type" => "Feature",
    "id" => $row->id,
    "geometry" => [
      "type" => "Point",
      "coordinates" => [
        floatval($row->lat),
        floatval($row->lng),
      ],
    ],
    "properties" => [
      //"balloonContentHeader" => balloonContentHeaderGenerator($row),
      //"balloonContentBody" => balloonContentBodyGenerator($row),
      //"state_id"    => $row->state_id,
      "hintContent"   => $row->number . "<br>" . $row->name . "<br>" . $row->address,
      "number"        => $row->number,
      "region_id"     => $row->region_id,
      "dogovor"       => $row->dogovor,
      "services"      => json_decode($row->services, true),
      "department_id" => $row->department_id,
      "company_id"    => $row->company_id,
      "class_fp_id"   => $row->class_fp_id,
      "type_id"       => $row->type_id,
    ],
    "options" => [
      //"preset" => presetGenerator($row),
      //"hideIconOnBalloonOpen" => false,
      "iconLayout"      => "default#image",
      "iconImageHref"   => presetImgGenerator($row, $check_dogovor),
      "iconImageSize"   => [18, 18],
      "iconImageOffset" => [-9, -10],
    ],
  ];

  if ($without_state === false) {
    $_row["properties"]["state_id"] = $row->state_id;
  } else {
    $_row["properties"]["state_id"] = "*";
  }

  if ($without_iscompany === false) {
    $_row["properties"]["iscompany"] = false;
  } else {
    $_row["properties"]["iscompany"] = "*";
  }

  return $_row;
}


function rowCompanyGenerator($row) {
  $_row = [
    "type" => "Feature",
    "id" => $row->id,
    "geometry" => [
      "type" => "Point",
      "coordinates" => [
        floatval($row->lat),
        floatval($row->lng),
      ]
    ],
    "properties" => [
      "hintContent"   => $row->title,
      "number"        => "*",
      "region_id"     => "*",
      "dogovor"       => "*",
      "services"      => [],
      "department_id" => "*",
      "company_id"    => "*",
      "class_fp_id"   => "*",
      "type_id"       => "*",
      "state_id"      => "*",
      "iscompany"     => true,
    ],
    "options" => [
      //"preset" => "islands#blueCircleDotIcon",
      //"hideIconOnBalloonOpen" => false,
      "iconLayout"      => "default#image",
      "iconImageHref"   => "/assets/img/blue.png",
      "iconImageSize"   => [18, 18],
      "iconImageOffset" => [-9, -10],
    ],
  ];

  return $_row;
}


function check_auth() {
  global $DB;

  $sid    = null;
  $user   = null;
  $actual = false;

  if (isset($_COOKIE["PHPSESSID"])) {
    $sid = $_COOKIE["PHPSESSID"];
  }

  if ($sid) {
    $user = $DB->users()->where("session", $sid)->fetch();
  }

  if ($user) {
    $time_now = new DateTime();
    $time_now->modify("-30 minutes");
    $time_stamp = $time_now->getTimestamp();
    $session_time = intval($user->session_dt);

    if ($session_time > $time_stamp) {
      $actual = true;
      $user->session_dt = (new DateTime())->getTimestamp();
      $user->save();
    } else {
      $actual = false;
      $user->session = null;
      $user->session_dt = null;
      $user->save();
    }
  }

  return [$actual, $user];
}


function check_enabled_user($user) {
  if ($user->isenabled) {
    return true;
  } else {
    return false;
  }
}


function check_role($user, $role) {
  global $DB;
  global $ROLES;

  $result = false;
  $user_role = intval($user->role_id);

  if (array_key_exists($role, $ROLES)) {
    if ($user_role >= $ROLES[$role]) {
      $result = true;
    }
  }

  return $result;
}


function preset_role($user) {
  switch ($user->role_id) {
  case "0":
    $user->role = "пользователь";
    break;

  case "1":
    $user->role = "администратор";
    break;

  case "2":
    $user->role = "супер администратор";
    break;

  }

  return $user;
}


function preset_company($user) {
  global $DB;
  if ($user->company_id) {
    $company = $DB->company()->where("id", $user->company_id)->fetch();
    if ($company) {
      return $company->title;
    } else {
      return null;
    }
  } else {
    return null;
  }
}


function response_404() {
  global $DB;
  global $MD;

  Flight::response()->status(404);
  $page_404 = $DB->pages()->where("name", "404")->fetch();

  $data = [];

  if ($page_404) {
    $data["view"] = "page";
    $data["page"] = $page_404;
    $data["MD"] = $MD;
  } else {
    $data["view"] = "404";
    $data["page"] = [
      "title" => "404",
      "content" => "страница не найдена",
    ];
    $data["MD"] = $MD;
  }

  html_response("layout", $data);
}


/**
 * Flight settings
 */

Flight::set('flight.log_errors', true);


/**
 * Роутинг `http` сервера
 */
Flight::route('GET /', function() {
  global $config;

  html_response("layout", [
    "view" => "index",
    "yanmapapi" => $config->yanmapapi,
  ]);
});


Flight::route('GET /data', function() {
  global $DB;
  $limit = 10;

  $rows_state_1 = $DB->point()->where(["has_object" => 1, "has_address" => 1, "has_device" => 1, "dogovor" => 1, "state_id" => 1,])->select(
    "id", "name", "number", "region_id", "state_id", "description", "address", "lat", "lng", "dogovor", "services", "department_id", "company_id", "class_fp_id", "type_id"
  )->limit($limit)->fetchAll();

  $rows_state_2 = $DB->point()->where(["has_object" => 1, "has_address" => 1, "has_device" => 1, "dogovor" => 1, "state_id" => 2,])->select(
    "id", "name", "number", "region_id", "state_id", "description", "address", "lat", "lng", "dogovor", "services", "department_id", "company_id", "class_fp_id", "type_id"
  )->limit($limit)->fetchAll();

  $rows_state_3 = $DB->point()->where(["has_object" => 1, "has_address" => 1, "has_device" => 1, "dogovor" => 1, "state_id" => 3,])->select(
    "id", "name", "number", "region_id", "state_id", "description", "address", "lat", "lng", "dogovor", "services", "department_id", "company_id", "class_fp_id", "type_id"
  )->limit($limit)->fetchAll();

  $rows = [
    "state_1" => [
      "type" => "FeatureCollection",
      "features" => [],
    ],
    "state_2" => [
      "type" => "FeatureCollection",
      "features" => [],
    ],
    "state_3" => [
      "type" => "FeatureCollection",
      "features" => [],
    ],
    "stats" => [],
  ];

  forEach($rows_state_1 as $row) {
    $rows["state_1"]["features"][] = rowObjectGenerator($row);
  }
  $rows["stats"]["1"] = count($rows_state_1);

  forEach($rows_state_2 as $row) {
    $rows["state_2"]["features"][] = rowObjectGenerator($row);
  }
  $rows["stats"]["2"] = count($rows_state_2);

  forEach($rows_state_3 as $row) {
    $rows["state_3"]["features"][] = rowObjectGenerator($row);
  }
  $rows["stats"]["3"] = count($rows_state_3);

  $rows["ch_counter_objects_state"] = $DB->state()->fetch()->ch_counter_objects_state;

  json_response(true, [
    "rows" => $rows,
  ]);
});


Flight::route('GET /data/@type/@last', function($type, $last) {
  global $DB;
  $data = [];

  $rows = [
    "type" => "FeatureCollection",
    "features" => [],
  ];

  switch ($type) {
  case "objects_state":
    $items = $DB->point()->where("ch_counter_objects_state > ?", $last)->select(
      "id", "name", "number", "region_id", "state_id", "description", "address", "lat", "lng"
    )->fetchAll();

    foreach($items as $row) {
      $rows["features"][] = rowObjectGenerator($row);
    }
    break;

  case "objects":
    $items = $DB->point()->where("ch_counter_objects > ?", $last)->select(
      "id", "name", "number", "region_id", "state_id", "description", "address", "lat", "lng"
    )->fetchAll();

    foreach($items as $row) {
      $rows["features"][] = rowObjectGenerator($row);
    }
    break;

  case "catalogs":
    $items = $DB->point()->where("catalogs > ?", $last)->select(
      "id", "name", "number", "region_id", "state_id", "description", "address", "lat", "lng"
    )->fetchAll();

    foreach($items as $row) {
      $rows["features"][] = rowObjectGenerator($row);
    }
    break;
  }

  $data["rows"] = $rows;
  $state = $DB->state()->select(
    'id', 'ch_counter_objects_state', 'ch_counter_objects', 'ch_counter_catalogs'
  )->fetch();

  $data["ch_counter_objects_state"] = $state->ch_counter_objects_state;

  json_response(true, $data);
});


Flight::route('GET /getDataById/@id', function($id) {
  global $DB;

  $row = $DB->point()->where(["id" => $id])->fetch();
  if ($row->state_id === "1") {
    $row->state = "на связи";
    $row->v01 = 1;
  } else if ($row->state_id === "2") {
    $row->state = "не исправен";
    $row->v01 = 1;
  } else if ($row->state_id === "3") {
    $row->state = "нет на связи";
    $row->v01 = 0;
  }

  json_response(true, $row);
});


Flight::route('GET /companies', function() {
  global $DB;

  $_rows = $DB->company()->fetchAll();

  $rows = [
    "type" => "FeatureCollection",
    "features" => [],
  ];

  foreach($_rows as $row) {
    $rows["features"][] = rowCompanyGenerator($row);
  }

  json_response(true, [
    "rows" => $rows,
  ]);
});


Flight::route('GET /dogovors', function() {
  global $DB;
  $limit = 10;

  $_rows = $DB->point()->where(["has_object" => 1, "has_address" => 1, "has_device" => 1, "dogovor" => 0,])->select(
    "id", "name", "number", "region_id", "state_id", "description", "address", "lat", "lng", "dogovor", "services", "department_id", "company_id", "class_fp_id", "type_id"
  )->limit($limit)->fetchAll();

  $rows = [
    "type" => "FeatureCollection",
    "features" => [],
  ];

  foreach($_rows as $row) {
    $rows["features"][] = rowObjectGenerator($row, true, true, true);
  }

  json_response(true, [
    "rows" => $rows,
  ]);
});



Flight::route('GET /stats', function() {
  global $DB;

  $data = [
    [
      "name" => "Всего датчиков",
      "value" => $DB->point()->count(),
    ],
    [
      "name" => "Всего датчиков с описания",
      "value" => $DB->point()->where(["has_object" => 1])->count(),
    ],
    [
      "name" => "Всего датчиков с описанием и местоположением",
      "value" => $DB->point()->where(["has_object" => 1, "has_address" => 1])->count(),
    ],
    [
      "name" => "Всего датчиков с состоянием АПС - 1",
      "value" => $DB->point()->where(["has_object" => 1, "has_address" => 1, "state_id" => 1])->count(),
    ],
    [
      "name" => "Всего датчиков с состоянием АПС - 2",
      "value" => $DB->point()->where(["has_object" => 1, "has_address" => 1, "state_id" => 2])->count(),
    ],
    [
      "name" => "Всего датчиков с состоянием АПС - 3",
      "value" => $DB->point()->where(["has_object" => 1, "has_address" => 1, "state_id" => 3])->count(),
    ],
    [
      "name" => "Всего компаний",
      "value" => $DB->company()->count(),
    ],
  ];

  json_response(true, $data);
});


Flight::route('GET /filters', function() {
  global $DB;

  $data = [];
  $_regions = $DB->list()->where(["type" => "region"])->select(
    "id", "value", "value_a"
  )->fetchAll();

  $_numbers = $DB->point()->where(["has_device" => 1, "has_object" => 1, "has_address" => 1])->orderBy("number")->select(
    "id", "number", "region_id"
  )->fetchAll();

  $regions = [];
  foreach($_regions as $region) {
    $regions[trim($region->value)] = $region->value_a;
  }
  ksort($regions);

  $numbers = [];
  foreach($_numbers as $number) {
    $numbers[] = [
      "number" => $number->number,
      "region_id" => $number->region_id,
    ];
  }

  $data["regions"] = $regions;
  $data["numbers"] = $numbers;

  $_companies = $DB->company()->select('id', 'title')->fetchAll();
  foreach($_companies as $company) {
    $data["companies"][$company->id] = $company->title;
  }

  $_class_fps = $DB->list()->where(["type" => "class_fp"])->select("id", "value")->fetchAll();
  foreach($_class_fps as $fps) {
    $data["class_fps"][$fps->id] = $fps->value;
  }

  $_departments = $DB->list()->where(["type" => "department"])->select("id", "value")->fetchAll();
  foreach($_departments as $department) {
    $data["departments"][$department->id] = $department->value;
  }

  $_types = $DB->list()->where(["type" => "type"])->select("id", "value")->fetchAll();
  foreach($_types as $type) {
    $data["types"][$type->id] = $type->value;
  }

  $_services = $DB->list()->where(["type" => "service"])->select("id", "value")->fetchAll();
  foreach($_services as $service) {
    $data["services"][$service->id] = $service->value;
  }

  json_response(true, $data);
});


Flight::route('POST /templates', function() {
  global $DB;

  $data = [
    "vue_tools"  => file_get_contents(__DIR__ . "/views/vue_tools.tpl"),
    "vue_auth"   => file_get_contents(__DIR__ . "/views/vue_auth.tpl"),
    "vue_panel"  => file_get_contents(__DIR__ . "/views/vue_panel.tpl"),
    "vue_filter" => file_get_contents(__DIR__ . "/views/vue_filter.tpl"),
  ];

  json_response(true, $data);
});


Flight::route('POST /auth/login', function() {
  global $DB;

  $params       = Flight::request()->data->getData();
  $has_login    = false;
  $has_password = false;
  $auth         = false;
  $user         = null;
  $user_        = new stdclass();
  $isenabled    = false;
  $errors       = [];

  if (isset($params["login"])) {
    if (!empty($params["login"])) {
      if (strlen($params["login"]) <= 32) {
        $has_login = true;
      } else {
        $errors[] = "login is very long";
      }
    } else {
      $errors[] = "login is empty";
    }
  } else {
    $errors[] = "login is not set";
  }

  if (isset($params["password"])) {
    if (!empty($params["password"])) {
      if (strlen($params["password"]) <= 32) {
        $has_password = true;
      } else {
        $errors[] = "password is very long";
      }
    } else {
      $errors[] = "password is empty";
    }
  } else {
    $errors[] = "password is not set";
  }

  if ($has_login && $has_password) {
    $user = $DB->users()->where("login", $params["login"])->fetch();
  } else {
    $errors[] = "login or password is not valide";
  }

  if ($user && $user->isenabled) {
    $isenabled = true;
  } else {
    $errors[] = "user not activated";
  }

  if ($user && $isenabled) {
    $password_get = $params["password"];
    $password_hash = $user->password;
    $auth = password_verify($password_get, $password_hash);
  } else {
    $errors[] = "user can't be found";
  }

  if ($user && $auth === true) {
    $dt = (new DateTime())->getTimestamp();
    $user->session = session_id();
    $user->session_dt = $dt;
    $user->auth_dt = $dt;
    $user->save();

    $user_->id = $user->id;
    $user_->login = $user->login;
    $user_->role_id = $user->role_id;
    $user_ = preset_role($user_);
    $user_->company_id = $user->company_id;
    $user_->company = preset_company($user_);
  }

  if ($user && $auth === false) {
    $user->session = null;
    $user->session_dt = null;
    $user->save();
    $errors[] = "user is not authenticated";
  }

  $data = [
    "auth"         => $auth,
    "has_login"    => $has_login,
    "has_password" => $has_password,
    "user"         => $user_,
    "errors"       => $errors,
  ];

  json_response($auth, $data);
});


Flight::route('POST /auth/logout', function() {
  global $DB;

  $user = null;
  $user_ = new stdclass();
  $logout = false;

  [$check, $user] = check_auth();

  if ($check === false) {
    json_response($logout, [
      "msg" => "not authenticated",
      "code" => 1,
    ]);

    return;
  }

  if ($user) {
    $user->session = null;
    $user->session_dt = null;
    $user->save();

    $user_->id = $user->id;
    $user_->login = $user->login;
    $user_->role_id = $user->role_id;
    $user_ = preset_role($user_);
    $user_->company_id = $user->company_id;
    $user_->company = preset_company($user_);

    $logout = true;
  }

  json_response($logout, $user_);
});


Flight::route('POST /auth/check', function() {
  global $DB;

  $check = null;
  $user_ = new stdclass();

  [$check, $user] = check_auth();
  if ($user) {
    $user_->id         = $user->id;
    $user_->login      = $user->login;
    $user_->role_id    = $user->role_id;
    $user_->company_id = $user->company_id;
    $user_             = preset_role($user_);
    $user_->company    = preset_company($user_);
  }

  json_response($check, $user_);
});


Flight::route('POST /auth/reg', function() {
  global $DB;

  $params = Flight::request()->data->getData();
  $has_login = false;
  $has_password = false;
  $has_password1 = false;
  $has_password2 = false;
  $errors = [];
  $created = false;
  $user = null;

  if (isset($params["login"])) {
    if (!empty($params["login"])) {
      if (strlen($params["login"]) <= 32) {
        $has_login = true;
      } else {
        $errors[] = "login is very long";
      }
    } else {
      $errors[] = "login is empty";
    }
  } else {
    $errors[] = "login is not set";
  }

  if (isset($params["password1"])) {
    if (!empty($params["password1"])) {
      if (strlen($params["password1"]) <= 32) {
        $has_password1 = true;
      } else {
        $errors[] = "password 1 is very long";
      }
    } else {
      $errors[] = "password 1 is empty";
    }
  } else {
    $errors[] = "password 1 is not set";
  }

  if (isset($params["password2"])) {
    if (!empty($params["password2"])) {
      if (strlen($params["password2"]) <= 32) {
        $has_password2 = true;
      } else {
        $errors[] = "password 2 is very long";
      }
    } else {
      $errors[] = "password 2 is empty";
    }
  } else {
    $errors[] = "password 2 is not set";
  }

  if ($has_password1 && $has_password2) {
    if ($params["password1"] === $params["password2"]) {
      $has_password = true;
    } else {
      $errors[] = "password not correct, please try again";
    }
  }

  if ($has_login && $has_password) {
    $user = $DB->users()->where("login", $params["login"])->fetch();
    if ($user) {
      $errors[] = "user already created";
    } else {
      $user = $DB->createRow('users', [
        "login" => $params["login"],
        "password" => password_hash($params["password1"], PASSWORD_DEFAULT),
      ]);
      $user->save();
      $created = true;
    }
  } else {
    $errors[] = "user can't be created";
  }

  $data = [
    "created" => $created,
    "has_login" => $has_login,
    "has_password" => $has_password,
    "user" => $user,
    "errors" => $errors,
  ];

  json_response($created, $data);
});


Flight::route('POST /api', function() {
  global $DB;

  $status = false;
  $response = [];
  $errors = [];
  $messages = [];
  $v = "noname";

  [$check, $user] = check_auth();

  if ($check === false) {
    json_response($check, [
      "msg" => "not authenticated",
      "code" => 1,
    ]);

    return;
  }

  $params = Flight::request()->data->getData();

  if (!isset($params["action"])) {
    json_response(false, [
      "errors" => [
        "action must be setup"
      ],
    ]);

    return;
  }

  switch ($params["action"]) {
  case "getdata":
    switch ($params["from"]) {
    case "objects": //getdata
      $cr = check_role($user, "default");
      if ($cr === false) {json_response($cr, ["msg" => "not access",]); return;}
      $ce = check_enabled_user($user);
      if ($ce === false) {json_response($ce, ["msg" => "not access",]); return;}

      $helpers = [];
      $page = $params["page"];
      $pagination_count = 50;

      $offset_count = ($params["page"] - 1) * $pagination_count;

      if (check_role($user, "admin")) {
        $objects = $DB->point()->select(
          "id", "number", "region", "region_id", "name", "has_object", "has_address", "has_device", "company", "company_id", "dogovor", "state_id"
        )->limit($pagination_count, $offset_count)->fetchAll();

        $objects_count = $DB->point()->select("id")->fetchAll();

      } else if (check_role($user, "default")) {
        if ($user->company_id) {
          $objects = $DB->point()->where("company_id", $user->company_id)->select(
            "id", "number", "region", "region_id", "name", "has_object", "has_address", "has_device", "company", "company_id", "dogovor", "state_id"
          )->limit($pagination_count, $offset_count)->fetchAll();

          $objects_count = $DB->point()->where("company_id", $user->company_id)->select("id")->fetchAll();

        } else {
          $objects = [];
        }
      }

      $paginations = gen_paginations(
        count($objects_count), $pagination_count, $page, 11
      );

      foreach ($objects as $object) {
        $region_id = $object->region_id;
        $region = $DB->list()->where(["type" => "region", "id" => $region_id])->fetch();

        $object->region = $region->value_a;

        $object->has_object   = boolval($object->has_object);
        $object->has_address  = boolval($object->has_address);
        $object->has_device   = boolval($object->has_device);
        $object->dogovor      = boolval($object->dogovor);
      }

      $_regions = $DB->list()->where("type", "region")->select("id", "value", "value_a")->fetchAll();
      $regions = [];
      foreach ($_regions as $region) {
        $id = $region->value;
        $name = $region->value_a;
        $regions[$id] = $name;
      }
      $helpers["regions"] = $regions;

      $_companies = $DB->company()->select("id", "title")->fetchAll();
      $companies = [];
      foreach ($_companies as $company) {
        $id = $company->id;
        $name = $company->title;
        $companies[$id] = $name;
      }
      $helpers["companies"] = $companies;

      $status = true;
      $response = [
        "rows" => $objects,
        "helpers" => $helpers,
        "paginations" => $paginations,
      ];
      break;

    case "users": //getdata
      $cr = check_role($user, "default");
      if ($cr === false) {json_response($cr, ["msg" => "not access",]); return;}
      $ce = check_enabled_user($user);
      if ($ce === false) {json_response($ce, ["msg" => "not access",]); return;}

      if (check_role($user, "admin")) {
        $users = $DB->users()->select("id", "fio", "login", "email", "role_id", "isenabled")->fetchAll();
      } else if (check_role($user, "default")) {
        $users = $DB->users()->where("id", $user->id)->select("id", "fio", "login", "email", "role_id", "isenabled")->fetchAll();
      }

      foreach ($users as $index=>$user_) {
        $user_->isenabled = boolval($user_->isenabled);
        $user_ = preset_role($user_);
        $users[$index] = $user_;
      }

      $status = true;
      $response = $users;
      break;

    case "companies": //getdata
      $cr = check_role($user, "default");
      if ($cr === false) {json_response($cr, ["msg" => "not access",]); return;}
      $ce = check_enabled_user($user);
      if ($ce === false) {json_response($ce, ["msg" => "not access",]); return;}

      if (check_role($user, "admin")) {
        $companies = $DB->company()->fetchAll();
      } else if (check_role($user, "default")) {
        if ($user->company_id) {
          $companies = $DB->company()->where("id", $user->company_id)->fetchAll();
        } else {
          $companies = [];
        }
      }

      foreach ($companies as $company) {
        $_user = $DB->users()->where("company_id", $company->id)->fetch();
        if ($_user) {
          $company->user = $_user->login;
          $company->user_id = $_user->id;
        } else {
          $company->user = null;
          $company->user_id = null;
        }
        if (!empty($company->lat) && !empty($company->lng)) {
          $company->has_address = true;
        } else {
          $company->has_address = false;
        }
      }

      $status = true;
      $response = $companies;
      break;

    case "pages": //getdata
      $cr = check_role($user, "default");
      if ($cr === false) {json_response($cr, ["msg" => "not access",]); return;}
      $ce = check_enabled_user($user);
      if ($ce === false) {json_response($ce, ["msg" => "not access",]); return;}

      $pages = [];

      if (check_role($user, "admin")) {
        $_pages = $DB->pages()->fetchAll();

        foreach($_pages as $page) {
          $page["enabled"] = boolval($page["enabled"]);
          $pages[] = $page;
        }
      }

      $status = true;
      $response = $pages;
      break;

    case "lists": // getdata
      $cr = check_role($user, "default");
      if ($cr === false) {json_response($cr, ["msg" => "not access",]); return;}
      $ce = check_enabled_user($user);
      if ($ce === false) {json_response($ce, ["msg" => "not access",]); return;}

      $data = [];
      $_class_fps = $DB->list()->where(["type" => "class_fp"])->select("id", "value")->fetchAll();
      foreach($_class_fps as $fps) {
        $data["class_fps"][$fps->id] = $fps->value;
      }

      $_departments = $DB->list()->where(["type" => "department"])->select("id", "value")->fetchAll();
      foreach($_departments as $department) {
        $data["departments"][$department->id] = $department->value;
      }

      $_types = $DB->list()->where(["type" => "type"])->select("id", "value")->fetchAll();
      foreach($_types as $type) {
        $data["types"][$type->id] = $type->value;
      }

      $_services = $DB->list()->where(["type" => "service"])->select("id", "value")->fetchAll();
      foreach($_services as $service) {
        $data["services"][$service->id] = $service->value;
      }

      $status = true;
      $response = $data;
      break;

    case "user": //getdata
      $cr = check_role($user, "default");
      if ($cr === false) {json_response($cr, ["msg" => "not access",]); return;}
      $ce = check_enabled_user($user);
      if ($ce === false) {json_response($ce, ["msg" => "not access",]); return;}

      $helpers = [];
      $user_ = $DB->users()->where("id", $params["id"])->select("id", "login", "isenabled", "role_id", "fio", "email", "phone", "company_id")->fetch();

      if ($user->role_id == 1) {
        $helpers["roles"] = [
          "0" => "пользователь",
          "1" => "администратор",
        ];

        $companies = [];
        $companies_ = $DB->company()->select("id", "title")->fetchAll();
        foreach ($companies_ as $company) {
          $cid = $company->id;
          $companies[$cid] = $company->title;
        }
        $helpers["companies"] = $companies;
      }

      if ($user_) {
        $user_->isenabled = boolval($user_->isenabled);
        $user_ = preset_role($user_);
        $user_->company = preset_company($user_);
        $user_->helpers = $helpers;
        $response = $user_;
        $status = true;
      } else {
        $status = false;
      }
      break;

    case "page": //getdata
      $cr = check_role($user, "default");
      if ($cr === false) {json_response($cr, ["msg" => "not access",]); return;}
      $ce = check_enabled_user($user);
      if ($ce === false) {json_response($ce, ["msg" => "not access",]); return;}

      $page = $DB->pages()->where("id", $params["id"])->fetch();

      if ($page) {
        $page->enabled = boolval($page->enabled);
        $status = true;
      } else {
        $status = false;
      }

      $response = $page;
      break;

    case "object": //getdata
      $cr = check_role($user, "default");
      if ($cr === false) {json_response($cr, ["msg" => "not access",]); return;}
      $ce = check_enabled_user($user);
      if ($ce === false) {json_response($ce, ["msg" => "not access",]); return;}

      //$object = $DB->point()->where("id", $params["id"])->fetch();
      if (check_role($user, "admin")) {
        $object = $DB->point()->where("id", $params["id"])->fetch();
      } else if (check_role($user, "default")) {
        if ($user->company_id) {
          $object = $DB->point()->where(["id" => $params["id"], "company_id" => $user->company_id])->fetch();
        } else {
          $object = null;
        }
      }

      if ($object) {
        $object->has_object  = boolval($object->has_object);
        $object->has_address = boolval($object->has_address);
        $object->has_device  = boolval($object->has_device);
        $object->dogovor     = boolval($object->dogovor);

        $status = true;
      } else {
        $status = false;
        $errors[] = "объект не найден";
      }

      $response = $object;
      break;

    case "company":
      $cr = check_role($user, "default");
      if ($cr === false) {json_response($cr, ["msg" => "not access",]); return;}
      $ce = check_enabled_user($user);
      if ($ce === false) {json_response($ce, ["msg" => "not access",]); return;}

      if (check_role($user, "admin")) {
        $company = $DB->company()->where("id", $params["id"])->fetch();
      } else if (check_role($user, "default")) {
        if ($user->company_id) {
          $company = $DB->company()->where(["id" => $user->company_id])->fetch();
        } else {
          $company = null;
        }
      }

      if ($company) {
        if (!empty($company->lat) && !empty($company->lng)) {
          $company->has_address = true;
        } else {
          $company->has_address = false;
        }

        $status = true;
      } else {
        $errors[] = "компания не найдена";
      }

      $response = $company;
      break;
    }

    break;

  case "finddata":
    switch ($params["from"]) {
    case "objects":
      $cr = check_role($user, "default");
      if ($cr === false) {json_response($cr, ["msg" => "not access",]); return;}
      $ce = check_enabled_user($user);
      if ($ce === false) {json_response($ce, ["msg" => "not access",]); return;}

      $helpers = [];
      $find_params = [];

      if (isset($params["number"]) && !empty($params["number"])) {
        $find_params["number"] = $params["number"];
      }
      if (isset($params["region_id"]) && !empty($params["region_id"])) {
        $find_params["region_id"] = $params["region_id"];
      }
      if (isset($params["company_id"]) && !empty($params["company_id"])) {
        $find_params["company_id"] = $params["company_id"];
      }

      $page = $params["page"];
      $pagination_count = 50;
      $offset_count = ($page - 1) * $pagination_count;

      if (check_role($user, "admin")) {
        $objects = $DB->point()->where($find_params)->select(
          "id", "number", "region", "region_id", "name", "has_object", "has_address", "has_device", "company", "company_id", "address", "dogovor", "state_id"
        )->fetchAll();
      } else if (check_role($user, "default")) {
        if ($user->company_id) {
          $find_params["company_id"] = $user->company_id;
          $objects = $DB->point()->where($find_params)->select(
            "id", "number", "region", "region_id", "name", "has_object", "has_address", "has_device", "company", "company_id", "address", "dogovor", "state_id"
          )->fetchAll();
        } else {
          $objects = [];
        }
      }


      if (isset($params["name"]) && !empty($params["name"])) {
        $find_params["name"] = $params["name"];
        $find_name = mb_strtoupper( $params["name"] );
        $objects_t = [];
        foreach ($objects as $object) {
          $_name = mb_strtoupper( $object->name );
          if (preg_match("/" . $find_name . "/", $_name)) {
            $objects_t[] = $object;
          }
        }
        $objects = $objects_t;
      }

      $response["count"] = count($objects);

      if (isset($params["address"]) && !empty($params["address"])) {
        $find_params["address"] = $params["address"];
        $address = mb_strtoupper( $params["address"] );
        $objects_t = [];
        foreach ($objects as $object) {
          $_address = mb_strtoupper( $object->address );
          if (preg_match("/" . $address . "/", $_address)) {
            $objects_t[] = $object;
          }
        }
        $objects = $objects_t;
      }

      foreach ($objects as $object) {
        $region_id = $object->region_id;
        $region = $DB->list()->where(["type" => "region", "id" => $region_id])->fetch();
        $object->region = $region->value_a;
        $object->has_object  = boolval($object->has_object);
        $object->has_address = boolval($object->has_address);
        $object->has_device  = boolval($object->has_device);
        $object->dogovor     = boolval($object->dogovor);
      }

      $_regions = $DB->list()->where("type", "region")->select("id", "value", "value_a")->fetchAll();
      $regions = [];

      foreach ($_regions as $region) {
        $id   = $region->value;
        $name = $region->value_a;
        $regions[$id] = $name;
      }

      $helpers["regions"] = $regions;

      if (check_role($user, "admin")) {
        $_companies = $DB->company()->select("id", "title")->fetchAll();
        $companies = [];

        foreach ($_companies as $company) {
          $id = $company->id;
          $name = $company->title;
          $companies[$id] = $name;
        }

        $helpers["companies"] = $companies;
      } else if (check_role($user, "default")) {
        if ($user->company_id) {
          $company = $DB->company()->where("id", $user->company_id)->select("id", "title")->fetch();
          if ($company) {
            $companies = [];
            $companies[$company->id] = $company->title;
          } else {
            $companies = new stdclass();
          }

          $helpers["companies"] = $companies;
        } else {
          $helpers["companies"] = new stdclass();
        }
      }

      $response["helpers"] = $helpers;
      $rows = array_slice($objects, $offset_count, $pagination_count);
      $response["rows"] = $rows;
      $response["rows_count"] = count($objects);
      $response["offset_count"] = $offset_count;
      $response["paginations"] = gen_paginations(
        count($objects), $pagination_count, $page, 11
      );
      $response["fd"] = $find_params;
      $status = true;
      break;
    }
    break;

  case "toggle":
    switch ($params["from"]) {
    case "page":
      $cr = check_role($user, "default");
      if ($cr === false) {json_response($cr, ["msg" => "not access",]); return;}
      $ce = check_enabled_user($user);
      if ($ce === false) {json_response($ce, ["msg" => "not access",]); return;}

      $page = $DB->pages()->where("id", $params["id"])->fetch();
      if ($page) {
        if ($page[$params["field"]] === "0") {
          $page[$params["field"]] = true;
        } else {
          $page[$params["field"]] = false;
        }
      } else {
        $errors = [
          "страница не найдена"
        ];
      }

      $page->save();
      $status = true;
      $response = $page;
      break;

    case "user":
      $cr = check_role($user, "default");
      if ($cr === false) {json_response($cr, ["msg" => "not access",]); return;}
      $ce = check_enabled_user($user);
      if ($ce === false) {json_response($ce, ["msg" => "not access",]); return;}

      $user_ = $DB->users()->where("id", $params["id"])->fetch();
      if ($user_) {
        if ($user_[$params["field"]] === "0") {
          $user_[$params["field"]] = true;
        } else {
          $user_[$params["field"]] = false;
        }
      } else {
        $errors[] = "страница не найдена";
      }

      $user_->save();
      $status = true;
      $response = $user_;
      break;
    }
    break;

  case "savedata":
    switch ($params["from"]) {
    case "page": // save
      $cr = check_role($user, "default");
      if ($cr === false) {json_response($cr, ["msg" => "not access",]); return;}
      $ce = check_enabled_user($user);
      if ($ce === false) {json_response($ce, ["msg" => "not access",]); return;}

      $page = $DB->pages()->where("id", $params["model"]["id"])->fetch();
      $page->enabled = boolval($page->enabled);

      if ($page) {
        $page->update($params["model"]);
        $status = true;
        $response = $page;
        $messages[] = "сохранение прошло успешно";
      } else {
        $status = false;
        $response = null;
        $errors = [
          "найти страницу не удалось",
        ];
      }

      break;

    case "user": //save
      $cr = check_role($user, "default");
      if ($cr === false) {json_response($cr, ["msg" => "not access",]); return;}
      $ce = check_enabled_user($user);
      if ($ce === false) {json_response($ce, ["msg" => "not access",]); return;}

      $user_ = $DB->users()->where("id", $params["model"]["id"])->select("id", "fio", "login", "email", "role_id", "isenabled")->fetch();

      if ($user_) {
        $user_->isenabled = boolval($user_->isenabled);
        $data_ = [
          "fio" => $params["model"]["fio"],
          "email" => $params["model"]["email"],
          "phone" => $params["model"]["phone"],
          "isenabled" => $params["model"]["isenabled"],
          "role_id" => $params["model"]["role_id"],
        ];

        if ($user->id == $params["model"]["id"]) {
          unset($data_["role_id"]);
          unset($data_["isenabled"]);
        }

        if (!check_role($user, "admin")) {
          unset($data_["isenabled"]);
        }

        if (check_role($user, "admin")) {
          $data_["company_id"] = $params["model"]["company_id"];
        }

        $user_->update($data_);
        $user_ = preset_role($user_);

        if ($user_->company_id) {
          $company = $DB->company()->where("id", $user_->company_id)->fetch();
          if ($company) {
            $user_->company = $company->title;
          }
        } else {
          $user_->company = "";
        }

        $status = true;
        $response = $user_;
        $messages[] = "сохранение прошло успешно";
        $v = "saveuser";
      } else {
        $errors[] = "пользователь не найден";
      }

      break;

    case "object": //save
      $cr = check_role($user, "default");
      if ($cr === false) {json_response($cr, ["msg" => "not access",]); return;}
      $ce = check_enabled_user($user);
      if ($ce === false) {json_response($ce, ["msg" => "not access",]); return;}

      if (check_role($user, "admin")) {
        $object = $DB->point()->where("id", $params["model"]["id"])->fetch();
      } else if (check_role($user, "default")) {
        if ($user->company_id) {
          $object = $DB->point()->where(["id" => $params["model"]["id"], "company_id" => $user->company_id])->fetch();
        } else {
          $object = null;
        }
      }

      if ($object) {
        $object->has_object  = boolval($object->has_object);
        $object->has_address = boolval($object->has_address);
        $object->has_device  = boolval($object->has_device);
        $object->dogovor     = boolval($object->dogovor);

        if (!empty($params["model"]["name"])) {
          $object->has_object = true;
        }

        $update_data = [
          "name"        => $params["model"]["name"],
          "phone"       => $params["model"]["phone"],
          "person"      => $params["model"]["person"],
          "dogovor"     => $params["model"]["dogovor"],
          "description" => $params["model"]["description"],
          "address"     => $params["model"]["address"],
          "has_address" => false,
          "lat"         => $params["model"]["lat"],
          "lng"         => $params["model"]["lng"],
        ];

        if (!empty($params["model"]["lat"]) && !empty($params["model"]["lng"])) {
          $update_data["has_address"] = true;
        } else {
          $update_data["has_address"] = false;
        }

        $ch_counter_objects_state = $DB->state()->fetch()->ch_counter_objects_state;
        $update_data["ch_counter_objects_state"] = $ch_counter_objects_state + 1;

        $object->update($update_data);
        $status = true;
        $response = $object;
        $messages[] = "сохранение прошло успешно";
        $v = "saveobject";
      } else {
        $errors[] = "объект не найден";
      }
    }

    break;

  case "create":
    switch ($params["from"]) {
    case "page":
      $cr = check_role($user, "default");
      if ($cr === false) {json_response($cr, ["msg" => "not access",]); return;}
      $ce = check_enabled_user($user);
      if ($ce === false) {json_response($ce, ["msg" => "not access",]); return;}

      $page = $DB->createRow('pages', ["name" => ""]);
      $page->save();
      $response = $page;
      $status = true;
      $v = "create page";
      break;

    case "company":
      $cr = check_role($user, "default");
      if ($cr === false) {json_response($cr, ["msg" => "not access",]); return;}
      $ce = check_enabled_user($user);
      if ($ce === false) {json_response($ce, ["msg" => "not access",]); return;}

      $company = $DB->createRow('company', ["title" => ""]);
      $company->save();
      $response = $company;
      $status = true;
      $v = "create company";
      break;
    }
    break;

  case "delete":
    switch ($params["from"]) {
    case "page":
      $cr = check_role($user, "default");
      if ($cr === false) {json_response($cr, ["msg" => "not access",]); return;}
      $ce = check_enabled_user($user);
      if ($ce === false) {json_response($ce, ["msg" => "not access",]); return;}

      $page = $DB->pages()->where("id", $params["id"])->fetch();
      if ($page) {
        $page->delete();
        $status = true;
      } else {
        $errors[] = "страница не найдена";
        $status = false;
      }

      break;

    case "user":
      $cr = check_role($user, "default");
      if ($cr === false) {json_response($cr, ["msg" => "not access",]); return;}
      $ce = check_enabled_user($user);
      if ($ce === false) {json_response($ce, ["msg" => "not access",]); return;}

      $user_ = $DB->users()->where("id", $params["id"])->fetch();

      if ($user->id == $user_->id) {
        $status = false;
        $errors[] = "нельзя удалить самого себя";
      } else {
        if ($user_) {
          $user_->delete();
          $status = true;
        } else {
          $errors[] = "пользователь не найден";
          $status = false;
        }
      }

      break;
    }
  }

  json_response($status, $response, $errors, $messages, $v);
});


Flight::route('POST /search/by/name', function() {
  global $DB;

  //if (isset(Flight::request()->data->getData()["name"])) {
    //$qs = Flight::request()->data->getData()["name"];
    //$q = mb_strtoupper( mb_convert_encoding($qs, "UTF-8"));
    //if (strlen($q) >= 3) {
      //$result = $DB->point()->where(
        //'UPPER(name) LIKE ?', ["%" . $q . "%"]
        ////'name LIKE ?', ["%" . $q . "%"]
      //)->select('id', 'name', 'number', 'region_id')->fetchAll();
    //} else {
      //$result = [];
    //}
  //} else {
    //$result = [];
  //}

  if (isset(Flight::request()->data->getData()["name"])) {
    $qs = Flight::request()->data->getData()["name"];
    //$q = mb_strtoupper( mb_convert_encoding($qs, "UTF-8"));
    $q = mb_strtoupper($qs);
    if (strlen($q) >= 3) {
      $rows = $DB->point()->where(["has_object" => 1, "has_address" => 1, "has_device" => 1,])->select(
        "id", "name", "number", "region_id"
      )->fetchAll();

      $result = [];

      foreach ($rows as $row) {
        $name = mb_strtoupper($row->name);
        if (preg_match("/" . $q . "/", $name)) {
          $result[] = $row;
        }
      }

    } else {
      $result = [];
    }
  } else {
    $result = [];
  }

  json_response(true, $result);
});


function daemon_start() {
  $status = daemon_status();

  if ($status === true) {
    return true;
  } else if ($status === false) {
    $cmd = "php " . __DIR__ . "/daemon.php 1>/dev/null 2>/dev/null &";
    exec($cmd);
    $sleep_cmd = "sleep 2";
    exec($sleep_cmd);

    if (daemon_status()) {
      return true;
    } else {
      return false;
    }
  }
}


function daemon_stop() {
  $status = daemon_status();

  if ($status) {
    $pid_cmd = "cat " . __DIR__ . "/daemon.pid";
    $pid = exec($pid_cmd);
    $kill_cmd = "kill " . $pid;
    $kill = exec($kill_cmd);
    $sleep_cmd = "sleep 2";
    exec($sleep_cmd);

    if (daemon_status()) {
      return false;
    } else {
      return true;
    }
  } else {
    return true;
  }
}


function daemon_status() {
  $pid_cmd = "cat " . __DIR__ . "/daemon.pid";
  $pid = exec($pid_cmd);
  $ps_cmd = "ps --no-headers -fp " . $pid . " | wc -l";
  $ps = exec($ps_cmd);

  if ($ps === "1") {
    return true;
  } else if ($ps === "0") {
    return false;
  }
}


Flight::route('GET /daemon/@command', function($command) {
  if ($command === "start") {
    if (daemon_start()) {
      echo "OK";
    } else {
      echo "FALSE";
    }
  } else if ($command === "stop") {
    if (daemon_stop()) {
      echo "OK";
    } else {
      echo "FALSE";
    }
  } else if ($command === "status") {
    if (daemon_status()) {
      echo "OK";
    } else {
      echo "FALSE";
    }
  }
});


Flight::route('GET /t/@name', function($name) {
  $filepath = __DIR__ . "/views/" . $name . ".tpl";
  if (file_exists($filepath)) {
    html_response("layout_markup", ["view" => $name]);
  } else {
    json_response(false, ["msg" => "not found"]);
  }
});


Flight::route('GET /page/@name', function($name) {
  global $DB;
  global $MD;

  $page = $DB->pages()->where("name", $name)->fetch();
  $data = [];

  if ($page) {
    if ($page->enabled) {
      $data["view"] = "page";
      $data["page"] = $page;
      $data["MD"] = $MD;
    } else {
      response_404();
      return;
    }
  } else {
    response_404();
    return;
  }

  html_response("layout", $data);
});


Flight::map('notFound', function() {
  global $DB;
  global $MD;

  Flight::response()->status(404);
  $page = $DB->pages()->where("name", "404")->fetch();

  if ($page) {
    html_response("layout_page", $page);
  } else {
    html_response("layout_page", ["view" => "404"]);
  }
});


Flight::start();
