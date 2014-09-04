
$(function() {
  $("#pages").treetable({
    expandable: true,
    initialState: "collapsed",
    onNodeExpand: function() {
      var node = this;

      // Render loader/spinner while loading
      $.ajax({
        async: false, // Must be false, otherwise loadBranch happens after showChildren?
        url: "/admin/pages/" + node.row.data('ttPageId') + "/children?index=" + node.id
      }).done(function(html) {
        var rows = $(html).filter("tr");

        rows.find(".directory").parents("tr").each(function() {
          droppableSetup.apply(this);
        });

        $("#pages").treetable("loadBranch", node, rows);
        $('a.dropdown').each(function(){
          Dropdown.setup(this);
        });
      });
    }
  });
});
