% rebase('base.tpl', title='Doorstop', stylesheet='sidebar.css')
<div class="container-fluid">
    <div class="row">
      <div class="col-lg-2 hidden-sm hidden-xs">
          <nav id="TOC" class="nav nav-stacked fixed sidebar">
              {{!toc}}
          </nav>
      </div>
      <div class="col-lg-8" id="main">
        {{!body}}
      </div>
    </div>
</div>
<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
<script src="{{baseurl}}assets/doorstop/jquery.min.js"></script>
<script src="{{baseurl}}assets/doorstop/bootstrap.min.js"></script>
<script>
    $(function() {
        $("table").addClass("table");
        $("nav ul").addClass("nav nav-stacked");
        $("nav").affix();
        $('body').scrollspy({
          target: '.sidebar'
        });
        $("#main a").attr("target", "parent");

  $(window).on('hashchange', function() {
    $(window).scrollTop($(location.hash.toLowerCase()).offset().top);});
  });
</script>
    <script>
    window.addEventListener('beforeunload', function(event) {
      // Send an AJAX request to your Flask server when the tab is closed
      var xhr = new XMLHttpRequest();
      xhr.open('POST', 'http://localhost:5000/closed_tab', true);
      xhr.setRequestHeader('Content-Type', 'application/json');
      xhr.send(JSON.stringify({ 'closed_url': window.location.href }));
    });
  </script>