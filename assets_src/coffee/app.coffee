DEBUG=false
TIMERS={}
TRIGGERS={}

RELOAD = window.RELOAD =
  css: (name, cb) ->
    css_dom = document.querySelector "link[href^=\"/assets/css/#{name}\"]"
    if css_dom
      css_dom.remove()
      reload_css = document.createElement 'link'
      reload_css.rel = "stylesheet"
      reload_css.type = "text/css"
      reload_css.media = "all"
      _href = "/assets/css/#{name}.css?#{new Date().getTime()}"
      reload_css.href = _href
      reload_css.onload = ->
        if cb then cb()
        return

      document.body.append reload_css
    return


document.addEventListener "click", (event) ->
  if TRIGGERS['panel']?
    return

  if TIMERS['dropdown']?
    clearTimeout TIMERS.dropdown
    TIMERS.dropdown = null

  TIMERS.dropdown = setTimeout ->
    items = [].slice.call document.querySelectorAll('.mui--is-open')
    if items.length > 0
      document.body.style.overflow = "hidden"
    else
      document.body.style.overflow = ""
    return
  , 200
  return


document.addEventListener "DOMContentLoaded", (event) ->
  Preloader.label 'добро пожаловать в систему RISKI'

  map_dom = document.getElementById 'map'
  if map_dom
    if map_dom.dataset.yanmapapi
      yscript = document.createElement 'script'
      yscript.src = "https://api-maps.yandex.ru/2.1?lang=ru_RU&apikey=#{map_dom.dataset.yanmapapi}"
      yscript.onload = ->
        main()
        return

      yscript.onerror = ->
        console.log "load error:"
        main()
        return

      document.body.appendChild yscript

    else
      main()

  else
    main()
  return


point_was_changed = ->
  console.log "point_was_changed"
  if PMap
    if window.point_temp
      PMap.geoObjects.remove window.point_temp

  Bus.$emit "pointWasChangedRun"
  return


window.addEventListener 'load', (event) ->
  Preloader.label "переключаем интерфейс"
  setTimeout ->
    Preloader.disable()

    YMap = window.YMap or null
    if YMap
      YMap.container.fitToViewport()

  , 300
  return


getJsonData = (url, cb) ->
  if DEBUG
    console.log "getJsonData run:", url

  $.ajax
    url: url
    type: 'GET'
    contentType: "application/json; charset=utf-8"
    cache: true
    success: (res) ->
      if DEBUG
        console.log "getJsonData res:", res

      if res.data["code"]?
        if res.data.code == 1
          Bus.$emit 'modal_info_show_auth_run'

      if cb then cb res
      return
    error: (err) ->
      console.error err
      return
  return

postJsonData = (url, cb) ->
  if DEBUG
    console.log "postJsonData run:", url

  $.ajax
    url: url
    type: 'POST'
    contentType: "application/json; charset=utf-8"
    cache: true
    success: (res) ->
      if DEBUG
        console.log "postJsonData res:", res

      if res.data["code"]?
        if res.data.code == 1
          Bus.$emit 'modal_info_show_auth_run'

      if cb then cb res
      return

    error: (err) ->
      console.error err
      return
  return

postJsonWithData = (url, data, cb) ->
  if DEBUG
    console.log "postJsonWithData run:", data

  $.ajax
    url: url
    type: 'POST'
    contentType: "application/json; charset=utf-8"
    dataType: 'json'
    data: JSON.stringify(data)
    cache: true
    success: (res) ->
      if DEBUG
        console.log "postJsonWithData res:", res

      if res.data["code"]?
        if res.data.code == 1
          Bus.$emit 'modal_info_show_auth_run'

      if cb then cb res
      return

    error: (err) ->
      console.error err
      return
  return


class Filter
  constructor: ->
    @filters =
      or: {}
      or2: {}
      and: {}
      and2: {}
      orand: {}
      andor: {}

  @new: ->
    filter = new Filter()
    filter

  add: (type_group, name, params_name, condition, value) ->
    if type_group is 'orand'
      if @filters[type_group].hasOwnProperty(name)
        @filters[type_group][name].push ["properties.#{params_name}", condition, value]
      else
        @filters[type_group][name] = []
        @filters[type_group][name].push ["properties.#{params_name}", condition, value]

    else if type_group is 'andor'
      if @filters[type_group].hasOwnProperty(name)
        @filters[type_group][name].push ["properties.#{params_name}", condition, value]
      else
        @filters[type_group][name] = []
        @filters[type_group][name].push ["properties.#{params_name}", condition, value]

    else
      @filters[type_group][name] = ["properties.#{params_name}", condition, value]

    @

  remove: (type_group, name, value, inverse) ->
    inverse = inverse ? false
    self = @
    if type_group is 'orand'
      delete self.filters[type_group][name]
      #to_remove_index = []
      #for row, index in @filters[type_group][name]
        #do (row, index, value) ->
          #if inverse
            #if row[0] is ["properties", value].join('.')
              #to_remove_index.push index

          #else
            #if row[2] is value
              #to_remove_index.push index
          #return

      #for index in to_remove_index
        #do (index) ->
          #self.filters[type_group][name].splice index, 1
          #return

      #if @filters[type_group][name].length is 0
        #delete @filters[type_group][name]

    else if type_group is 'andor'
      to_remove_index = []
      for row, index in @filters[type_group][name]
        do (row, index, value) ->
          if inverse
            if row[0] is ["properties", value].join('.')
              to_remove_index.push index
          else
            if row[2] is value
              to_remove_index.push index
          return

      for index in to_remove_index
        do (index) ->
          self.filters[type_group][name].splice index, 1
          return

      if @filters[type_group][name].length is 0
        delete @filters[type_group][name]

    else
      try
        delete @filters[type_group][name]
    @

  reset: ->
    @filters =
      or: {}
      or2: {}
      and: {}
      and2: {}
      orand: {}
      andor: {}
    return

  names: ->
    return {
      and: Object.keys(@filters.and)
      and2: Object.keys(@filters.and2)
      or: Object.keys(@filters.or)
      or2: Object.keys(@filters.or2)
      orand: Object.keys(@filters.orand)
      andor: Object.keys(@filters.andor)
    }

  query: ->
    query = []
    query_or = []
    query_or2 = []
    query_and = []
    query_and2 = []
    query_orand = []
    query_andor = []

    for name, value of @filters.or
      query_or.push @filters.or[name].join(' ')

    for name, value of @filters.or2
      query_or2.push @filters.or2[name].join(' ')

    for name, value of @filters.and
      query_and.push @filters.and[name].join(' ')

    for name, value of @filters.and2
      query_and2.push @filters.and2[name].join(' ')

    p = null
    s = null
    d = []
    for name, value of @filters.orand
      p = []
      for v in value
        do (v) ->
          p.push v.join(' ')
          return

      s = "(#{p.join(' && ')})"
      d.push s

    dd = "(#{d.join(' || ')})"


    p = null
    s = null
    x = []
    for name, value of @filters.andor
      p = []
      for v in value
        do (v) ->
          p.push v.join(' ')
          return

      s = "(#{p.join(' || ')})"
      x.push s

    xx = "(#{x.join(' && ')})"


    if query_or.length > 0
      _q_or = "(#{query_or.join(' || ')})"
    else
      _q_or = true

    if query_or2.length > 0
      _q_or2 = "(#{query_or2.join(' || ')})"
    else
      _q_or2 = true

    if query_and.length > 0
      _q_and = "(#{query_and.join(' && ')})"
    else
      _q_and = true

    if query_and2.length > 0
      _q_and2 = "(#{query_and2.join(' && ')})"
    else
      _q_and2 = true


    query = [
      _q_or
      _q_and
      _q_or2
      _q_and2
    ]

    qq = query.join(' && ')

    if d.length > 0
      qq += " && #{dd}"

    if x.length > 0
      qq += " && #{xx}"

    qq

  make: ->
    unless typeof(ObjectManagerGroup) is 'undefined'
      ObjectManagerGroup.setFilter @query()
    @

Preloader = window.Preloader =
  disable: ->
    preload_dom = document.querySelector '[data-window="preloader"]'
    preload_dom.classList.add "animated", "fadeOut"
    setTimeout ->
      preload_dom.classList.add 'hide'
    , 1100
    return

  enable: ->
    preload_dom = document.querySelector '[data-window="preloader"]'
    preload_dom.classList.remove "fadeOut"
    preload_dom.classList.add "animated", "fadeIn"
    preload_dom.classList.remove 'hide'
    return

  label: (text) ->
    label = document.querySelector "[data-label=\"preloader\"]"
    label.textContent = text
    return


Bus = new Vue()

tools_data_app =
  data: ->
    _data = window._tdata =
      stats:
        "1": 0
        "2": 0
        "3": 0
        "4": 0
      buttons:
        state_icons:
          st1:
            "fa-circle": true
            "fa-circle-o": false
          st2:
            "fa-circle": true
            "fa-circle-o": false
          st3:
            "fa-circle": true
            "fa-circle-o": false
          dogovors:
            "fa-square": false
            "fa-square-o": true
          companies:
            "fa-circle": false
            "fa-circle-o": true
      panel:
        first:
          class:
            hide: true
        second:
          class:
            hide: true
        third:
          class:
            hide: true
      filters:
        states:
          "1": true
          "2": true
          "3": true
          "4": true
          count: 0
        companies:
          toggle: false
          alreadyInGroup: false
        dogovors:
          toggle: false
          alreadyInGroup: false
      row:
        id: ""
        number: ""
        name: ""
        description: ""
        region_id: ""
        address: ""
        state: ""
        state_id: ""
      modalClass:
        hide: true
      modalInfoClass:
        hide: true
      modal_info:
        title: ""
        stats: false
        auth: false
        panel: false
        filter: false
      numbers: []
      numbers_in_filters: []
      stats: {}
      timers: {}

      class_fps: {}
      class_fps_changed: {}
      departments: {}
      departments_changed: {}
      types: {}
      types_changed: {}
      companies: {}
      companies_changed: {}
      services: {}
      services_changed: {}
      regions: {}
      regions_changed: {}

      object_names: []
      object_names_in_filters: []
      ch_counter_objects_state: null
      ch_counter_objects: null
      ch_counter_catalogs: null

      user: {}
      point_temp: null

    window._data = _data
    _data

  template: null

  methods:
    toggle_panel_all: ->
      if @panel.first.class.hide is false or @panel.second.class.hide is false or @panel.third.class.hide is false
        @panel.first.class.hide = true
        @panel.second.class.hide = true
        @panel.third.class.hide = true
      else
        @panel.first.class.hide = false
      return

    toggle_panel_first: ->
      switch @panel.first.class.hide
        when true
          @panel.first.class.hide = false
        when false
          @panel.first.class.hide = true
      return

    toggle_panel_second: ->
      switch @panel.second.class.hide
        when true
          @panel.second.class.hide = false
        when false
          @panel.second.class.hide = true
      return

    toggle_panel_third: ->
      switch @panel.third.class.hide
        when true
          @panel.third.class.hide = false
          @panel.first.class.hide = true
          document.querySelector("[data-target=\"search_with_name_object\"]").focus()
        when false
          @panel.third.class.hide = true
          @panel.first.class.hide = false
      return

    modal_info_show: (need) ->
      self = @

      if need is 'stats'
        @loadStatsData ->
          self.modal_info.title = "Статистика по объектам, датчикам, базе данных"
          self.modalInfoClass.hide = false
          self.modal_info.stats = true
          self.modal_info.auth = false
          self.modal_info.panel = false
          self.modal_info.filter = false

          TRIGGERS.panel = true
          document.body.style.overflow = "hidden"
          return

      if need is 'auth'
        Bus.$emit 'runCheckAuth'
        @modal_info.title = "Авторизация"
        @modalInfoClass.hide = false
        @modal_info.stats = false
        @modal_info.auth = true
        @modal_info.panel = false
        @modal_info.filter = false

      if need is 'panel'
        @modal_info.title = "Панель"
        @modalInfoClass.hide = false
        @modal_info.stats = false
        @modal_info.auth = false
        @modal_info.panel = true
        @modal_info.filter = false

      if need is 'filter'
        @modal_info.title = "Фильтры"
        @modalInfoClass.hide = false
        @modal_info.stats = false
        @modal_info.auth = false
        @modal_info.panel = false
        @modal_info.filter = true

      TRIGGERS.panel = true
      document.body.style.overflow = 'hidden'
      return

    modal_info_close: ->
      @modalInfoClass.hide = true
      @modal_info.title = ""
      @modal_info.stats = false
      @modal_info.auth = false
      @modal_info.panel = false
      @modal_info.filter = false

      TRIGGERS.panel = null
      document.body.style.overflow = ''
      return

    editPoint: ->
      return

    send_logout: ->
      Bus.$emit 'sendLogoutRun'
      Bus.$emit 'modal_info_show_auth_run'
      return

    showModal: ->
      TRIGGERS.panel = true
      document.body.style.overflow = 'hidden'

      @modalClass.hide = false
      return

    closeModal: ->
      TRIGGERS.panel = null
      document.body.style.overflow = ''

      @modalClass.hide = true
      return

    toggle_show_dogovor_on_map: ->
      if @filters.dogovors.toggle
        @filters.dogovors.toggle = false
        @buttons.state_icons["dogovors"]["fa-square"] = false
        @buttons.state_icons["dogovors"]["fa-square-o"] = true
        filterApp.add "and", "dogovor", "dogovor", "!==", "\"0\""
        filterApp.make()

      else
        @filters.dogovors.toggle = true
        @buttons.state_icons["dogovors"]["fa-square"] = true
        @buttons.state_icons["dogovors"]["fa-square-o"] = false

        unless @filters.dogovors.alreadyInGroup
          @filters.dogovors.alreadyInGroup = true
          filterApp.remove "and", 'dogovor'
          filterApp.make()
          @loadDogovorsData (data) ->
            ObjectManagerGroup.add data
            return

        else
          filterApp.remove "and", "dogovor"
          filterApp.make()
      return

    toggle_show_companies_on_map: ->
      if @filters.companies.toggle
        @filters.companies.toggle = false
        filterApp.add "and", "iscompany", "iscompany", "!==", true
        filterApp.make()

      else
        @filters.companies.toggle = true

        unless @filters.companies.alreadyInGroup
          @filters.companies.alreadyInGroup = true
          filterApp.add "and", "iscompany", "iscompany", "==", true
          filterApp.make()
          @loadCompaniesData (data) ->
            ObjectManagerGroup.add data
            return

        else
          filterApp.reset()
          filterApp.add "and", "iscompany", "iscompany", "==", true
          filterApp.make()
      return

    find_number_in_list: (event) ->
      event.preventDefault()
      event.stopPropagation()
      target = event.target
      regexp = new RegExp target.value, 'i'

      items = [].slice.call document.querySelectorAll('[data-area="numbers"] li a')
      for item in items
        do (item) ->
          unless regexp.test(item.dataset.number)
            unless item.dataset.area is 'search'
              item.classList.add 'hide'
          else
            item.classList.remove 'hide'
          return
      return

    filter_by_name: (event) ->
      self = @
      target = event.target

      if @timers.search_by_name
        clearTimeout @timers.search_by_name
        @timers.search_by_name = null

      fn = ->
        postJsonWithData "/search/by/name", {name: target.value}, (res) ->
          self.object_names = res.data
          return

        list = document.querySelector "[data-target=\"search_with_name_object_list\"]"
        if target.value.length > 0
          list.style.display = "block"
        else
          list.style.display = "none"
        return

      @timers.search_by_name = setTimeout ->
        fn()
        return
      , 500
      return

    change_filter: (type, id, event, need_send) ->
      if event
        event.preventDefault()
        event.stopPropagation()
        target = event.target
        while target.hasAttribute('nc') is true then target = target.parentNode
        icon = target.querySelector 'i'

      else
        query = "[data-type=\"#{type}\"][data-id=\"#{id}\"] > i"
        icon = document.querySelector query

      need_send = need_send ? true

      if @["#{type}_changed"][id]?
        icon.classList.remove 'fa-check-square-o'
        icon.classList.add 'fa-square-o'

        delete @["#{type}_changed"][id]

        if need_send
          @sync_buttons_send type, id, false

      else
        icon.classList.add 'fa-check-square-o'
        icon.classList.remove 'fa-square-o'

        @["#{type}_changed"][id] = @["#{type}"][id]

        if need_send
          @sync_buttons_send type, id, true

      if need_send
        @set_filters()
      return

    set_filters: ->
      filterApp.make()
      return

    filters_reset: ->
      self = @
      fn = (names) ->
        _from = names[0]
        _to = names[1]

        ids = Object.keys self[_from]

        for id in ids
          do (id) ->
            delete self[_from][id]
            query = "[data-type=\"#{_to}\"][data-id=\"#{id}\"] > i"
            icon = document.querySelector query
            icon.classList.remove 'fa-check-square-o'
            icon.classList.add 'fa-square-o'
            return
        return

      for names in [
        ['class_fps_changed'   , 'class_fps']
        ['services_changed'    , 'services']
        ['types_changed'       , 'types']
        ['departments_changed' , 'departments']
        ['companies_changed'   , 'companies']
        ['regions_changed'     , 'regions']
      ]
        do (names) ->
          fn names
          return

      filterApp.reset()
      filterApp.make()
      return

    filter_by_number: (event) ->
      event.preventDefault()
      event.stopPropagation()
      target = event.target
      while target.hasAttribute('nc') is true then target = target.parentNode
      uid = "#{target.dataset.number}_#{target.dataset.region_id}"
      icon = target.querySelector "i"

      unless uid in @numbers_in_filters
        filterApp.add "orand", "number_#{uid}", "number", "==", "\"#{target.dataset.number}\""
        filterApp.add "orand", "number_#{uid}", "region_id", "==", "\"#{target.dataset.region_id}\""
        filterApp.make()
        @numbers_in_filters.push uid
        icon.classList.add 'fa-check-square-o'
        icon.classList.remove 'fa-square-o'

      else
        filterApp.remove "orand", "number_#{uid}"
        filterApp.make()
        index = @numbers_in_filters.indexOf(target.dataset.region_id)
        @numbers_in_filters.splice index, 1
        icon.classList.remove 'fa-check-square-o'
        icon.classList.add 'fa-square-o'
      return

    search_with_name_object_list__toggle: ->
      list = document.querySelector "[data-target=\"search_with_name_object_list\"]"
      if list.style.display is "none"
        list.style.display = "block"
      else
        list.style.display = "none"
      return

    filter_by_object_name_clear: ->
      self = @
      for l in [].slice.call(document.querySelectorAll("[data-target=\"search_with_name_object_list\"] li"))
        do (l) ->
          icon = l.querySelector "i"
          icon.classList.remove 'fa-check-square-o'
          icon.classList.add 'fa-square-o'
          return

      for uid in @object_names_in_filters
        do (uid) ->
          filterApp.remove "orand", "byname_#{uid}"
          return

      @object_names_in_filters = []
      filterApp.make()
      return

    filter_by_object_name: (object_name, event) ->
      event.preventDefault()
      event.stopPropagation()
      target = event.target
      while target.hasAttribute('nc') is true then target = target.parentNode
      icon = target.querySelector "i"

      uid = "#{object_name.number}_#{object_name.region_id}"

      if uid in @object_names_in_filters
        icon.classList.remove 'fa-check-square-o'
        icon.classList.add 'fa-square-o'
        index = @object_names_in_filters.indexOf uid
        @object_names_in_filters.splice index, 1
        filterApp.remove "orand", "byname_#{uid}",

      else
        icon.classList.add 'fa-check-square-o'
        icon.classList.remove 'fa-square-o'
        @object_names_in_filters.push uid
        filterApp.add "orand", "byname_#{uid}", "number", "==", "\"#{object_name.number}\""
        filterApp.add "orand", "byname_#{uid}", "region_id", "==", "\"#{object_name.region_id}\""

      filterApp.make()
      return

    find_region_in_list: (event) ->
      event.preventDefault()
      event.stopPropagation()
      target = event.target
      regexp = new RegExp target.value, 'i'

      items = [].slice.call document.querySelectorAll('[data-item="region"]')
      if target.value isnt ''
        for item in items
          do (item) ->
            if regexp.test(item.dataset.name)
              item.classList.remove 'hide'
            else
              item.classList.add 'hide'
            return

      else
        for item in items
          do (item) ->
            item.classList.remove 'hide'
            return
      return

    filter_points_state: (state_id) ->
      if @filters.states[state_id]
        @filters.states[state_id] = false
        filterApp.add "and", "state_id_#{state_id}", "state_id", "!==", "\"#{state_id}\""

        if @buttons.state_icons["st#{state_id}"].hasOwnProperty("fa-circle")
          @buttons.state_icons["st#{state_id}"]["fa-circle"] = false
          @buttons.state_icons["st#{state_id}"]["fa-circle-o"] = true

      else
        @filters.states[state_id] = true
        filterApp.remove "and", "state_id_#{state_id}"

        if @buttons.state_icons["st#{state_id}"].hasOwnProperty("fa-circle")
          @buttons.state_icons["st#{state_id}"]["fa-circle"] = true
          @buttons.state_icons["st#{state_id}"]["fa-circle-o"] = false

      filterApp.make()
      return

    sync_buttons_send: (type, id, status) ->
      Bus.$emit 'sync_buttons_side_1_run', type, id, status
      return

    sync_buttons_get: (type, id, status) ->
      @change_filter type, id, null, false
      return


    loadObjectData: (cb) ->
      Preloader.label 'Загружаем данные с сервера'
      cacheData = (data, fromCache) ->
        if cb then cb(data)
        Data = window.Data = data
        unless fromCache
          localStorage.setItem "rows", JSON.stringify(data)
          localStorage.setItem "cached", true

      if localStorage.hasOwnProperty("_cached")
        data = JSON.parse localStorage.getItem "rows"
        cacheData data, true

      else
        getJsonData "/data", (res) ->
          cacheData res.data.rows
          return
      return

    loadStatsData: (cb) ->
      self = @
      getJsonData "/stats", (res) ->
        self.stats = res.data
        if cb then cb()
        return
      return

    loadCompaniesData: (cb) ->
      cacheData = (data, fromCache) ->
        if cb then cb data
        Data = window.Data = data
        unless fromCache
          localStorage.setItem "companies", JSON.stringify(data)
          localStorage.setItem "companies_cached", true

      if localStorage.hasOwnProperty("_companies_cached")
        data = JSON.parse localStorage.getItem "companies"
        if cb then cb data
        cacheData data, true

      else
        getJsonData "/companies", (res) ->
          cacheData res.data.rows
          return
      return

    loadDogovorsData: (cb) ->
      cacheData = (data, fromCache) ->
        if cb then cb data
        Data = window.Data = data
        unless fromCache
          localStorage.setItem "dogovors", JSON.stringify(data)
          localStorage.setItem "dogovors_cached", true

      if localStorage.hasOwnProperty("_dogovors_cached")
        data = JSON.parse localStorage.getItem "dogovors"
        if cb then cb data
        cacheData data, true

      else
        getJsonData "/dogovors", (res) ->
          cacheData res.data.rows
          return
      return

    initTools: ->
      self = @

      getJsonData "/filters", (res) ->
        self.regions = res.data.regions
        self.numbers = res.data.numbers
        self.companies = res.data.companies
        self.class_fps = res.data.class_fps
        self.departments = res.data.departments
        self.types = res.data.types
        self.services = res.data.services
        return
      return

    initMap: (data) ->
      @drawMap data
      return

    drawMap: (data) ->
      if typeof(ymaps) is 'undefined'
        return

      YMap = window.YMap = new ymaps.Map "map",
        center: [
          48.03151328246074
          41.33003048828119
        ]
        zoom: 7
        type: 'yandex#map'
        controls: [
          'zoomControl'
        ]
      ,
        autoFitToViewport: true
        restrictMapArea: [
          [42, 28]
          [52, 56]
        ]

      YMap.behaviors.disable 'scrollZoom'

      ymaps.borders.load('RU', {lang: 'ru', quality: 3}).then (result) ->
        region = null
        for c in result.features
          do (c) ->
            if c.properties.iso3166 is 'RU-ROS'
              region = c
            return

        background = new ymaps.Polygon [
          [
            [82, -170]
            [82,   20]
            [40,   20]
            [40, -170]
            [82, -170]
          ]
        ], {}, {
          fillColor: 'rgba(0, 0, 0, 0.5)'
          strokeWidth: 0
        }

        for c in region.geometry.coordinates
          do (c) ->
            background.geometry.insert 1, c
            return

        YMap.geoObjects.add background
        return

      @drawPlacemarks data
      #
      #
      #
      PMap = window.PMap = new ymaps.Map "map_point",
        center: [
          48.03151328246074
          41.33003048828119
        ]
        zoom: 7
        type: 'yandex#map'
        controls: [
          'zoomControl'
        ]
      ,
        autoFitToViewport: true
        restrictMapArea: [
          [42, 28]
          [52, 56]
        ]

      PMap.behaviors.disable 'scrollZoom'

      ymaps.borders.load('RU', {lang: 'ru', quality: 3}).then (result) ->
        region = null
        for c in result.features
          do (c) ->
            if c.properties.iso3166 is 'RU-ROS'
              region = c
            return

        background = new ymaps.Polygon [
          [
            [82, -170]
            [82,   20]
            [40,   20]
            [40, -170]
            [82, -170]
          ]
        ], {}, {
          fillColor: 'rgba(0, 0, 0, 0.5)'
          strokeWidth: 0
        }

        for c in region.geometry.coordinates
          do (c) ->
            background.geometry.insert 1, c
            return

        PMap.geoObjects.add background
        return

      PMap.events.add 'click', @point_changed_event
      return

    point_changed_event: (event) ->
      console.log "point_changed_event:", event
      coordinate = event.get('coords')
      if window.point_temp
        PMap.geoObjects.remove window.point_temp

      point_temp = window.point_temp = new ymaps.Placemark coordinate
      PMap.geoObjects.add point_temp
      Bus.$emit "changePointRun", event.get('coords')
      return

    getPointData: (id, cb) ->
      getJsonData "/getDataById/#{id}", (res) ->
        if cb then cb res
        return
      return

    placemarkEvent: (event) ->
      id = event.get("objectId")
      point = ObjectManagerGroup.objects.getById id
      self = @

      if point.properties.hasOwnProperty('iscompany')
        if point.properties.iscompany is true
          @closeModal()
          return

      if @row
        if @row.id is point.id
          self.showCard @row
          return

      @getPointData point.id, (json) ->
        self.showCard json.data
        return
      return

    showCard: (row) ->
      @row = row
      @showModal()
      return

    drawPlacemarks: (data) ->
      ObjectManagerGroup = window.ObjectManagerGroup = new ymaps.ObjectManager
        clusterize: false
        gridSize: 0
        clusterDisableClickZoom: true
        clusterIconLayout: "default#pieChart"

      ObjectManagerGroup.events.add 'click', @placemarkEvent

      ObjectManagerGroup.add data.state_1
      ObjectManagerGroup.add data.state_2
      ObjectManagerGroup.add data.state_3

      @ch_counter_objects_state = data.ch_counter_objects_state

      YMap.geoObjects.add ObjectManagerGroup
      return

    updatePlacemarks: (data) ->
      for row, index in data.features
        do (row, index) ->
          ObjectManagerGroup.remove [row.id]
          if (index + 1) is data.features.length
            setTimeout ->
              ObjectManagerGroup.add data
              alertify.message("обновлено #{data.features.length} объектов на карте")
              return
            , 2000
          return
      return

    runSyncData: ->
      self = @

      fn = (ch_counter_objects_state) ->
        if ch_counter_objects_state
          getJsonData "/data/objects_state/#{ch_counter_objects_state}", (res) ->
            if res.status
              self.updatePlacemarks res.data.rows
              self.ch_counter_objects_state = res.data.ch_counter_objects_state

            self.runSyncData()
            return

        else
          self.runSyncData()
        return

      @timers.syncData = setTimeout ->
        fn self.ch_counter_objects_state
        return
      , 32000
      return


  created: ->
    Preloader.label 'подготавливаем приложение'
    self = @
    @initTools()
    @loadObjectData (data) ->
      Preloader.label 'Инициализируем yandex api'

      map_dom = document.getElementById 'map'
      if map_dom
        if map_dom.dataset.yanmapapi
          ymaps.ready ->
            self.initMap data
            return
      return

    @runSyncData()

    Bus.$on 'sendLoginStatus', (user) ->
      self.user = user
      return

    Bus.$on 'runShowPanel', ->
      self.modal_info.title = "Панель"
      self.modalInfoClass.hide = false
      self.modal_info.stats = false
      self.modal_info.auth = false
      self.modal_info.panel = true
      self.modal_info.filter = false

      TRIGGERS.panel = true
      document.body.style.overflow = "hidden"

      document.querySelector("[data-button=\"info\"]").click()
      return

    Bus.$on 'toggle_show_companies_on_map_run', ->
      self.toggle_show_companies_on_map()
      return

    Bus.$on 'modal_info_show_auth_run', ->
      Bus.$emit "runCheckAuth"
      self.modal_info.title = "Авторизация"
      self.modalInfoClass.hide = false
      self.modal_info.stats = false
      self.modal_info.auth = true
      self.modal_info.panel = false
      self.modal_info.filter = false

      TRIGGERS.panel = true
      document.body.style.overflow = "hidden"
      return

    Bus.$on 'modal_info_close_run', ->
      self.modal_info_close()

      TRIGGERS.panel = null
      document.body.style.overflow = ""
      return

    Bus.$on 'sync_buttons_side_2_run', @sync_buttons_get
    Bus.$on 'filters_reset_run', @filters_reset
    return


auth_data_app =
  data: ->
    _data =
      authenticated: false
      registered: false
      login: ''
      user: {}

      login_auth: ''
      password_auth: ''
      login_reg: ''
      password_reg1: ''
      password_reg2: ''

      auth_errors: []
      reg_errors: []

      auth_form:
        hide: true
        fadeOut: false
        fadeIn: false

      reg_form:
        hide: true
        fadeOut: false
        fadeIn: false

      logout_form:
        hide: true
        fadeOut: false
        fadeIn: false

    return _data

  template: null

  methods:
    reset_auth_form: ->
      login_auth: ''
      password_auth: ''

      auth_errors: []
      return

    reset_reg_form: ->
      login_reg: ''
      password_reg1: ''
      password_reg2: ''

      reg_errors: []
      return

    send_auth: ->
      self = @
      postJsonWithData "/auth/login", {login: @login_auth, password: @password_auth}, (res) ->
        self.auth_errors = res.data.errors
        self.authenticated = res.status

        if res.status
          self.login = res.data.user.login
          self.show_logoutform()
          self.send_login_status res.data.user
          self.user = res.data.user

        else
          self.send_login_status {}
          self.user = {}
        return
      return

    send_reg: ->
      self = @
      postJsonWithData "/auth/reg", {login: @login_reg, password1: @password_reg1, password2: @password_reg2}, (res) ->
        self.reg_errors = res.data.errors
        self.registered = res.status

        if res.status
          self.auth_errors = ['войдите под своим логином']
          self.show_authform()
        return
      return

    send_logout: ->
      self = @
      postJsonData "/auth/logout", (res) ->
        if res.status
          self.logout_form.fadeIn = false
          self.logout_form.fadeOut = true
          self.send_login_status {}
          self.user = {}

          setTimeout ->
            self.login = ''
            self.auth_form.fadeOut = false
            self.auth_form.fadeIn = true
            self.auth_form.hide = false
          , 1000
        return
      return

    show_regform: ->
      self = @
      @reset_auth_form()
      @auth_form.fadeIn = false
      @auth_form.fadeOut = true

      setTimeout ->
        self.auth_form.hide = true
        self.reg_form.fadeIn = true
        self.reg_form.fadeOut = false
        self.reg_form.hide = false
      , 1000
      return

    show_authform: ->
      self = @
      @reset_reg_form()
      @reg_form.fadeIn = false
      @reg_form.fadeOut = true
      @logout_form.hide = true

      setTimeout ->
        self.reg_form.hide = true
        self.auth_form.fadeIn = true
        self.auth_form.fadeOut = false
        self.auth_form.hide = false
      , 1000
      return

    show_logoutform: ->
      self = @

      unless @auth_form.hide
        @auth_form.fadeIn = false
        @auth_form.fadeOut = true
        setTimeout ->
          self.auth_form.hide = true
          self.logout_form.fadeIn = true
          self.logout_form.fadeOut = false
          self.logout_form.hide = false
        , 1000

      else
        @logout_form.fadeIn = true
        @logout_form.fadeOut = false
        @logout_form.hide = false
      return

    show_panel: ->
      Bus.$emit('runShowPanel')
      return

    send_login_status: (login) ->
      Bus.$emit('sendLoginStatus', login)
      return

    checkAuth: ->
      self = @
      postJsonData "/auth/check", (res) ->
        if res.status
          self.show_logoutform()
          self.login = res.data.login
          self.user = res.data
          self.send_login_status res.data
        else
          self.show_authform()
          self.user = {}
          self.send_login_status {}
        return
      return

  created: ->
    self = @
    @checkAuth()
    Bus.$on "runCheckAuth", ->
      self.checkAuth()
      return

    Bus.$on "sendLogoutRun", ->
      self.send_logout()
      return
    return

panel_data_app =
  data: ->
    _data = window._pdata =
      users_list: []
      users_helpers: {}

      objects_list: []
      objects_paginations: {}
      objects_list_find: []
      objects_paginations_find: {}
      objects_helpers: {}

      number_find     : null
      region_id_find  : null
      name_find       : null
      address_find    : null
      company_id_find : null

      companies_list: []
      pages_list: []

      class_fps_lists: {}
      departments_lists: {}
      services_lists: {}
      types_lists: {}

      user: {}

      form:
        edit:
          page:
            class:
              hide: true
            errors: []
            messages: []
            model:
              id: null
              name: null
              title: null
              content: null
              views: null
              enabled: null
          user:
            class:
              hide: true
            errors: []
            messages: []
            model:
              id: null
              login: null
              isenabled: null
              role_id: null
              role: null
              fio: null
              email: null
              phone: null

          list:
            class:
              hide: true
            errors: []
            messages: []
            model:
              id: null
              value: null

          object:
            class:
              hide: true
            errors: []
            messages: []
            model:
              id: null
              name: null

          company:
            class:
              hide: true
            errors: []
            messages: []
            model:
              id: null
              title: null

    _data

  template: null

  computed:
    page_content_markdown: ->
      if @form.edit.page.model.content
        html = marked @form.edit.page.model.content
      else
        html = ""
      return html

  methods:
    show_panel_part: (part) ->
      self = @

      switch part
        when 'users', 'pages', 'companies'
          @get_data_and_show(part)
        when 'lists'
          @get_data_and_show_from_lists()
        when 'objects'
          @get_data_and_show_from_objects()
      return

    get_data_and_show: (_from) ->
      self = @
      postJsonWithData "/api", {action: "getdata", from: _from}, (res) ->
        if res.status
          self["#{_from}_list"] = res.data
        else
          self["#{_from}_list"] = []
        return
      return

    get_data_and_show_from_lists: ->
      self = @
      postJsonWithData "/api", {action: "getdata", from: 'lists'}, (res) ->
        if res.status
          self.class_fps_lists = res.data.class_fps
          self.departments_lists = res.data.departments
          self.services_lists = res.data.services
          self.types_lists = res.data.types
        else
          self.class_fps_lists = []
          self.departments_lists = []
          self.services_lists = []
          self.types_lists = []
        return
      return

    get_data_and_show_from_objects: (page) ->
      page = page ? 1
      self = @
      postJsonWithData "/api", {action: "getdata", from: "objects", page: page}, (res) ->
        if res.status
          self.objects_list = res.data.rows
          self.objects_paginations = res.data.paginations
          self.objects_helpers.regions = res.data.helpers.regions
          self.objects_helpers.companies = res.data.helpers.companies
        else
          self.objects_list = []
          self.objects_paginations = {}
          self.objects_helpers = {}
        return
      return

    find_data_and_show_from_objects: (page) ->
      self = @
      page = page ? 1
      params =
        action     : "finddata"
        from       : "objects"
        page       : page
        number     : @number_find
        region_id  : @region_id_find
        name       : @name_find
        address    : @address_find
        company_id : @company_id_find

      postJsonWithData "/api", params, (res) ->
        if res.status
          self.objects_list_find = res.data.rows
          self.objects_paginations_find = res.data.paginations
          self.objects_helpers.regions = res.data.helpers.regions
          self.objects_helpers.companies = res.data.helpers.companies
        else
          self.objects_list_find = []
          self.objects_paginations_find = {}
          self.objects_helpers = {}
        return
      return


    show_edit_form_for_user: (id) ->
      self = @
      postJsonWithData "/api", {action: "getdata", from: "user", id: id}, (res) ->
        if res.status
          self.form.edit.user.model = res.data
          self.users_helpers = res.data.helpers
          delete self.form.edit.user.model.helpers

          self.form.edit.user.class.hide = false
        return
      return

    close_edit_form_for_user: ->
      @reset_form_for_user()
      @form.edit.user.class.hide = true
      return

    save_user: ->
      self = @

      postJsonWithData "/api", {action: "savedata", from: "user", model: @form.edit.user.model}, (res) ->
        if res.status
          self.form.edit.user.model = res.data
          self.sync_list_models res.data, self.users_list
          if self.user.id == res.data.id
            Bus.$emit 'sendLoginStatus', {
              id: res.data.id
              login: res.data.login
              role_id: res.data.role_id
              role: res.data.role
            }

        self.form.edit.user.errors = res.errors
        self.form.edit.user.messages = res.messages

        setTimeout ->
          self.form.edit.user.messages = []
          return
        , 3000

        return
      return

    delete_for_user: (id) ->
      self = @
      postJsonWithData "/api", {action: "delete", from: "user", id: id}, (res) ->
        if res.status
          self.sync_for_delete id, self.users_list
          self.reset_form_for_page()
        return
      return

    toggle_for_user: (id) ->
      self = @
      postJsonWithData "/api", {action: "toggle", from: "user", field: "isenabled", id: id}, (res) ->
        if res.status
          self.sync_toggle_field id, "isenabled", res.data, self.users_list
        return
      return

    change_company_for_user: (id, name) ->
      self = @
      @form.edit.user.model.company_id = id
      @form.edit.user.model.company = name
      return


    create_page_and_show_form: ->
      self = @
      postJsonWithData "/api", {action: "create", from: "page"}, (res) ->
        if res.status
          self.form.edit.page.model = res.data
          self.pages_list.push res.data
          self.form.edit.page.class.hide = false
        return
      return

    show_edit_form_for_page: (id) ->
      self = @
      postJsonWithData "/api", {action: "getdata", from: "page", id: id}, (res) ->
        if res.status
          self.form.edit.page.model = res.data
          self.form.edit.page.class.hide = false
        return
      return

    close_edit_form_for_page: ->
      @reset_form_for_page()
      @form.edit.page.class.hide = true
      return

    delete_for_page: (id) ->
      self = @
      postJsonWithData "/api", {action: "delete", from: "page", id: id}, (res) ->
        if res.status
          self.sync_for_delete id, self.pages_list
          self.reset_form_for_page()
        return
      return

    toggle_for_page: (id) ->
      self = @
      postJsonWithData "/api", {action: "toggle", from: "page", field: "enabled", id: id}, (res) ->
        if res.status
          self.sync_toggle_field id, "enabled", res.data, self.pages_list
        return
      return

    save_page: ->
      self = @
      postJsonWithData "/api", {action: "savedata", from: "page", model: @form.edit.page.model}, (res) ->
        if res.status
          self.form.edit.page.model = res.data
          self.sync_list_models res.data, self.pages_list

        self.form.edit.page.errors = res.errors
        self.form.edit.page.messages = res.messages

        setTimeout ->
          self.form.edit.page.messages = []
          return
        , 3000

        return
      return


    show_change_point_map: ->
      console.log "show_change_point_map"
      if PMap
        p = document.getElementById "map_point"
        if p
          p.classList.add "to_top"

        pb = document.getElementById "map_point_btn"
        if pb
          pb.classList.add "to_top"
      return

    hide_change_point_map: ->
      if PMap
        p = document.getElementById "map_point"
        if p
          p.classList.remove "to_top"

        pb = document.getElementById "map_point_btn"
        if pb
          pb.classList.remove "to_top"
      return

    change_point: (coordinate) ->
      console.log "CP:", coordinate
      @form.edit.object.model.lat = coordinate[0]
      @form.edit.object.model.lng = coordinate[1]
      return


    change_relation_object_company: (id) ->
      console.log "change_relation_object_company:", id
      return

    show_edit_form_for_object: (id) ->
      self = @
      postJsonWithData "/api", {action: "getdata", from: "object", id: id}, (res) ->
        if res.status
          self.form.edit.object.model = res.data
          self.form.edit.object.class.hide = false
        return
      return

    close_edit_form_for_object: ->
      @reset_form_for_object()
      @form.edit.object.class.hide = true
      return

    save_object: ->
      self = @
      postJsonWithData "/api", {action: "savedata", from: "object", model: @form.edit.object.model}, (res) ->
        if res.status
          self.form.edit.object.model = res.data
          self.sync_list_models res.data, self.objects_list

        self.form.edit.object.errors = res.errors
        self.form.edit.object.messages = res.messages

        setTimeout ->
          self.form.edit.object.messages = []
          return
        , 3000
        return
      return

    delete_for_object: (id) ->
      console.log "delete_for_object:", id
      return


    reset_form_for_page: ->
      @form.edit.page.model =
        id: null
        name: null
        title: null
        content: null
        views: null
        enabled: null
      return

    reset_form_for_user: ->
      @form.edit.page.model =
        id: null
        login: null
        isenabled: null
        role_id: null
        role: null
        fio: null
        email: null
        phone: null
      return

    reset_form_for_object: ->
      @form.edit.object.model =
        id: null
        name: null
      return

    reset_form_for_company: ->
      @form.edit.company.model =
        id: null
      return


    sync_list_models: (fresh_model, models_list) ->
      self = @
      for model, index in models_list
        do (model, index) ->
          if model.id is fresh_model.id
            for key, value of fresh_model
              models_list[index][key] = fresh_model[key]
          return
      return

    sync_toggle_field: (id, field_name, fresh_model, models_list) ->
      for model, index in models_list
        do (model, index) ->
          if model.id is id
            models_list[index][field_name] = fresh_model[field_name]
          return
      return

    sync_for_delete: (id, models_list) ->
      _index = null
      for model, index in models_list
        do (model, index) ->
          if model.id is id
            _index = index
          return

      models_list.splice _index, 1
      return


    show_edit_form_for_list: (id) ->
      return


    show_edit_form_for_company: (id) ->
      console.log "show_edit_form_for_company:", id
      self = @
      postJsonWithData "/api", {action: "getdata", from: "company", id: id}, (res) ->
        if res.status
          self.form.edit.company.model = res.data
          self.form.edit.company.class.hide = false
        return
      return

    save_company: ->
      self = @
      postJsonWithData "/api", {action: "savedata", from: "company", model: @form.edit.company.model}, (res) ->
        if res.status
          self.form.edit.company.model = res.data
          self.sync_list_models res.data, self.companies_list

        self.form.edit.company.errors = res.errors
        self.form.edit.company.messages = res.messages

        setTimeout ->
          self.form.edit.company.message = []
          return
        , 3000
        return
      return

    delete_for_company: (id) ->
      self = @
      postJsonWithData "/api", {action: "delete", from: "company", id: id}, (res) ->
        if res.status
          self.sync_for_delete id, self.companies_list
          self.reset_form_for_company()
        return
      return

    create_company_and_show_form: ->
      self = @
      postJsonWithData "/api", {action: "create", from: "company"}, (res) ->
        console.log "create_company_and_show_form:", res
        if res.status
          self.form.edit.company.model = res.data
          self.companies_list.push res.data
          self.form.edit.company.class.hide = false
        return
      return

    close_edit_form_for_company: ->
      @reset_form_for_company()
      @form.edit.company.class.hide = true
      return


  created: ->
    self = @

    Bus.$on 'sendLoginStatus', (user) ->
      self.user = user
      return

    Bus.$on 'changePointRun', (coordinate) ->
      self.change_point coordinate
      return

    Bus.$on 'pointWasChangedRun', ->
      self.hide_change_point_map()
      return
    return


menu_nav_data_app =
  data: ->
    _data =
      current_menu: null
      menu_main_items: []

    _data

  template: null

  methods:
    deactivate_all_items: ->
      for item in @menu_main_items
        do (item) ->
          item.classList.remove 'active'
          return
      return

    change_menu_item: (event) ->
      target = event.target
      while target.hasAttribute('nc') is true then target = target.parentNode

      if target.dataset.click is 'toggle_show_companies_on_map'
        if target.classList.contains('active')
          return

        Bus.$emit('toggle_show_companies_on_map_run')
        @deactivate_all_items()
        target.classList.add 'active'


      else if target.dataset.click is 'toggle_show_monitoring'
        if target.classList.contains('active')
          return

        Bus.$emit('toggle_show_companies_on_map_run')
        @deactivate_all_items()
        target.classList.add 'active'

      else if target.dataset.click is 'modal_info_show_auth'
        Bus.$emit('modal_info_show_auth_run')

      else
        console.log "E: not found"
      return

    toggle_menu_sidebar: (event) ->
      sidebar_dom = document.querySelector '[data-area="menu_sidebar"]'
      if sidebar_dom.classList.contains('menu_sidebar__hidden')
        sidebar_dom.classList.remove 'menu_sidebar__hidden'
      else
        sidebar_dom.classList.add 'menu_sidebar__hidden'
      return

  created: ->
    self = @
    menu_dom = document.querySelector '[data-area="menu"]'
    if menu_dom
      @menu_main_items = [].slice.call menu_dom.querySelectorAll 'li a'
      menu_dom.addEventListener 'click', (event) ->
        self.change_menu_item event
        return

    menu_sidebar_btns = [].slice.call document.querySelectorAll '[data-action="toggle menu_sidebar"]'
    for btn in menu_sidebar_btns
      do (btn) ->
        btn.addEventListener 'click', (event) ->
          self.toggle_menu_sidebar event
          return
        return
    return


filter_panel_data_app =
  data: ->
    _data = window._fdata =
      class_fps: {}
      class_fps_changed: {}
      departments: {}
      departments_changed: {}
      types: {}
      types_changed: {}
      companies: {}
      companies_changed: {}
      services: {}
      services_changed: {}
      regions: {}
      regions_changed: {}

      object_names: []
      object_names_in_filters: []

      timers: {}

      buttons:
        state_icons:
          st1:
            "fa-circle": true
            "fa-circle-o": false
          st2:
            "fa-circle": true
            "fa-circle-o": false
          st3:
            "fa-circle": true
            "fa-circle-o": false
          dogovors:
            "fa-square": false
            "fa-square-o": true
      filters:
        states:
          "1": true
          "2": true
          "3": true
          "dogovors": false

    _data

  template: null

  methods:
    filters_reset: ->
      self = @
      fn = (names) ->
        _from = names[0]
        _to = names[1]

        ids = Object.keys self[_from]
        for id in ids
          do (id) ->
            value = self[_from][id]
            self.$set self[_to], id, value
            self.$delete self[_from], id
            return
        return

      for names in [
        ['regions_changed'     , 'regions']
        ['class_fps_changed'   , 'class_fps']
        ['services_changed'    , 'services']
        ['types_changed'       , 'types']
        ['departments_changed' , 'departments']
        ['companies_changed'   , 'companies']
      ]
        do (names) ->
          fn names
          return

      @modal_info_close()
      Bus.$emit 'filters_reset_run'
      filterApp.reset()
      filterApp.make()
      return

    set_filters_and_show_map: ->
      @modal_info_close()
      filterApp.make()
      return

    modal_info_close: ->
      Bus.$emit('modal_info_close_run')
      return

    find_in_list: (event, input_dom) ->
      if event
        event.preventDefault()
        event.stopPropagation()
        value = event.target.value
        search_target = event.target.dataset.search_target

      else
        value = input_dom.value
        search_target = input_dom.dataset.search_target

      regexp = new RegExp value, 'i'
      items = [].slice.call document.querySelectorAll "[data-search_item=\"#{search_target}\"]"

      for item in items
        if value is ''
          do (item) ->
            item.classList.remove 'hide'
            return

        else
          do (item) ->
            if regexp.test(item.dataset.value)
              item.classList.remove 'hide'
            else
              item.classList.add 'hide'
      return

    filter_points_state: (state) ->
      if @filters.states[state]
        @filters.states[state] = false
        @buttons.state_icons["st#{state}"]["fa-circle"] = false
        @buttons.state_icons["st#{state}"]["fa-circle-o"] = true

      else
        @filters.states[state] = true
        @buttons.state_icons["st#{state}"]["fa-circle"] = true
        @buttons.state_icons["st#{state}"]["fa-circle-o"] = false
      return

    toggle_show_dogovor_on_map: ->
      if @filters.states.dogovors
        @filters.states.dogovors = false
        @buttons.state_icons["dogovors"]["fa-square"] = false
        @buttons.state_icons["dogovors"]["fa-square-o"] = true

      else
        @filters.states.dogovors = true
        @buttons.state_icons["dogovors"]["fa-square"] = true
        @buttons.state_icons["dogovors"]["fa-square-o"] = false
      return

    filter_by_name: (event) ->
      self = @
      target = event.target

      if @timers.search_by_name
        clearTimeout @timers.search_by_name
        @timers.search_by_name = null

      fn = ->
        postJsonWithData "/search/by/name", {name: target.value}, (res) ->
          self.object_names = res.data
          return

        list = document.querySelector "[data-target=\"search_with_name_object_list2\"]"
        if target.value.length > 0
          list.style.display = "block"
        else
          list.style.display = "none"
        return

      @timers.search_by_name = setTimeout ->
        fn()
        return
      , 500
      return

    filter_by_object_name_clear: ->
      self = @
      for l in [].slice.call(document.querySelectorAll("[data-target=\"search_with_name_object_list2\"] li"))
        do (l) ->
          icon = l.querySelector "i"
          icon.classList.remove 'fa-check-square-o'
          icon.classList.add 'fa-square-o'
          return

      for uid in @object_names_in_filters
        do (uid) ->
          filterApp.remove "orand", "byname_#{uid}"
          return

      @object_names_in_filters = []
      filterApp.make()
      return

    search_with_name_object_list__toggle: ->
      list = document.querySelector "[data-target=\"search_with_name_object_list2\"]"
      if list.style.display is "none"
        list.style.display = "block"
      else
        list.style.display = "none"
      return

    filter_by_object_name: (object_name, event) ->
      event.preventDefault()
      event.stopPropagation()
      target = event.target
      while target.hasAttribute('nc') is true then target = target.parentNode
      icon = target.querySelector "i"

      uid = "#{object_name.number}_#{object_name.region_id}"

      if uid in @object_names_in_filters
        icon.classList.remove 'fa-check-square-o'
        icon.classList.add 'fa-square-o'
        index = @object_names_in_filters.indexOf uid
        @object_names_in_filters.splice index, 1
        filterApp.remove "orand", "byname_#{uid}",

      else
        icon.classList.add 'fa-check-square-o'
        icon.classList.remove 'fa-square-o'
        @object_names_in_filters.push uid
        filterApp.add "orand", "byname_#{uid}", "number", "==", "\"#{object_name.number}\""
        filterApp.add "orand", "byname_#{uid}", "region_id", "==", "\"#{object_name.region_id}\""

      filterApp.make()
      return

    change_filter: (type, id, name, event, need_send) ->
      self = @
      if event
        event.preventDefault()
        event.stopPropagation()
        target = event.target
        while target.hasAttribute('nc') is true then target = target.parentNode

      need_send = need_send ? true

      @$set @["#{type}_changed"], id, name
      @$delete @["#{type}"], id

      if need_send
        @sync_buttons_send type, id, true

      if type is 'class_fps'
        filterApp.add 'andor', "#{type}", 'class_fp_id', '==', "\"#{id}\""

      else if type is 'departments'
        filterApp.add 'andor', "#{type}", 'department_id', '==', "\"#{id}\""

      else if type is 'services'
        filterApp.add 'andor', "#{type}", "services.indexOf(\"#{id}\")", '>', "-1"

      else if type is 'companies'
        filterApp.add 'andor', "#{type}", 'company_id', '==', "\"#{id}\""

      else if type is 'types'
        filterApp.add 'andor', "#{type}", 'type_id', '==', "\"#{id}\""

      else if type is 'regions'
        filterApp.add 'andor', "#{type}", 'region_id', '==', "\"#{id}\""

      if event
        if target.parentNode.dataset['search_input']?
          input_dom = document.querySelector "[data-search_target=\"#{target.parentNode.dataset.search_input}\"]"
          if input_dom.value isnt ''
            setTimeout ->
              self.find_in_list null, input_dom
              return
            , 500
          else
            console.log "FIL:", input_dom.value, input_dom
      return

    unchange_filter: (type, id, name, event, need_send) ->
      self = @
      if event
        event.preventDefault()
        event.stopPropagation()
        target = event.target
        while target.hasAttribute('nc') is true then target = target.parentNode

      need_send = need_send ? true

      @$set @["#{type}"], id, name
      @$delete @["#{type}_changed"], id

      if need_send
        @sync_buttons_send type, id, false

      if type is 'class_fps'
        filterApp.remove 'andor', "#{type}", "\"#{id}\""

      else if type is 'departments'
        filterApp.remove 'andor', "#{type}", "\"#{id}\""

      else if type is 'services'
        filterApp.remove 'andor', "#{type}", "services.indexOf(\"#{id}\")", true

      else if type is 'companies'
        filterApp.remove 'andor', "#{type}", "\"#{id}\""

      else if type is 'types'
        filterApp.remove 'andor', "#{type}", "\"#{id}\""

      else if type is 'regions'
        filterApp.remove 'andor', "#{type}", "\"#{id}\""

      if event
        if target.parentNode.dataset['search_input']?
          input_dom = document.querySelector "[data-search_target=\"#{target.parentNode.dataset.search_input}\"]"
          if input_dom.value isnt ''
            setTimeout ->
              self.find_in_list null, input_dom
              return
            , 500
          else
            console.log "FIL:", input_dom.value, input_dom
      return

    sync_buttons_send: (type, id, status) ->
      Bus.$emit 'sync_buttons_side_2_run', type, id, status
      return

    sync_buttons_get: (type, id, status) ->
      if status
        name = @["#{type}"][id]
      else
        name = @["#{type}_changed"][id]

      if status
        @change_filter type, id, name, null, false
      else
        @unchange_filter type, id, name, null, false
      return


  created: ->
    self = @

    getJsonData "/filters", (res) ->
      self.regions = res.data.regions
      self.class_fps = res.data.class_fps
      self.services = res.data.services
      self.types = res.data.types
      self.departments = res.data.departments
      self.companies = res.data.companies
      return

    Bus.$on 'sync_buttons_side_1_run', @sync_buttons_get
    return


main = ->
  filterApp = window.filterApp = Filter.new()
  postJsonData "/templates", (res) ->
    auth_data_app.template = res.data.vue_auth
    Vue.component 'auth', auth_data_app

    panel_data_app.template = res.data.vue_panel
    Vue.component 'panel', panel_data_app

    filter_panel_data_app.template = res.data.vue_filter
    Vue.component 'filter_panel', filter_panel_data_app

    tools_data_app.template = res.data.vue_tools
    Vue.component 'tools', tools_data_app

    tools_app = window.tools_app = new Vue
      el: '#tools'

    Vue.component 'menu_nav', menu_nav_data_app
    menu_app = window.menu_app = new Vue
      el: '#menu_nav'
    return
  return
