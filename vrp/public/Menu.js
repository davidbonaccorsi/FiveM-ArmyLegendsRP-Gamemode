//events
// .onValid(choice)
// .onClose()

function Menu() {
  this.choices = [];
  this.opened = false;
  this.selected = -1;
  this.el_choices = [];

  $("#k-menu").fadeOut();
}

//choices: [name, icon]
Menu.prototype.open = function(choices) {
  this.close();
  this.opened = true;
  this.choices = choices;

  $("#k-choices").find("div").remove();
  this.el_choices = [];

  for (var i = 0; i < this.choices.length; i++) {
    var icon = this.choices[i][1];
    var choice_name = this.choices[i][0];

    var el = $(`
      <div class="choice"><div>${icon} ${choice_name.toLowerCase()}</div></div>
    `);

    this.el_choices.push(el);
    $("#k-choices").append(el);
  }

  $("#k-menu").fadeIn();
  $(".k-description").hide();


  this.setSelected(0);
}

Menu.prototype.setSelected = function(i) {
  if (this.selected >= 0 && this.selected < this.el_choices.length) {
    this.el_choices[this.selected].removeClass("active");
  }

  this.selected = i;
  if (this.selected < 0) this.selected = this.choices.length - 1;
  else if (this.selected >= this.choices.length) this.selected = 0;

  if (this.selected >= 0 && this.selected < this.el_choices.length) {
    this.el_choices[this.selected].addClass("active");
  }

  //scroll to selected
  var scrollto = $(this.el_choices[this.selected]);
  var container = $("#k-choices");
  if (
    scrollto.offset().top < container.offset().top ||
    scrollto.offset().top + scrollto.height() >=
      container.offset().top + container.height()
  )
    container.scrollTop(
      scrollto.offset().top - container.offset().top + container.scrollTop()
    );

  if (this.choices[this.selected][2]) {
    var description = $(".k-description");
    description.children(".wrap").html(this.choices[this.selected][2]);
    description.fadeIn();
  } else {
    $(".k-description").fadeOut();
  }
}

Menu.prototype.close = function() {
  if (this.opened) {
    this.opened = false;
    this.choices = [];

    $("#k-menu").hide();
    $(".k-description").hide();

    if (this.onClose) this.onClose();
  }
};

Menu.prototype.moveUp = function () {
  if (this.opened) this.setSelected(this.selected - 1);
};

Menu.prototype.moveDown = function () {
  if (this.opened) this.setSelected(this.selected + 1);
};

Menu.prototype.valid = function (mod) {
  if (this.selected >= 0 && this.selected < this.choices.length) {
    if (this.onValid && this.opened)
      this.onValid(this.choices[this.selected][0], mod);
  }
};
