<div>
  <div class="tools first" v-bind:class="{hide: panel.first.class.hide}">
    <div class="tools_wrap">
      <ul class="tools_list">
        <li class="tools_list_item">
          <a class="mui-btn mui-btn--raised mui-btn--small" v-on:click="toggle_panel_all" title="Скрыть панель фильтров">
            <i class="fa fa-chevron-left" nc title="{{buttons.toggle.msg}}" title="Скрыть панель фильтров"></i>
          </a>
        </li>
        <li class="tools_list_item">
          <a class="mui-btn mui-btn--raised mui-btn--small" title="Показать вторую панель фильтров" v-on:click="toggle_panel_second">
            <i class="fa fa-chevron-down" nc title="Показать вторую панель фильтров"></i>
          </a>
        </li>
        <li class="tools_list_item">
          <a class="mui-btn mui-btn--raised mui-btn--small mark_1" title="Переключить отображение датчиков со статусом 1" v-on:click="filter_points_state(1, $event)" data-state_id="1">
            <i class="fa" v-bind:class="buttons.state_icons.st1" nc title="Переключить отображение датчиков со статусом 1"></i>
          </a>
        </li>
        <li class="tools_list_item">
          <a class="mui-btn mui-btn--raised mui-btn--small mark_2" title="Переключить отображение датчиков со статусом 2" v-on:click="filter_points_state(2, $event)" data-state_id="2">
            <i class="fa" v-bind:class="buttons.state_icons.st2" nc title="Переключить отображение датчиков со статусом 2"></i>
          </a>
        </li>
        <li class="tools_list_item">
          <a class="mui-btn mui-btn--raised mui-btn--small mark_3" title="Переключить отображение датчиков со статусом 3" v-on:click="filter_points_state(3, $event)" data-state_id="3">
            <i class="fa" v-bind:class="buttons.state_icons.st3" nc title="Переключить отображение датчиков со статусом 3"></i>
          </a>
        </li>
        <li class="tools_list_item">
          <a class="mui-btn mui-btn--raised mui-btn--small mark_dogovors" title="Отобразить/Скрыть объекты без договоров" v-on:click="toggle_show_dogovor_on_map">
            <i class="fa" v-bind:class="buttons.state_icons.dogovors" nc title="Отобразить/Скрыть объекты без договоров"></i>
          </a>
        </li>
        <li class="tools_list_item">
          <div class="mui-dropdown">
            <a class="mui-btn mui-btn--raised mui-btn--small" data-mui-toggle="dropdown" title="Фильтр по номеру датчика">
              <i class="fa fa-square-o"></i>
              Номер
              <span class="mui-caret"></span>
            </a>
            <ul class="mui-dropdown__menu mui-dropdown__menu_style1" data-area="numbers">
              <li>
                <a data-area="search">
                  <input type="text" v-on:click="find_number_in_list" v-on:keyup="find_number_in_list" placeholder="Найти номер" class="mui-form--speedsearch">
                </a>
              </li>
              <li v-for="number in numbers"><a v-on:click="filter_by_number" v-bind:data-number="number.number" v-bind:data-region_id="number.region_id"><i class="fa fa-square-o" nc></i> <span nc>{{number.number}}</span> <span class="light" nc>- {{number.region_id}}</span></a></li>
            </ul>
          </div>
        </li>
        <li class="tools_list_item">
          <a class="mui-btn mui-btn--raised mui-btn--small" v-on:click="toggle_panel_third" title="Отобразить/Скрыть фильтр по имени объекта">
            <i class="fa fa-font" title="Отобразить/Скрыть фильтр по имени объекта"></i>
          </a>
        </li>
        <li class="tools_list_item">
          <a class="mui-btn mui-btn--raised mui-btn--small mark_stat" title="Показать общую статистику" v-on:click="modal_info_show('stats')">
            <i class="fa fa-table" nc title="Показать общую статистику"></i>
          </a>
        </li>
        <li class="tools_list_item">
          <a class="mui-btn mui-btn--raised mui-btn--small" title="Войти в панель администрирования" v-on:click="modal_info_show('auth')">
            <i class="fa fa-sign-in" title="Войти в панель администрирования" nc></i>
          </a>
        </li>
        <li class="tools_list_item">
          <a class="mui-btn mui-btn--raised mui-btn--small" title="Открыть панель фильтров" v-on:click="modal_info_show('filter')">
            <i class="fa fa-sliders" title="Открыть панель фильтров" nc></i>
          </a>
        </li>
      </ul>
    </div>
  </div>

  <div class="tools second" v-bind:class="{hide: panel.second.class.hide}">
    <div class="tools_wrap">
      <ul class="tools_list">
        <li class="tools_list_item">
          <a class="mui-btn mui-btn--raised mui-btn--small" v-on:click="toggle_panel_all" title="Скрыть панель фильтров">
            <i class="fa fa-chevron-left" nc title="{{buttons.toggle.msg}}" title="Скрыть панель фильтров"></i>
          </a>
        </li>
        <li class="tools_list_item">
          <a class="mui-btn mui-btn--raised mui-btn--small" v-on:click="toggle_panel_second" title="Переключиться на первую панель фильтров">
            <i class="fa fa-chevron-up" nc title="{{buttons.toggle.msg}}" title="Переключиться на первую панель фильтров"></i>
          </a>
        </li>
        <li class="tools_list_item">
          <div class="mui-dropdown">
            <a class="mui-btn mui-btn--raised mui-btn--small" data-mui-toggle="dropdown" title="">
              <i class="fa fa-fire"></i>
              Класс ФПО
              <span class="mui-caret"></span>
            </a>
            <ul class="mui-dropdown__menu mui-dropdown__menu_style1">
              <li v-for="(name, id) in class_fps"><a v-on:click="change_filter('class_fps', id, $event)" data-type="class_fps" v-bind:data-id="id" v-bind:title="name"><i class="fa fa-square-o" v-bind:title="name" nc></i> <span nc v-bind:title="name">{{name}}</span></a></li>
            </ul>
          </div>
        </li>
        <li class="tools_list_item">
          <div class="mui-dropdown">
            <a class="mui-btn mui-btn--raised mui-btn--small" data-mui-toggle="dropdown" title="">
              <i class="fa fa-book"></i>
              Ведомство
              <span class="mui-caret"></span>
            </a>
            <ul class="mui-dropdown__menu mui-dropdown__menu_style1">
              <li v-for="(name, id) in departments"><a v-on:click="change_filter('departments', id, $event)" data-type="departments" v-bind:data-id="id" v-bind:title="name"><i class="fa fa-square-o" nc></i> <span nc>{{name}}</span></a></li>
            </ul>
          </div>
        </li>
        <li class="tools_list_item">
          <div class="mui-dropdown">
            <a class="mui-btn mui-btn--raised mui-btn--small" data-mui-toggle="dropdown" title="">
              <i class="fa fa-bookmark"></i>
              Тип объекта
              <span class="mui-caret"></span>
            </a>
            <ul class="mui-dropdown__menu mui-dropdown__menu_style1">
              <li v-for="(name, id) in types"><a v-on:click="change_filter('types', id, $event)" data-type="types" v-bind:data-id="id" v-bind:title="name"><i class="fa fa-square-o" nc></i> <span nc>{{name}}</span></a></li>
            </ul>
          </div>
        </li>
        <li class="tools_list_item">
          <div class="mui-dropdown">
            <a class="mui-btn mui-btn--raised mui-btn--small" data-mui-toggle="dropdown" title="">
              <i class="fa fa-cube"></i>
              Услуга
              <span class="mui-caret"></span>
            </a>
            <ul class="mui-dropdown__menu mui-dropdown__menu_style1">
              <li v-for="(name, id) in services"><a v-on:click="change_filter('services', id, $event)" data-type="services" v-bind:data-id="id" v-bind:title="name"><i class="fa fa-square-o" nc></i> <span nc>{{name}}</span></a></li>
            </ul>
          </div>
        </li>
        <li class="tools_list_item">
          <div class="mui-dropdown">
            <a class="mui-btn mui-btn--raised mui-btn--small" data-mui-toggle="dropdown" title="">
              <i class="fa fa-building-o"></i>
              Компания
              <span class="mui-caret"></span>
            </a>
            <ul class="mui-dropdown__menu mui-dropdown__menu_style1">
              <li v-for="(name, id) in companies"><a v-on:click="change_filter('companies', id, $event)" data-type="companies" v-bind:data-id="id"><i class="fa fa-square-o" nc></i> <span nc>{{name}}</span></a></li>
            </ul>
          </div>
        </li>
        <li class="tools_list_item">
          <div class="mui-dropdown">
            <a class="mui-btn mui-btn--raised mui-btn--small" data-mui-toggle="dropdown" title="Фильтр по номеру региона для объектов, не работает для компаний">
              <i class="fa fa-map-signs"></i>
              Регион
              <span class="mui-caret"></span>
            </a>
            <ul class="mui-dropdown__menu mui-dropdown__menu_style1">
              <li><a><input type="text" v-on:click="find_region_in_list" v-on:keyup="find_region_in_list" placeholder="Найти регион в списке" class="mui-form--speedsearch"></a></li>
              <li v-for="(name, id) in regions" data-item="region" v-bind:data-name="name"><a v-on:click="change_filter('regions', id, $event)" v-bind:title="name" data-type="regions" v-bind:data-id="id"><i class="fa fa-square-o" nc></i> <span class="light" nc>{{id}}</span> <span nc>{{name}}</span></a></li>
            </ul>
          </div>
        </li>
      </ul>
    </div>
  </div>

  <div class="tools second" v-bind:class="{hide: panel.third.class.hide}">
    <div class="tools_wrap">
      <ul class="tools_list">
        <li class="tools_list_item">
          <a class="mui-btn mui-btn--raised mui-btn--small" v-on:click="toggle_panel_all" title="Скрыть панель фильтров">
            <i class="fa fa-chevron-left" nc title="{{buttons.toggle.msg}}" title="Скрыть панель фильтров"></i>
          </a>
        </li>
        <li class="tools_list_item">
          <a class="mui-btn mui-btn--raised mui-btn--small" v-on:click="toggle_panel_third" title="Закрыть фильтр по названию объекта">
            <i class="fa fa-times" nc title="Закрыть фильтры по названию объекта"></i>
          </a>
        </li>
        <li class="tools_list_item">
          <input type="text" class="tools_list_item__input_full" placeholder="Напишите название объекта" data-target="search_with_name_object" v-on:keyup="filter_by_name">
          <div class="mui-dropdown">
            <ul class="mui-dropdown__menu mui-dropdown__menu_style1" data-target="search_with_name_object_list">
              <li v-for="object_name in object_names"><a v-on:click="filter_by_object_name(object_name, $event)"><i class="fa fa-square-o" nc></i> <span nc>{{object_name.name}}</span></a></li>
            </ul>
          </div>
        </li>
        <li class="tools_list_item">
          <a class="mui-btn mui-btn--raised mui-btn--small" v-on:click="search_with_name_object_list__toggle" title="Отобразить/Скрыть список с результатами поиска">
            <i class="fa fa-list"></i>
          </a>
        </li>
        <li class="tools_list_item">
          <a class="mui-btn mui-btn--raised mui-btn--small" v-on:click="filter_by_object_name_clear" title="Очистить выбранные объекты из фильтра">
            <i class="fa fa-times" title="Очистить выбранные объекты из фильтра" nc></i> <span>{{object_names_in_filters.length}}</span>
          </a>
        </li>
      </ul>
    </div>
  </div>

  <a class="mui-btn mui-btn--raised mui-btn--small tools_toggle_btn" v-on:click="toggle_panel_all" title="Показать фильтры">
    <i class="fa fa-chevron-right" nc title="Показать фильтры"></i>
  </a>

  <a class="mui-btn mui-btn--raised mui-btn--small filter_toggle_btn" title="Открыть панель фильтров" v-on:click="modal_info_show('filter')">
    <i class="fa fa-sliders" title="Открыть панель фильтров" nc></i>
  </a>

  <div class="modal_window animated" v-bind:class="modalClass">
    <div class="modal_window_wrap">
      <a v-on:click="closeModal" class="close_btn" title="Закрыть карточку объекта">
        <i class="fa fa-times"></i>
      </a>
      <div class="head">
        <h2>{{row.name}}</h2>
      </div>

      <div class="body">
        <table class="mui-table mui-table--bordered">
          <tbody>
            <tr>
              <td>АПС</td>
              <td><span class="state_label" v-bind:class="row.state_id">{{row.state}}</span></td>
            </tr>
            <tr>
              <td>Вывод на 01</td>
              <td><span>{{row.v01}}</span></td>
            </tr>
            <tr>
              <td>Телефон</td>
              <td>{{row.phone}}</td>
            </tr>
            <tr>
              <td>Ответственное лицо</td>
              <td>{{row.person}}</td>
            </tr>
            <tr>
              <td>Класс ФП</td>
              <td>{{row.class_fp}}</td>
            </tr>
            <tr>
              <td>Ведомство</td>
              <td>{{row.department}}</td>
            </tr>
            <tr>
              <td>Тип финансирования</td>
              <td>{{row.type_financing}}</td>
            </tr>
            <tr>
              <td>Договор</td>
              <td>{{row.dogovor}}</td>
            </tr>
            <tr>
              <td>Контакты</td>
              <td>{{row.description}}</td>
            </tr>
            <tr>
              <td>Адрес объекта</td>
              <td>{{row.address}}</td>
            </tr>
            <tr>
              <td>Регион</td>
              <td>{{row.region_id}}</td>
            </tr>
            <tr>
              <td>Номер АПС</td>
              <td>{{row.number}}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="footer">
        <a v-on:click="editPoint" class="mui-btn mui-btn--raised mui-btn--danger mui-btn--small">
          <i class="fa fa-pencil"></i>
          <span>редактировать</span>
        </a>
        <a v-on:click="closeModal" class="mui-btn mui-btn--raised mui-btn--small">
          <i class="fa fa-times"></i>
          <span>закрыть</span>
        </a>
      </div>
    </div>
  </div>

  <div class="modal_info animated" v-bind:class="modalInfoClass">
    <div class="modal_info_wrap">
      <div class="profile">
        <ul class="profile_params_list" v-bind:class="Object.keys(user).length == 0 ? 'hide' : ''">
          <li><a v-bind:title="'Логин учётной записью ' + user.login"><span class="profile_name">логин</span> {{user.login}}</a></li>
          <li><a v-bind:title="'Роль учётной записи ' + user.role"><span class="profile_name">роль</span> {{user.role}}</a></li>
          <li v-bind:class="typeof(user.company) == 'undefined' ? 'hide' : ''"><a v-bind:title="'К учётной записи привязана фирма ' + user.company"><span class="profile_name">компания</span> {{user.company}}</a></li>
          <li><a v-on:click="send_logout">выйти</a></li>
        </ul>
      </div>

      <div class="head">
        <a v-on:click="modal_info_close"><i class="fa fa-times"></i></a>
      </div>
      <div class="body">

        <div v-show="modal_info.stats">
          <h1 style="text-align: center;">Статистика</h1>
          <table class="mui-table mui-table--bordered">
            <tbody>
              <tr v-for="row in stats">
                <td>{{row.name}}</td>
                <td>{{row.value}}</td>
              </tr>
            </tbody>
          </table>
        </div>

        <div v-show="modal_info.auth">
          <auth></auth>
        </div>

        <div v-show="modal_info.panel">
          <panel></panel>
        </div>

        <div v-show="modal_info.filter">
          <filter_panel></filter_panel>
        </div>

      </div>
      <div class="footer"></div>
    </div>
  </div>
</div>
