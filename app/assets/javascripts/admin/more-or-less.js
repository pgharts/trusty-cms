(function(MoreOrLess, $) {
  MoreOrLess.setupToggle = function (link){
    if (link.innerHTML.match(/less/i)) {
      MoreOrLess.toggle(link);
    }
    $(link).on('click', function(event){
      event.preventDefault();
      MoreOrLess.toggle(this);
    });
  }

  MoreOrLess.toggle = function(link) {
    var elements = MoreOrLess.extractToggleObjects($(link).attr('rel'));
    $(elements).slideToggle();

    $(link).toggleClass('less more');
    if (link.innerHTML.match(/less/i)) {
      link.innerHTML = 'More';
    } else if (link.innerHTML.match(/more/i)) {
      link.innerHTML = 'Less';
    }
  }

  MoreOrLess.extractToggleObjects = function(rel) {
    var matches = rel.match(/^toggle\[(.+)\]$/);
    if (matches) {
      var ids = matches[1].split(',');
      return $("#" + ids.join(", #"));
    }
  }

}(window.MoreOrLess = window.MoreOrLess || {}, jQuery));

$(function () {
  $('a.toggle').each(function(){
    MoreOrLess.setupToggle(this);
  });
});
