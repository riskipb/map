{include "menu.tpl"}
{include "tools.tpl"}
{if (isset($yanmapapi))}
<div id="map" data-yanmapapi="{$yanmapapi}"></div>
<div id="map_point"></div>
<div id="map_point_btn">
  <a class="mui-btn mui-btn--raised mui-btn--small mui-btn--danger" onclick="point_was_changed()">
    <i class="fa fa-map-marker"></i>
    скрыть карту
  </a>
</div>
{else}
<div id="map"></div>
<div id="map_point"></div>
{/if}
