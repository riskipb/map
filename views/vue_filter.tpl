<div>
  <h1 class="mui--text-center">
    <i class="fa fa-search fa-small"></i>
    Фильтры
  </h1>

  <div class="filters">
    <div class="filters_wrap">

      <div class="mui-container-fluid">
        <div class="mui-row">
          <div class="mui-col-md-12">
            <div class="mui-panel mui-panel--default">
              <span class="mui-panel--head">
                <i class="fa fa-i-cursor"></i>
                Поиск по названию объекта
              </span>

              <form class="mui-form">
                <div class="mui-textfield">
                  <a class="mui-btn mui-btn--small" v-on:click="search_with_name_object_list__toggle" title="Отобразить/Скрыть список с результатами поиска">
                    <i class="fa fa-list"></i>
                  </a>
                  <a class="mui-btn mui-btn--small" v-on:click="filter_by_object_name_clear" title="Очистить выбранные объекты из фильтра">
                    <i class="fa fa-times" title="Очистить выбранные объекты из фильтра" nc></i> <span>{{object_names_in_filters.length}}</span>
                  </a>
                  <input type="text" placeholder="Название объекта для поиска" data-target="search_with_name_object" v-on:keyup="filter_by_name">
                  <div class="mui-dropdown" style="display: block;">
                    <ul class="mui-dropdown__menu mui-dropdown__menu_style1" data-target="search_with_name_object_list2">
                      <li v-for="object_name in object_names">
                        <a v-on:click="filter_by_object_name(object_name, $event)"><i class="fa fa-square-o" nc></i> <span nc>{{object_name.name}}</span></a>
                      </li>
                    </ul>
                  </div>
                </div>
              </form>

              <div class="result"></div>
            </div>
          </div>
        </div>
      </div>

      <div class="mui-container-fluid">
        <div class="mui-row">
          <div class="mui-col-md-4">

            <div class="mui-panel mui-panel--default">
              <span class="mui-panel--head">
                <i class="fa fa-fire"></i>
                Класс функциональной пожарной опасности
              </span>
              <div class="result">
                <div class="result_wrap">
                  <ul class="result_list">
                    <li v-for="(name, id) in class_fps_changed" class="result_item" data-search_input="class_fp_item">
                      <a v-on:click="unchange_filter('class_fps', id, name, $event)" v-bind:title="'убрать ' + name"><i class="fa fa-times" nc></i></a>
                      <span v-bind:title="name">{{name}}</span>
                    </li>
                  </ul>
                </div>
              </div>
              <div class="mui-dropdown">
                <a class="mui-btn mui-btn--small2" data-mui-toggle="dropdown">выбрать<span class="mui-caret"></span></a>
                <ul class="mui-dropdown__menu mui-dropdown__menu_style1">
                  <li>
                    <a data-area="search">
                      <input type="text" class="search_input" v-on:click="find_in_list" v-on:keyup="find_in_list" data-search_target="class_fp_item">
                    </a>
                  </li>
                  <li v-for="(name, id) in class_fps" data-search_item="class_fp_item" data-search_input="class_fp_item" v-bind:data-value="name">
                    <a v-bind:title="name" v-on:click="change_filter('class_fps', id, name, $event)">{{name}}</a>
                  </li>
                </ul>
              </div>
            </div>

            <div class="mui-panel mui-panel--default">
              <span class="mui-panel--head">
                <i class="fa fa-bookmark"></i>
                Тип объекта
              </span>
              <div class="result">
                <div class="result_wrap">
                  <ul class="result_list">
                    <li v-for="(name, id) in types_changed" class="result_item" data-search_input="types_item">
                      <a v-on:click="unchange_filter('types', id, name, $event)" v-bind:title="'убрать ' + name"><i class="fa fa-times" nc></i></a>
                      <span v-bind:title="name">{{name}}</span>
                    </li>
                  </ul>
                </div>
              </div>
              <div class="mui-dropdown">
                <a class="mui-btn mui-btn--small2" data-mui-toggle="dropdown">выбрать<span class="mui-caret"></span></a>
                <ul class="mui-dropdown__menu mui-dropdown__menu_style1">
                  <li>
                    <a data-area="search">
                      <input type="text" class="search_input" v-on:click="find_in_list" v-on:keyup="find_in_list" data-search_target="types_item">
                    </a>
                  </li>
                  <li v-for="(name, id) in types" data-search_item="types_item" data-search_input="types_item" v-bind:data-value="name">
                    <a v-bind:title="name" v-on:click="change_filter('types', id, name, $event)">{{name}}</a>
                  </li>
                </ul>
              </div>
            </div>

            <div class="mui-panel mui-panel--default">
              <span class="mui-panel--head">Автоматические пожарные сигнализации</span>
              <div class="mui-btn--group">
                <a class="mui-btn mui-btn--raised mui-btn--small mark_1" v-on:click="filter_points_state('1')">
                  <i class="fa" v-bind:class="buttons.state_icons.st1" title="Переключить отображение датчиков со статусом 1"></i>
                </a>
                <a class="mui-btn mui-btn--raised mui-btn--small mark_2" v-on:click="filter_points_state('2')">
                  <i class="fa" v-bind:class="buttons.state_icons.st2" title="Переключить отображение датчиков со статусом 2"></i>
                </a>
                <a class="mui-btn mui-btn--raised mui-btn--small mark_3" v-on:click="filter_points_state('3')">
                  <i class="fa" v-bind:class="buttons.state_icons.st3" title="Переключить отображение датчиков со статусом 3"></i>
                </a>
                <a class="mui-btn mui-btn--raised mui-btn--small mark_dogovors" v-on:click="toggle_show_dogovor_on_map">
                  <i class="fa" v-bind:class="buttons.state_icons.dogovors" title="Переключить отображение датчиков без договоров"></i>
                </a>
              </div>
            </div>
          </div>

          <div class="mui-col-md-4">
            <div class="mui-panel mui-panel--default">
              <span class="mui-panel--head">
                <i class="fa fa-book"></i>
                Ведомство
              </span>
              <div class="result">
                <div class="result_wrap">
                  <ul class="result_list">
                    <li v-for="(name, id) in departments_changed" class="result_item" data-search_input="departments_item">
                      <a v-on:click="unchange_filter('departments', id, name, $event)" v-bind:title="'убрать ' + name"><i class="fa fa-times" nc></i></a>
                      <span v-bind:title="name">{{name}}</span>
                    </li>
                  </ul>
                </div>
              </div>
              <div class="mui-dropdown">
                <a class="mui-btn mui-btn--small2" data-mui-toggle="dropdown">выбрать<span class="mui-caret"></span></a>
                <ul class="mui-dropdown__menu mui-dropdown__menu_style1">
                  <li>
                    <a data-area="search">
                      <input type="text" class="search_input" v-on:click="find_in_list" v-on:keyup="find_in_list" data-search_target="departments_item">
                    </a>
                  </li>
                  <li v-for="(name, id) in departments" data-search_item="departments_item" data-search_input="departments_item" v-bind:data-value="name">
                    <a v-bind:title="name" v-on:click="change_filter('departments', id, name, $event)">{{name}}</a>
                  </li>
                </ul>
              </div>
            </div>

            <div class="mui-panel mui-panel--default">
              <span class="mui-panel--head">
                <i class="fa fa-building-o"></i>
                Обслуживающая компания
              </span>
              <div class="result">
                <div class="result_wrap">
                  <ul class="result_list">
                    <li v-for="(name, id) in companies_changed" class="result_item" data-search_input="companies_item">
                      <a v-on:click="unchange_filter('companies', id, name, $event)" v-bind:title="'убрать ' + name"><i class="fa fa-times nc"></i></a>
                      <span v-bind:title="name">{{name}}</span>
                    </li>
                  </ul>
                </div>
              </div>
              <div class="mui-dropdown">
                <a class="mui-btn mui-btn--small2" data-mui-toggle="dropdown">выбрать<span class="mui-caret"></span></a>
                <ul class="mui-dropdown__menu mui-dropdown__menu_style1">
                  <li>
                    <a data-area="search">
                      <input type="text" class="search_input" v-on:click="find_in_list" v-on:keyup="find_in_list" data-search_target="companies_item">
                    </a>
                  </li>
                  <li v-for="(name, id) in companies" data-search_item="companies_item" data-search_input="companies_item" v-bind:data-value="name">
                    <a v-bind:title="name" v-on:click="change_filter('companies', id, name, $event)">{{name}}</a>
                  </li>
                </ul>
              </div>
            </div>
          </div>

          <div class="mui-col-md-4">
            <div class="mui-panel mui-panel--default">
              <span class="mui-panel--head">
                <i class="fa fa-cube"></i>
                Услуга
              </span>
              <div class="result">
                <div class="result_wrap">
                  <ul class="result_list">
                    <li v-for="(name, id) in services_changed" class="result_item" data-search_input="services_item">
                      <a v-on:click="unchange_filter('services', id, name, $event)" v-bind:title="'убрать ' + name"><i class="fa fa-times" nc></i></a>
                      <span v-bind:title="name">{{name}}</span>
                    </li>
                  </ul>
                </div>
              </div>
              <div class="mui-dropdown">
                <a class="mui-btn mui-btn--small2" data-mui-toggle="dropdown">выбрать<span class="mui-caret"></span></a>
                <ul class="mui-dropdown__menu mui-dropdown__menu_style1">
                  <li>
                    <a data-area="search">
                      <input type="text" class="search_input" v-on:click="find_in_list" v-on:keyup="find_in_list" data-search_target="services_item">
                    </a>
                  </li>
                  <li v-for="(name, id) in services" data-search_item="services_item" data-search_input="services_item" v-bind:data-value="name">
                    <a v-bind:title="name" v-on:click="change_filter('services', id, name, $event)">{{name}}</a>
                  </li>
                </ul>
              </div>
            </div>

            <div class="mui-panel mui-panel--default">
              <span class="mui-panel--head">
                <i class="fa fa-map-signs"></i>
                Муниципальное образование
              </span>
              <div class="result">
                <div class="result_wrap">
                  <ul class="result_list">
                    <li v-for="(name, id) in regions_changed" class="result_item" data-search_input="regions_item">
                      <a v-on:click="unchange_filter('regions', id, name, $event)" v-bind:title="'убрать ' + name"><i class="fa fa-times" nc></i></a>
                      <span v-bind:title="name">{{name}}</span>
                    </li>
                  </ul>
                </div>
              </div>
              <div class="mui-dropdown">
                <a class="mui-btn mui-btn--small2" data-mui-toggle="dropdown">выбрать<span class="mui-caret"></span></a>
                <ul class="mui-dropdown__menu mui-dropdown__menu_style1">
                  <li>
                    <a data-area="search">
                      <input type="text" class="search_input" v-on:click="find_in_list" v-on:keyup="find_in_list" data-search_target="regions_item">
                    </a>
                  </li>
                  <li v-for="(name, id) in regions" data-search_item="regions_item" data-search_input="regions_item" v-bind:data-value="name">
                    <a v-bind:title="name" v-on:click="change_filter('regions', id, name, $event)"><span class="light">{{id}}</span> {{name}}</a>
                  </li>
                </ul>
              </div>
            </div>

          </div>
        </div>
      </div>

      <hr>

      <div class="mui-container-fluid">
        <div class="mui-row">
          <div class="mui-col-md-12">

            <div>
              <a class="mui-btn mui-btn--raised mui-btn--red" v-on:click="set_filters_and_show_map">Применить</a>
              <a class="mui-btn mui-btn--raised mui-btn--red" v-on:click="filters_reset">Сбросить</a>
              <a class="mui-btn mui-btn--raised mui-btn--red" v-on:click="modal_info_close">
                <i class="fa fa-close"></i>
                Закрыть
              </a>
            </div>

          </div>
        </div>
      </div>

    </div>
  </div>
</div>
