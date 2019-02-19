<div>
  <ul class="mui-tabs__bar">
    <li class="mui--is-active">
      <a data-mui-toggle="tab" data-mui-controls="pane-info" data-button="info">
        <i class="fa fa-bars"></i>
        <span>
          Разделы
        </span>
      </a>
    </li>
    <li>
      <a data-mui-toggle="tab" data-mui-controls="pane-objects" v-on:click="show_panel_part('objects')">
        <i class="fa fa-list-alt" nc></i>
        <span nc>
          Объекты
        </span>
      </a>
    </li>
    <li>
      <a data-mui-toggle="tab" data-mui-controls="pane-companies" v-on:click="show_panel_part('companies')">
        <i class="fa fa-building-o" nc></i>
        <span nc>
          Компании
        </span>
      </a>
    </li>
    <li>
      <a data-mui-toggle="tab" data-mui-controls="pane-lists" v-on:click="show_panel_part('lists')">
        <i class="fa fa-book" nc></i>
        <span nc>
          Справочники
        </span>
      </a>
    </li>
    <li>
      <a data-mui-toggle="tab" data-mui-controls="pane-users" v-on:click="show_panel_part('users')">
        <i class="fa fa-address-card-o" nc></i>
        <span nc>
          Пользователи
        </span>
      </a>
    </li>
    <li>
      <a data-mui-toggle="tab" data-mui-controls="pane-pages" v-on:click="show_panel_part('pages')">
        <i class="fa fa-file-text-o" nc></i>
        <span nc>
          Страницы
        </span>
      </a>
    </li>
  </ul>

  <div class="mui-tabs__pane mui--is-active" id="pane-info">
    <div class="mui-container-fluid" style="margin-top: 20px;">
      <div class="mui-row">
        <div class="mui-col-md-6">
          <div class="mui-panel">
            <h3>
              <i class="fa fa-list-alt"></i>
              Объекты
            </h3>
            <p>В разделе можно просматривать и редактировать объекты отображаемые на карте.</p>
          </div>
        </div>
        <div class="mui-col-md-6">
          <div class="mui-panel">
            <h3>
              <i class="fa fa-building-o"></i>
              Компании
            </h3>
            <p>В разделе можно просматривать и редактировать компании предоставляющие услуги в области пожарной безопасности.</p>
          </div>
        </div>
      </div>
      <div class="mui-row">
        <div class="mui-col-md-6">
          <div class="mui-panel">
            <h3>
              <i class="fa fa-book"></i>
              Справочники
            </h3>
            <p>В разделе можно просматривать и редактировать справочники. Справочники используются при редактировании объектов и компаний.</p>
          </div>
        </div>
        <div class="mui-col-md-6">
          <div class="mui-panel">
            <h3>
              <i class="fa fa-address-card-o"></i>
              Пользователи
            </h3>
            <p>В разделе можно просматривать и редактировать пользователей. Пользователи могут редактировать данные с помощью панели администрирования.</p>
          </div>
        </div>
      </div>
      <div class="mui-row">
        <div class="mui-col-md-6">
          <div class="mui-panel">
            <h3>
              <i class="fa fa-file-text-o"></i>
              Страницы
            </h3>
            <p>В разделе можно редактировать страницы. Страницы необходимо для предоставления дополнительной информации, например "контакты" или "документы".</p>
          </div>
        </div>
      </div>
    </div>
  </div>

  <div class="mui-tabs__pane" id="pane-objects">
    <ul class="mui-tabs__bar">
      <li class="mui--is-active">
        <a data-mui-toggle="tab" data-mui-controls="pane-objects-list">Список объектов</a>
      </li>
      <li>
        <a data-mui-toggle="tab" data-mui-controls="pane-objects-search">Поиск объектов</a>
      </li>
    </ul>

    <div class="mui-tabs__pane mui--is-active" id="pane-objects-list">
      <div class="paginations" v-bind:class="Object.keys(objects_paginations).length == 0 ? 'hide' : ''">
        <ul class="paginations_wrap">
          <li class="paginations_item"><a class="mui-btn mui-btn--flat mui-btn--pagination" v-on:click="get_data_and_show_from_objects(objects_paginations.first)" v-bind:title="'перейти к первой странице ' + objects_paginations.first"><i class="fa fa-angle-double-left"></i></a></li>
          <li class="paginations_item"><a class="mui-btn mui-btn--flat mui-btn--pagination" v-on:click="get_data_and_show_from_objects(objects_paginations.prev)" v-bind:title="'перейти к предыдущей странице ' + objects_paginations.prev"><i class="fa fa-angle-left"></i></a></li>
          <li class="paginations_item" v-for="page in objects_paginations.pages"><a class="mui-btn mui-btn--pagination" v-bind:class="page == objects_paginations.page ? 'mui-btn--primary' : 'mui-btn--flat'" v-on:click="get_data_and_show_from_objects(page)" v-bind:title="'страница ' + page">{{page}}</a></li>
          <li class="paginations_item"><a class="mui-btn mui-btn--flat mui-btn--pagination" v-on:click="get_data_and_show_from_objects(objects_paginations.next)" v-bind:title="'перейти к следующей странице ' + objects_paginations.next"><i class="fa fa-angle-right"></i></a></li>
          <li class="paginations_item"><a class="mui-btn mui-btn--flat mui-btn--pagination" v-on:click="get_data_and_show_from_objects(objects_paginations.last)" v-bind:title="'перейти к последней странице ' + objects_paginations.last"><i class="fa fa-angle-double-right"></i></a></li>
        </ul>
      </div>

      <table class="mui-table mui-table--bordered" v-bind:class="objects_list.length == 0 ? 'hide' : ''">
        <thead>
          <tr>
            <th>ID</th>
            <th title="Номер устройства">Номер У</th>
            <th title="Номер региона">Номер Р</th>
            <th>Регион</th>
            <th>Название</th>
            <th title="Наличие описания">О</th>
            <th title="Наличие координат">К</th>
            <th title="Наличие устройства">У</th>
            <th title="Состояние АПС">А</th>
            <th title="Наличие договора">Д</th>
            <th>Действия</th>
          </tr>
        </thead>
        <tfoot>
          <tr>
            <th>ID</th>
            <th title="Номер устройства">Номер У</th>
            <th title="Номер региона">Номер Р</th>
            <th>Регион</th>
            <th>Название</th>
            <th title="Наличие описания">О</th>
            <th title="Наличие координат">К</th>
            <th title="Наличие устройства">У</th>
            <th title="Состояние АПС">А</th>
            <th title="Наличие договора">Д</th>
            <th>Действия</th>
          </tr>
        </tfoot>
        <tbody>
          <tr v-for="object in objects_list">
            <td>{{object.id}}</td>
            <td title="Номер устройства">{{object.number}}</td>
            <td title="Номер региона">{{object.region_id}}</td>
            <td>{{object.region}}</td>
            <td>{{object.name}}</td>
            <td title="Наличие описания">
              <i class="fa" v-bind:class="object.has_object ? 'fa-check-square-o' : 'fa-square-o'"></i>
            </td>
            <td title="Наличие координат">
              <i class="fa" v-bind:class="object.has_address ? 'fa-check-square-o' : 'fa-square-o'"></i>
            </td>
            <td title="Наличие устройства">
              <i class="fa" v-bind:class="object.has_device ? 'fa-check-square-o' : 'fa-square-o'"></i>
            </td>
            <td title="Состояние АПС" class="marker_in_table">
              <i class="fa fa-square" v-bind:class="'marker_state_' + object.state_id"></i>
            </td>
            <td title="Наличие договора">
              <i class="fa" v-bind:class="object.dogovor ? 'fa-check-square-o' : 'fa-square-o'"></i>
            </td>
            <td style="padding: 0;">
              <a class="mui-btn mui-btn--flat mui-btn--small margin-0" v-on:click="show_edit_form_for_object(object.id)" v-bind:title="'редактировать страницу ' + object.id"><i class="fa fa-pencil"></i></a>
              <a class="mui-btn mui-btn--flat mui-btn--small margin-0" v-on:click="change_relation_object_company(object.id)" v-bind:title="object.company_id === null ? 'привязать объект [' + object.id + '] к фирме' : 'отвязать объект [' + object.id + '] от фирмы ' + object.company"><i class="fa" v-bind:class="object.company_id === null ? 'fa-user-plus gray' : 'fa-user-times red'"></i></a>
            </td>
          </tr>
        </tbody>
      </table>

      <div class="paginations" v-bind:class="Object.keys(objects_paginations).length == 0 ? 'hide' : ''">
        <ul class="paginations_wrap">
          <li class="paginations_item"><a class="mui-btn mui-btn--flat mui-btn--pagination" v-on:click="get_data_and_show_from_objects(objects_paginations.first)" v-bind:title="'перейти к первой странице ' + objects_paginations.first"><i class="fa fa-angle-double-left"></i></a></li>
          <li class="paginations_item"><a class="mui-btn mui-btn--flat mui-btn--pagination" v-on:click="get_data_and_show_from_objects(objects_paginations.prev)" v-bind:title="'перейти к предыдущей странице ' + objects_paginations.prev"><i class="fa fa-angle-left"></i></a></li>
          <li class="paginations_item" v-for="page in objects_paginations.pages"><a class="mui-btn mui-btn--pagination" v-bind:class="page == objects_paginations.page ? 'mui-btn--primary' : 'mui-btn--flat'" v-on:click="get_data_and_show_from_objects(page)" v-bind:title="'страница ' + page">{{page}}</a></li>
          <li class="paginations_item"><a class="mui-btn mui-btn--flat mui-btn--pagination" v-on:click="get_data_and_show_from_objects(objects_paginations.next)" v-bind:title="'перейти к следующей странице ' + objects_paginations.next"><i class="fa fa-angle-right"></i></a></li>
          <li class="paginations_item"><a class="mui-btn mui-btn--flat mui-btn--pagination" v-on:click="get_data_and_show_from_objects(objects_paginations.last)" v-bind:title="'перейти к последней странице ' + objects_paginations.last"><i class="fa fa-angle-double-right"></i></a></li>
        </ul>
      </div>
    </div>

    <div class="mui-tabs__pane" id="pane-objects-search">
      <form class="mui-form--inline">
        <div class="mui-textfield">
          <input type="text" placeholder="НОМЕР АПС" v-model="number_find">
        </div>
        <div class="mui-textfield">
          <div class="mui-dropdown">
            <a class="mui-btn mui-btn--small" data-mui-toggle="dropdown" title="Фильтр по региону">регион <span class="light">{{region_id_find == null ? '' : region_id_find }}</span> <span class="mui-caret"></span></a>
            <ul class="mui-dropdown__menu mui-dropdown__menu_style1">
              <li><a v-on:click="region_id_find = null">&nbsp;</a></li>
              <li v-for="(name, id) in objects_helpers.regions"><a v-on:click="region_id_find = id"><span v-bind:class="region_id_find == id ? 'bold' : ''">{{name}}</span> <span class="light">- {{id}}</span></a></li>
            </ul>
          </div>
        </div>
        <div class="mui-textfield">
          <input type="text" placeholder="НАЗВАНИЕ ОБЪЕКТА" v-model="name_find">
        </div>
        <div class="mui-textfield">
          <input type="text" placeholder="АДРЕС ОБЪЕКТА" v-model="address_find">
        </div>
        <div class="mui-textfield">
          <div class="mui-dropdown">
            <a class="mui-btn mui-btn--small" data-mui-toggle="dropdown" title="Фильтр по номеру датчика">компания <span class="light">{{company_id_find == null ? '' : company_id_find }}</span> <span class="mui-caret"></span></a>
            <ul class="mui-dropdown__menu mui-dropdown__menu_style1">
              <li><a v-on:click="company_id_find = null">&nbsp;</a></li>
              <li v-for="(name, id) in objects_helpers.companies"><a v-on:click="company_id_find = id"><span v-bind:class="company_id_find == id ? 'bold' : ''">{{name}}</span></a></li>
            </ul>
          </div>
        </div>

        <a class="mui-btn mui-btn--primary mui-btn--small" v-on:click="find_data_and_show_from_objects(1, $event)">искать</a>
      </form>

      <div class="paginations" v-bind:class="Object.keys(objects_paginations_find).length == 0 ? 'hide' : ''">
        <ul class="paginations_wrap">
          <li class="paginations_item"><a class="mui-btn mui-btn--flat mui-btn--pagination" v-on:click="find_data_and_show_from_objects(objects_paginations_find.first)" v-bind:title="'перейти к первой странице ' + objects_paginations_find.first"><i class="fa fa-angle-double-left"></i></a></li>
          <li class="paginations_item"><a class="mui-btn mui-btn--flat mui-btn--pagination" v-on:click="find_data_and_show_from_objects(objects_paginations_find.prev)" v-bind:title="'перейти к предыдущей странице ' + objects_paginations_find.prev"><i class="fa fa-angle-left"></i></a></li>
          <li class="paginations_item" v-for="page in objects_paginations_find.pages"><a class="mui-btn mui-btn--pagination" v-bind:class="page == objects_paginations_find.page ? 'mui-btn--primary' : 'mui-btn--flat'" v-on:click="find_data_and_show_from_objects(page)" v-bind:title="'страница ' + page">{{page}}</a></li>
          <li class="paginations_item"><a class="mui-btn mui-btn--flat mui-btn--pagination" v-on:click="find_data_and_show_from_objects(objects_paginations_find.next)" v-bind:title="'перейти к следующей странице ' + objects_paginations_find.next"><i class="fa fa-angle-right"></i></a></li>
          <li class="paginations_item"><a class="mui-btn mui-btn--flat mui-btn--pagination" v-on:click="find_data_and_show_from_objects(objects_paginations_find.last)" v-bind:title="'перейти к последней странице ' + objects_paginations_find.last"><i class="fa fa-angle-double-right"></i></a></li>
        </ul>
      </div>

      <table class="mui-table mui-table--bordered" v-bind:class="objects_list_find.length == 0 ? 'hide' : ''">
        <thead>
          <tr>
            <th>ID</th>
            <th title="Номер устройства">Номер У</th>
            <th title="Номер региона">Номер Р</th>
            <th>Регион</th>
            <th>Название</th>
            <th title="Наличие описания">О</th>
            <th title="Наличие координат">К</th>
            <th title="Наличие устройства">У</th>
            <th title="Состояние АПС">А</th>
            <th title="Наличие договора">Д</th>
            <th>Действия</th>
          </tr>
        </thead>
        <tfoot>
          <tr>
            <th>ID</th>
            <th title="Номер устройства">Номер У</th>
            <th title="Номер региона">Номер Р</th>
            <th>Регион</th>
            <th>Название</th>
            <th title="Наличие описания">О</th>
            <th title="Наличие координат">К</th>
            <th title="Наличие устройства">У</th>
            <th title="Состояние АПС">А</th>
            <th title="Наличие договора">Д</th>
            <th>Действия</th>
          </tr>
        </tfoot>
        <tbody>
          <tr v-for="object in objects_list_find">
            <td>{{object.id}}</td>
            <td title="Номер устройства">{{object.number}}</td>
            <td title="Номер региона">{{object.region_id}}</td>
            <td>{{object.region}}</td>
            <td>{{object.name}}</td>
            <td title="Наличие описания">
              <i class="fa" v-bind:class="object.has_object ? 'fa-check-square-o' : 'fa-square-o'"></i>
            </td>
            <td title="Наличие координат">
              <i class="fa" v-bind:class="object.has_address ? 'fa-check-square-o' : 'fa-square-o'"></i>
            </td>
            <td title="Наличие устройства">
              <i class="fa" v-bind:class="object.has_device ? 'fa-check-square-o' : 'fa-square-o'"></i>
            </td>
            <td title="Состояние АПС" class="marker_in_table">
              <i class="fa fa-square" v-bind:class="'marker_state_' + object.state_id"></i>
            </td>
            <td title="Наличие договора">
              <i class="fa" v-bind:class="object.dogovor ? 'fa-check-square-o' : 'fa-square-o'"></i>
            </td>
            <td style="padding: 0;">
              <a class="mui-btn mui-btn--flat mui-btn--small margin-0" v-on:click="show_edit_form_for_object(object.id)" v-bind:title="'редактировать страницу ' + object.id"><i class="fa fa-pencil"></i></a>
              <a class="mui-btn mui-btn--flat mui-btn--small margin-0" v-on:click="change_relation_object_company(object.id)" v-bind:title="object.company_id === null ? 'привязать объект [' + object.id + '] к фирме' : 'отвязать объект [' + object.id + '] от фирмы ' + object.company"><i class="fa" v-bind:class="object.company_id === null ? 'fa-user-plus gray' : 'fa-user-times red'"></i></a>
            </td>
          </tr>
        </tbody>
      </table>

      <div class="paginations" v-bind:class="Object.keys(objects_paginations_find).length == 0 ? 'hide' : ''">
        <ul class="paginations_wrap">
          <li class="paginations_item"><a class="mui-btn mui-btn--flat mui-btn--pagination" v-on:click="find_data_and_show_from_objects(objects_paginations_find.first)" v-bind:title="'перейти к первой странице ' + objects_paginations_find.first"><i class="fa fa-angle-double-left"></i></a></li>
          <li class="paginations_item"><a class="mui-btn mui-btn--flat mui-btn--pagination" v-on:click="find_data_and_show_from_objects(objects_paginations_find.prev)" v-bind:title="'перейти к предыдущей странице ' + objects_paginations_find.prev"><i class="fa fa-angle-left"></i></a></li>
          <li class="paginations_item" v-for="page in objects_paginations_find.pages"><a class="mui-btn mui-btn--pagination" v-bind:class="page == objects_paginations_find.page ? 'mui-btn--primary' : 'mui-btn--flat'" v-on:click="find_data_and_show_from_objects(page)" v-bind:title="'страница ' + page">{{page}}</a></li>
          <li class="paginations_item"><a class="mui-btn mui-btn--flat mui-btn--pagination" v-on:click="find_data_and_show_from_objects(objects_paginations_find.next)" v-bind:title="'перейти к следующей странице ' + objects_paginations_find.next"><i class="fa fa-angle-right"></i></a></li>
          <li class="paginations_item"><a class="mui-btn mui-btn--flat mui-btn--pagination" v-on:click="find_data_and_show_from_objects(objects_paginations_find.last)" v-bind:title="'перейти к последней странице ' + objects_paginations_find.last"><i class="fa fa-angle-double-right"></i></a></li>
        </ul>
      </div>
    </div>
  </div>

  <div class="mui-tabs__pane" id="pane-companies">
    <div>
      <button class="mui-btn mui-btn--flat" v-on:click="show_panel_part('companies')" title="обновить список">
        <i class="fa fa-refresh"></i>
      </button>
      <button class="mui-btn mui-btn--flat" v-on:click="create_company_and_show_form" title="добавить компанию">
        <i class="fa fa-plus"></i>
        новая
      </button>
    </div>

    <table class="mui-table mui-table--bordered">
      <thead>
        <tr>
          <th>ID</td>
          <th>Название</td>
          <th>Телефон</td>
          <th>Сайт</td>
          <th>Email</td>
          <th>Адрес</td>
          <th>Руководитель</td>
          <th title="Наличие привязки к пользователю">П</th>
          <th title="Наличие координат">К</th>
          <th>Действия</td>
        </tr>
      </thead>
      <tfoot>
        <tr>
          <th>ID</td>
          <th>Название</td>
          <th>Телефон</td>
          <th>Сайт</td>
          <th>Email</td>
          <th>Адрес</td>
          <th>Руководитель</td>
          <th title="Наличие привязки к пользователю">П</th>
          <th title="Наличие координат">К</th>
          <th>Действия</td>
        </tr>
      </tfoot>
      <tbody>
        <tr v-for="company in companies_list">
          <td>{{company.id}}</td>
          <td>{{company.title}}</td>
          <td>{{company.phone}}</td>
          <td>
            <a v-bind:href="company.site" target="_blank">
              {{company.site}}
            </a>
          </td>
          <td>{{company.email}}</td>
          <td>{{company.address}}</td>
          <td>{{company.person}}</td>
          <td v-bind:title="company.user_id != null ? 'Компания привязана к пользователю ' + company.user : ''">
            <i class="fa" v-bind:class="company.user_id != null ? 'fa-check-square-o' : 'fa-square-o'"></i>
          </td>
          <td title="Наличие координат">
            <i class="fa" v-bind:class="company.has_address ? 'fa-check-square-o' : 'fa-square-o'"></i>
          </td>
          <td style="padding: 0;">
            <a class="mui-btn mui-btn--flat mui-btn--small margin-0" v-on:click="show_edit_form_for_company(company.id)" v-bind:title="'редактировать компанию ' + company.id"><i class="fa fa-pencil"></i></a>
            <a class="mui-btn mui-btn--flat mui-btn--small margin-0" v-on:click="delete_for_company(company.id)" v-bind:data-id="company.id" v-bind:title="'удалить компанию ' + company.id"><i class="fa fa-trash-o"></i></a>
          </td>
        </tr>
      </tbody>
    </table>
  </div>

  <div class="mui-tabs__pane" id="pane-lists">
    <ul class="mui-tabs__bar">
      <li class="mui--is-active">
        <a data-mui-toggle="tab" data-mui-controls="pane-class_fps">Классы функциональной пожарной опасности</a>
      </li>
      <li>
        <a data-mui-toggle="tab" data-mui-controls="pane-departments">Ведомства</a>
      </li>
      <li>
        <a data-mui-toggle="tab" data-mui-controls="pane-types">Типы объектов</a>
      </li>
      <li>
        <a data-mui-toggle="tab" data-mui-controls="pane-services">Услуги</a>
      </li>
    </ul>

    <div class="mui-tabs__pane mui--is-active" id="pane-class_fps">
      <table class="mui-table mui-table--bordered">
        <thead>
          <tr>
            <th>ID</th>
            <th>Значение</th>
            <th>Действия</th>
          </tr>
        </thead>
        <tfoot>
          <tr>
            <th>ID</th>
            <th>Значение</th>
            <th>Действия</th>
          </tr>
        </tfoot>
        <tbody>
          <tr v-for="(value, id) in class_fps_lists">
            <td>{{id}}</td>
            <td>{{value}}</td>
            <td style="padding: 0;">
              <a class="mui-btn mui-btn--flat mui-btn--small margin-0" v-on:click="show_edit_form_for_list(id)" title="редактировать значение справочника"><i class="fa fa-pencil"></i></a>
              <a class="mui-btn mui-btn--flat mui-btn--small margin-0" title="удалить значение справочника"><i class="fa fa-trash-o"></i></a>
            </td>
          </tr>
      </table>
    </div>

    <div class="mui-tabs__pane" id="pane-departments">
      <table class="mui-table mui-table--bordered">
        <thead>
          <tr>
            <th>ID</th>
            <th>Значение</th>
            <th>Действия</th>
          </tr>
        </thead>
        <tfoot>
          <tr>
            <th>ID</th>
            <th>Значение</th>
            <th>Действия</th>
          </tr>
        </tfoot>
        <tbody>
          <tr v-for="(value, id) in departments_lists">
            <td>{{id}}</td>
            <td>{{value}}</td>
            <td style="padding: 0;">
              <a class="mui-btn mui-btn--flat mui-btn--small margin-0" v-on:click="show_edit_form_for_list(id)" title="редактировать значение справочника"><i class="fa fa-pencil"></i></a>
              <a class="mui-btn mui-btn--flat mui-btn--small margin-0" title="удалить значение справочника"><i class="fa fa-trash-o"></i></a>
            </td>
          </tr>
      </table>
    </div>

    <div class="mui-tabs__pane" id="pane-types">
      <table class="mui-table mui-table--bordered">
        <thead>
          <tr>
            <th>ID</th>
            <th>Значение</th>
            <th>Действия</th>
          </tr>
        </thead>
        <tfoot>
          <tr>
            <th>ID</th>
            <th>Значение</th>
            <th>Действия</th>
          </tr>
        </tfoot>
        <tbody>
          <tr v-for="(value, id) in types_lists">
            <td>{{id}}</td>
            <td>{{value}}</td>
            <td style="padding: 0;">
              <a class="mui-btn mui-btn--flat mui-btn--small margin-0" v-on:click="show_edit_form_for_list(id)" title="редактировать значение справочника"><i class="fa fa-pencil"></i></a>
              <a class="mui-btn mui-btn--flat mui-btn--small margin-0" title="удалить значение справочника"><i class="fa fa-trash-o"></i></a>
            </td>
          </tr>
      </table>
    </div>

    <div class="mui-tabs__pane" id="pane-services">
      <table class="mui-table mui-table--bordered">
        <thead>
          <tr>
            <th>ID</th>
            <th>Значение</th>
            <th>Действия</th>
          </tr>
        </thead>
        <tfoot>
          <tr>
            <th>ID</th>
            <th>Значение</th>
            <th>Действия</th>
          </tr>
        </tfoot>
        <tbody>
          <tr v-for="(value, id) in services_lists">
            <td>{{id}}</td>
            <td>{{value}}</td>
            <td style="padding: 0;">
              <a class="mui-btn mui-btn--flat mui-btn--small margin-0" v-on:click="show_edit_form_for_list(id)" title="редактировать значение справочника"><i class="fa fa-pencil"></i></a>
              <a class="mui-btn mui-btn--flat mui-btn--small margin-0" title="удалить значение справочника"><i class="fa fa-trash-o"></i></a>
            </td>
          </tr>
      </table>
    </div>

  </div>


  <div class="mui-tabs__pane" id="pane-users">
    <div>
      <button class="mui-btn mui-btn--flat" v-on:click="show_panel_part('users')" title="обновить список">
        <i class="fa fa-refresh"></i>
      </button>
    </div>

    <table class="mui-table mui-table--bordered">
      <thead>
        <tr>
          <th>ID</th>
          <th>Фамилия Имя Отчество</th>
          <th>Логин</th>
          <th>Email</th>
          <th>Роль</th>
          <th>Действия</th>
        </tr>
      </thead>
      <tfoot>
        <tr>
          <th>ID</th>
          <th>Фамилия Имя Отчество</th>
          <th>Логин</th>
          <th>Email</th>
          <th>Роль</th>
          <th>Действия</th>
        </tr>
      </tfoot>
      <tbody>
        <tr v-for="user in users_list">
          <td>{{user.id}}</td>
          <td>{{user.fio}}</td>
          <td>{{user.login}}</td>
          <td>{{user.email}}</td>
          <td>{{user.role}}</td>
          <td style="padding: 0;">
            <a class="mui-btn mui-btn--flat mui-btn--small margin-0" v-on:click="show_edit_form_for_user(user.id)" v-bind:title="'редактировать пользователя ' + user.login"><i class="fa fa-pencil"></i></a>
            <a class="mui-btn mui-btn--flat mui-btn--small margin-0" v-on:click="delete_for_user(user.id)" v-bind:title="'удалить пользователя ' + user.login"><i class="fa fa-trash-o"></i></a>
            <a class="mui-btn mui-btn--flat mui-btn--small margin-0" v-on:click="toggle_for_user(user.id)" v-bind:title="'переключить пользователя ' + user.login"><i class="fa" v-bind:class="user.isenabled ? 'fa-toggle-on' : 'fa-toggle-off'"></i></a>
          </td>
        </tr>
      </tbody>
    </table>
  </div>

  <div class="mui-tabs__pane" id="pane-pages">
    <div>
      <button class="mui-btn mui-btn--flat" v-on:click="create_page_and_show_form">
        <i class="fa fa-plus"></i>
        новая
      </button>
    </div>

    <table class="mui-table mui-table--bordered">
      <thead>
        <tr>
          <th>ID</th>
          <th>URN</th>
          <th>Заголовок</th>
          <th>Действия</th>
        </tr>
      </thead>
      <tfoot>
        <tr>
          <th>ID</th>
          <th>URN</th>
          <th>Заголовок</th>
          <th>Действия</th>
        </tr>
      </tfoot>
      <tbody>
        <tr v-for="page in pages_list">
          <td>{{page.id}}</td>
          <td>{{page.name}}</td>
          <td>{{page.title}}</td>
          <td style="padding: 0;">
            <a class="mui-btn mui-btn--flat mui-btn--small margin-0" v-on:click="show_edit_form_for_page(page.id)" v-bind:title="'редактировать страницу ' + page.name"><i class="fa fa-pencil"></i></a>
            <a class="mui-btn mui-btn--flat mui-btn--small margin-0" v-on:click="delete_for_page(page.id)" v-bind:title="'удалить страницу ' + page.name"><i class="fa fa-trash-o"></i></a>
            <a class="mui-btn mui-btn--flat mui-btn--small margin-0" v-on:click="toggle_for_page(page.id)" v-bind:title="'включить/отключить страницу ' + page.name"><i class="fa" v-bind:class="page.enabled ? 'fa-toggle-on' : 'fa-toggle-off'"></i></a>
            <a class="mui-btn mui-btn--flat mui-btn--small margin-0" v-bind:href="'/map/page/' + page.name" target="_blank" v-bind:title="'ссылка на страницу ' + page.name"><i class="fa fa-link"></i></a>
          </td>
        </tr>
      </tbody>
    </table>
  </div>

  <div class="form_for_edit" v-bind:class="form.edit.page.class">
    <div class="form_for_edit_wrap">
      <div class="head">
        <h2>Редактирование страницы: {{form.edit.page.model.title}}</h2>
      </div>

      <div class="body">
        <div class="body_left">

          <div class="mui-container-fluid">
            <div class="mui-row">
              <div class="mui-col-md-12">

                <form class="mui-form">
                  <div class="mui-textfield">
                    <input v-model="form.edit.page.model.name" type="text" placeholder="например - documents">
                    <label>URI страницы. Страница будет доступна по
                      <a v-bind:href="'/map/page/' + form.edit.page.model.name" target="_blank">ссылке</a>
                    </label>
                  </div>
                  <div class="mui-textfield">
                    <input v-model="form.edit.page.model.title" type="text" placeholder="текст заголовка">
                    <label>Заголовок</label>
                  </div>
                  <div class="mui-textfield">
                    <div class="textarea_wrap">
                      <textarea v-model="form.edit.page.model.content"></textarea>
                    </div>
                    <label>
                      Контент страницы в markdown формате
                      <a href="https://ru.wikipedia.org/wiki/Markdown" target="_blank">(описание)</a>
                    </label>
                  </div>
                  <div class="mui-checkbox">
                    <label>
                      <input v-model="form.edit.page.model.enabled" type="checkbox">
                      Включить/Выключить отображение страницы
                    </label>
                  </div>
                </form>

              </div>
            </div>
          </div>

        </div>

        <div class="body_right">
          <p style="color: rgba(0, 0, 0, 0.54);">Внешний вид контента на странице</p>
          <div v-html="page_content_markdown"></div>
        </div>
      </div>

      <hr>

      <ul class="messages">
        <li class="messages_item" v-for="message in form.edit.page.messages">{{message}}</li>
      </ul>

      <ul class="errors">
        <li class="errors_item" v-for="error in form.edit.page.errors">{{error}}</li>
      </ul>

      <div class="footer">
        <button class="mui-btn mui-btn--raised mui-btn--primary" v-on:click="save_page"><i class="fa fa-floppy-o"></i> сохранить</button>
        <button class="mui-btn mui-btn--raised" v-on:click="close_edit_form_for_page"><i class="fa fa-times"></i> закрыть</button>
      </div>
    </div>
  </div>

  <div class="form_for_edit" v-bind:class="form.edit.user.class">
    <div class="form_for_edit_wrap">
      <div class="head">
        <h2>Редактирование пользователя: {{form.edit.user.model.login}}</h2>
      </div>

      <div class="mui-container-fluid">
        <div class="mui-row">
          <div class="mui-col-md-6">

            <form class="mui-form">
              <div class="mui-textfield">
                <input v-model="form.edit.user.model.fio" type="text" placeholder="например - Иванов Иван Иванович">
                <label>Фамилия Имя Отчество</label>
              </div>
              <div class="mui-textfield">
                <input v-model="form.edit.user.model.email" type="text" placeholder="email">
                <label>Email</label>
              </div>
              <div class="mui-textfield">
                <input v-model="form.edit.user.model.phone" type="text" placeholder="Телефон">
                <label>Телефон</label>
              </div>
              <div class="mui-checkbox">
                <label>
                  <input v-model="form.edit.user.model.isenabled" type="checkbox">
                  Включить/Выключить пользователя
                </label>
              </div>
            </form>

          </div>

          <div class="mui-col-md-6">

            <form class="mui-form">
              <div class="mui-textfield" v-if="user.role_id == 1">
                <div class="mui-dropdown">
                  <a class="mui-btn mui-btn--small" data-mui-toggle="dropdown" title="Выбрать роль пользователя">роль <span class="light">{{form.edit.user.model.role_id == null ? '' : form.edit.user.model.role }}</span> <span class="mui-caret"></span></a>
                  <ul class="mui-dropdown__menu mui-dropdown__menu_style1">
                    <li v-for="(name, id) in users_helpers.roles"><a v-on:click="form.edit.user.model.role_id = id; form.edit.user.model.role = name;">{{name}}</a></li>
                  </ul>
                </div>
              </div>
              <div class="mui-textfield" v-if="user.role_id == 1">
                <div class="mui-dropdown">
                  <p>Компания: {{form.edit.user.model.company}}</p>
                  <a class="mui-btn mui-btn--small" data-mui-toggle="dropdown" title="Привязать компанию к учётной записи">компания <span class="mui-caret"></span></a>
                  <ul class="mui-dropdown__menu mui-dropdown__menu_style1">
                    <li><a v-on:click="change_company_for_user(null, null)">&nbsp;</a></li>
                    <li v-for="(name, id) in users_helpers.companies"><a v-on:click="change_company_for_user(id, name)">{{name}}</a></li>
                  </ul>
                </div>
              </div>
            </form>

          </div>
        </div>
      </div>

      <hr>

      <ul class="messages">
        <li class="messages_item" v-for="message in form.edit.user.messages">{{message}}</li>
      </ul>

      <ul class="errors">
        <li class="errors_item" v-for="error in form.edit.user.errors">{{error}}</li>
      </ul>

      <div class="footer">
        <button class="mui-btn mui-btn--raised mui-btn--primary" v-on:click="save_user"><i class="fa fa-floppy-o"></i> сохранить</button>
        <button class="mui-btn mui-btn--raised" v-on:click="close_edit_form_for_user"><i class="fa fa-times"></i> закрыть</button>
      </div>
    </div>
  </div>

  <div class="form_for_edit" v-bind:class="form.edit.object.class">
    <div class="form_for_edit_wrap">
      <div class="head">
        <h2>Редактирование объекта: {{form.edit.object.model.name}}</h2>
      </div>

      <div class="body" style="display: block;">
        <div class="mui-container-fluid">
          <div class="mui-row">
            <div class="mui-col-md-6">
              <form class="mui-form">

                <div class="mui-textfield">
                  <span class="marker" title="Состояние АПС">
                    <i class="fa fa-square" v-bind:class="'marker_state_' + form.edit.object.model.state_id"></i>
                    Состояние АПС
                  </span>
                  <span class="marker" title="Наличие объекта">
                    <i class="fa" v-bind:class="form.edit.object.model.has_object ? 'fa-check-square-o' : 'fa-square-o'"></i>
                    Наличие объекта
                  </span>
                  <span class="marker" title="Наличие координат">
                    <i class="fa" v-bind:class="form.edit.object.model.has_address ? 'fa-check-square-o' : 'fa-square-o'"></i>
                    Наличие координат
                  </span>
                  <span class="marker" title="Наличие устройства">
                    <i class="fa" v-bind:class="form.edit.object.model.has_device ? 'fa-check-square-o' : 'fa-square-o'"></i>
                    Наличие устройства
                  </span>
                </div>

                <div class="mui-textfield">
                  <input type="text" placeholder="Телефон" v-model="form.edit.object.model.name">
                  <label>Название</label>
                </div>
                <div class="mui-textfield">
                  <input type="text" placeholder="Ответственное лицо" v-model="form.edit.object.model.person">
                  <label>Ответственное лицо</label>
                </div>
                <div class="mui-textfield">
                  <input type="text" placeholder="Адрес" v-model="form.edit.object.model.address">
                  <label>Адрес</label>
                </div>
                <div class="mui-checkbox">
                  <label>
                    <input v-model="form.edit.object.model.dogovor" type="checkbox">
                    Включить/Выключить наличие договора
                  </label>
                </div>
                <div class="mui-textfield" v-if="form.edit.object.model.number !== null">
                  <label>Координаты</label>
                  <div>
                    <span>LAT:</span> {{form.edit.object.model.lat}}
                    x
                    <span>LNG:</span> {{form.edit.object.model.lng}}
                  </div>
                  <div>
                    <a class="mui-btn mui-btn--raised mui-btn--small mui-btn--primary" v-on:click="show_change_point_map">
                      <i class="fa fa-map-marker"></i>
                    </a>
                    Указать положение датчика {{form.edit.object.model.number}} на карте
                  </div>
                  <div>
                    <a class="mui-btn mui-btn--raised mui-btn--small" v-on:click="form.edit.object.model.lat = null; form.edit.object.model.lng = null;">
                      <i class="fa fa-times"></i>
                    </a>
                    Убрать положение датчика {{form.edit.object.model.number}} на карте
                  </div>
                </div>
              </form>
            </div>
            <div class="mui-col-md-6">
              <div class="mui-textfield">
                <textarea class="textarea_style2" v-model="form.edit.object.model.phone"></textarea>
                <label>Телефон</label>
              </div>
              <div class="mui-textfield">
                <textarea class="textarea_style2" v-model="form.edit.object.model.description"></textarea>
                <label>Описание</label>
              </div>
            </div>
          </div>
        </div>
      </div>

      <hr>

      <ul class="messages">
        <li class="messages_item" v-for="message in form.edit.object.messages">{{message}}</li>
      </ul>

      <ul class="errors">
        <li class="errors_item" v-for="error in form.edit.object.errors">{{error}}</li>
      </ul>

      <div class="footer">
        <button class="mui-btn mui-btn--raised mui-btn--primary" v-on:click="save_object"><i class="fa fa-floppy-o"></i> сохранить</button>
        <button class="mui-btn mui-btn--raised" v-on:click="close_edit_form_for_object"><i class="fa fa-times"></i> закрыть</button>
      </div>
    </div>
  </div>

  <div class="form_for_edit" v-bind:class="form.edit.company.class">
    <div class="form_for_edit_wrap">
      <div class="head">
        <h2>Редактирование компании: {{form.edit.company.model.title}}</h2>
      </div>

      <div class="body" style="display: block;">
        <div class="mui-container-fluid">
          <div class="mui-row">
            <div class="mui-col-md-6">
              <form class="mui-form">
                <div class="mui-textfield">
                  <input type="text" placeholder="Название" v-model="form.edit.company.model.title">
                  <label>Название</label>
                </div>
                <div class="mui-textfield">
                  <input type="text" placeholder="Руководитель" v-model="form.edit.company.model.person">
                  <label>Руководитель</label>
                </div>
                <div class="mui-textfield">
                  <input type="text" placeholder="Email" v-model="form.edit.company.model.email">
                  <label>Email</label>
                </div>
                <div class="mui-textfield">
                  <input type="text" placeholder="Адрес" v-model="form.edit.company.model.address">
                  <label>Адрес</label>
                </div>
                <div class="mui-textfield">
                  <input type="text" placeholder="Телефон" v-model="form.edit.company.model.phone">
                  <label>Телефон</label>
                </div>
                <div class="mui-textfield">
                  <input type="text" placeholder="Официальный сайт" v-model="form.edit.company.model.link">
                  <label>Официальный сайт</label>
                </div>
              </form>
            </div>
            <div class="mui-col-md-6">
            </div>
          </div>
        </div>
      </div>

      <hr>

      <ul class="messages">
        <li class="messages_item" v-for="message in form.edit.company.messages">{{message}}</li>
      </ul>

      <ul class="errors">
        <li class="errors_item" v-for="error in form.edit.company.errors">{{error}}</li>
      </ul>

      <div class="footer">
        <button class="mui-btn mui-btn--raised mui-btn--primary" v-on:click="save_company"><i class="fa fa-floppy-o"></i> сохранить</button>
        <button class="mui-btn mui-btn--raised" v-on:click="close_edit_form_for_company"><i class="fa fa-times"></i> закрыть</button>
      </div>
    </div>
  </div>
</div>
