
$(function() {
  var persistStore = new Persist.Store("Trusty CMS");
  var needToExpand = [];
  $("#pages").treetable({
    expandable: true,
    initialState: "collapsed",
    onNodeCollapse: function() {
      var node = this;
      persistStore.remove(node.id);
      $("#pages").treetable("unloadBranch", this);
    },
    onInitialized: function() {
      var length = needToExpand.length;
      for (var i = 0; i < length; i++)
        $("#pages").treetable("expandNode", needToExpand[i]);
    },
    onNodeInitialized: function() {
      var node = this;
      var state = persistStore.get(node.id);
      if (state) {
        needToExpand.push(node.id);
      }

    },
    onNodeExpand: function() {
      var node = this;
      var spinner = $($(node.row[0]).find(".busy")[0]);
      spinner.show();
      persistStore.set(node.id, 'expanded');
      // Render loader/spinner while loading
      $.ajax({
        async: true, // Must be false, otherwise loadBranch happens after showChildren?
        url: "/admin/pages/" + node.row.data('ttPageId') + "/children?index=" + node.id
      }).done(function(html) {
        var rows = $(html).filter("tr");

        $("#pages").treetable("loadBranch", node, rows);
        $.each(node.children, function() {
          var state = persistStore.get(this.id);
          if (state) {
            $("#pages").treetable("expandNode", this.id);
          }
        });
        $('a.dropdown').each(function(){
          Dropdown.setup(this);
        });
        spinner.hide();
      });
    }
  });
});
