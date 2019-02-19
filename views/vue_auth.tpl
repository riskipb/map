<div class="auth_wrap">
  <div class="auth">
    <form class="mui-form animated" v-bind:class="auth_form">
      <legend>Авторизация</legend>
      <div class="mui-textfield mui-textfield--float-label">
        <input type="text" v-model="login_auth">
        <label>логин</label>
      </div>
      <div class="mui-textfield mui-textfield--float-label">
        <input type="password" v-model="password_auth">
        <label>пароль</label>
      </div>
      <div class="mui-textfield" v-if="auth_errors.length > 0">
        <p v-for="error in auth_errors">{{error}}</p>
      </div>

      <div>
        <button type="button" class="mui-btn mui-btn--flat mui-btn--primary" v-on:click="send_auth">отправить</button>
      </div>
      <div>
        <button type="button" class="mui-btn mui-btn--flat" v-on:click="show_regform">регистрация</button>
      </div>
    </form>

    <form class="mui-form animated" v-bind:class="reg_form">
      <legend>Регистрация</legend>
      <div class="mui-textfield mui-textfield--float-label">
        <input type="text" v-model="login_reg">
        <label>логин</label>
      </div>
      <div class="mui-textfield mui-textfield--float-label">
        <input type="password" v-model="password_reg1">
        <label>пароль</label>
      </div>
      <div class="mui-textfield mui-textfield--float-label">
        <input type="password" v-model="password_reg2">
        <label>пароль повторно</label>
      </div>
      <div class="mui-textfield" v-if="reg_errors.length > 0">
        <p v-for="error in reg_errors">{{error}}</p>
      </div>

      <div>
        <button type="button" class="mui-btn mui-btn--flat mui-btn--primary" v-on:click="send_reg">отправить</button>
      </div>
      <div>
        <button type="button" class="mui-btn mui-btn--flat" v-on:click="show_authform">авторизация</button>
      </div>
    </form>

    <form class="mui-form animated" v-bind:class="logout_form">
      <legend>Вы аутентифицированы как</legend>
      <div class="mui-textfield">
        <p class="login_in_logout">{{login}}</p>
      </div>
      <div>
        <button type="button" class="mui-btn mui-btn--flat mui-btn--primary" v-on:click="show_panel">открыть панель</button>
      </div>
      <div>
        <button type="button" class="mui-btn mui-btn--flat" v-on:click="send_logout">выйти</button>
      </div>
    </form>
  </div>
</div>
